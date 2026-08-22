#' @rdname enhance
#'
#' @section ReplicaAdder Method:
#'
#' Executes the attribute-assignment workflow.
#'
#' The method:
#'
#' \enumerate{
#'   \item resolves missing contingency groups;
#'   \item calculates conditional fractions;
#'   \item converts fractions into agent allocations;
#'   \item assigns target attribute values; and
#'   \item updates the synthetic population.
#' }
#'
#' Validation results are cleared before execution and may
#' subsequently be regenerated using \code{ratify()}.
#'
#' The updated synthetic population is stored in:
#'
#' \preformatted{
#' x@population
#' }
#'
#' @param x A \code{ReplicaAdder}.
#' @param ... Additional arguments passed to the method.
#'
#' @return An updated \code{ReplicaAdder}.
#'
#' @examples
#' \dontrun{
#'
#' adder <- enhance(
#'   adder
#' )
#'
#' head(
#'   adder@population
#' )
#'
#' }
#'
#' @seealso
#' \code{\link{renew}},
#' \code{\link{ratify}},
#' \code{\link{ReplicaAdder}}
#'
#' @exportMethod enhance
setMethod(
  "enhance",
  "ReplicaAdder",
  
  function(x = "ReplicaAdder", 
           ...) {
    
    #
    # Ensure contingency table contains
    # all group combinations present
    # in the synthetic population
    #
    
    x@contingency_table <-
      
      update_contingency_table(
        
        contingency_table =
          x@contingency_table,
        
        population =
          x@population,
        
        group_by =
          x@group_by,
        
        target_attribute =
          x@target_attribute,
        
        strategy =
          x@missing_group_strategy
        
      )
    
    pop <- data.table::copy(
      x@population
    )
    
    target <- x@target_attribute
    
    pop[
      ,
      (target) := NA_character_
    ]
    
    grouping <- split(
      
      seq_len(
        nrow(pop)
      ),
      
      interaction(
        
        pop[
          ,
          x@group_by,
          with = FALSE
        ],
        
        drop = TRUE
        
      )
      
    )
    
    for (idx in grouping) {
      
      group_dt <- pop[idx]
      
      group_values <-
        
        as.list(
          
          group_dt[
            1,
            x@group_by,
            with = FALSE
          ]
          
        )
      
      mask <- getGroupMask(
        x@contingency_table,
        unlist(group_values),
        x@group_by
      )
      
      contingency_group <-
        x@contingency_table[
          mask,
        ]
      
      #
      # This should never happen now
      # because update_contingency_table()
      # has already handled missing groups.
      #
      
      if (
        nrow(contingency_group) == 0
      ) {
        
        stop(
          paste(
            "update_contingency_table failed to create contingency group:",
            paste(
              unlist(group_values),
              collapse = ", "
            )
          )
        )
        
      }
      
      fractions_dt <-
        getGroupFractions(
          x,
          contingency_group
        )
      
      fractions <-
        fractions_dt$fraction
      
      names(fractions) <-
        fractions_dt[[target]]
      
      values <-
        getAgentValuesFromFractions(
          fractions,
          length(idx)
        )
      
      pop[
        idx,
        (target) := values
      ]
      
    }
    
    x@population <- pop
    
    x <- ratify(x)
    
    x
    
  }
)

#' @rdname procure
#'
#' @section ReplicaAdder Method:
#'
#' Retrieves components stored within a
#' \code{ReplicaAdder}.
#'
#' Typical uses include retrieving:
#'
#' \itemize{
#'   \item synthetic populations;
#'   \item contingency tables; and
#'   \item validation results.
#' }
#'
#' @param x A `ReplicaAdder`.
#' @param slot Character string naming the slot to retrieve.
#' @param ... Additional arguments passed to the method.
#'
#' @return The contents of the requested slot.
#'
#' @examples
#' \dontrun{
#'
#' procure(
#'   adder,
#'   slot = "validation_results"
#' )
#'
#' }
#'
#' @seealso
#' \code{\link{ReplicaAdder}}
#'
#' @export
setMethod(
  "procure",
  "ReplicaAdder",
  function(x,
           slot = character(0),
           ...) {
    
    procureSlot(
      x = x,
      slot_nm_1L_chr = slot,
      ...
    )
    
  }
)

#' @rdname ratify
#'
#' @section ReplicaAdder Method:
#'
#' Evaluates the quality of attribute assignment and stores
#' validation diagnostics within the module.
#'
#' The observed distributions in the synthetic population are
#' compared with the expected distributions supplied by the
#' contingency table.
#'
#' Validation results are stored in:
#'
#' \preformatted{
#' x@validation_results
#' }
#'
#' and include:
#'
#' \itemize{
#'   \item z-squared statistics;
#'   \item p-values;
#'   \item warning flags; and
#'   \item detailed comparisons of observed and expected
#'   distributions.
#' }
#'
#' @param x A `ReplicaAdder`.
#' @param ... Additional arguments passed to the method.
#'
#' @return An updated `ReplicaAdder`.
#'
#' @examples
#' \dontrun{
#'
#' adder <- enhance(
#'   adder
#' )
#'
#' adder <- ratify(
#'   adder
#' )
#'
#' adder@validation_results
#'
#' }
#'
#' @seealso
#' \code{\link{validate_synthetic_population_fit}},
#' \code{\link{plot_validation_distributions}},
#' \code{\link{plot_validation_differences}},
#' \code{\link{plot_validation_heatmap}}
#'
#' @export
setMethod(
  "ratify",
  "ReplicaAdder",
  
  function(x, ...) {
    
    target <-
      x@target_attribute
    
    if (
      any(
        is.na(
          x@population[[target]]
        )
      )
    ) {
      
      warning(
        paste(
          "Missing assignments for",
          target
        )
      )
    }
    
    dimensions <-
      
      unique(
        c(
          x@group_by,
          target
        )
      )
    
    validation <- tryCatch(
      
      validate_synthetic_population_fit(
        
        synthetic_population =
          x@population,
        
        expected =
          x@contingency_table,
        
        dimensions =
          dimensions,
        
        name =
          target
        
      ),
      
      error = function(e) e
      
    )
    
    if (!inherits(validation, "try-error")) {
      
      x@validation_results <-
        validation
      
    }
    
    x
  }
)


#' @rdname renew
#'
#' @section ReplicaAdder Method:
#'
#' Updates a \code{ReplicaAdder} by adding or replacing
#' marginal distributions.
#'
#' Marginal distributions provide additional information
#' about known population totals and can be used alongside
#' contingency tables during attribute assignment.
#'
#' Any existing validation results are automatically cleared
#' when margins are modified.
#'
#' @param x A \code{ReplicaAdder}.
#' @param margins A list of marginal distributions.
#' @param margins_names A list of names corresponding to the
#' @param ... Additional arguments
#' supplied margins.
#'
#' @return An updated \code{ReplicaAdder}.
#'
#' @exportMethod renew
setMethod(
  "renew",
  "ReplicaAdder",
  
  function(
    x,
    margins,
    margins_names,
    ...
  ) {
    
    x@margins <- margins
    
    x@margins_names <- margins_names
    
    x@margins_group <-
      unique(
        unlist(
          margins_names
        )
      )
    
    #
    # Existing validation results are
    # no longer guaranteed to be valid.
    #
    
    x@validation_results <- list()
    
    x
    
  }
)
