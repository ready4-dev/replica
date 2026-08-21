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
          x@synth_pop[[target]]
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
          x@synth_pop,
        
        expected =
          x@contingency,
        
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
#' x@synth_pop
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
#'   adder@synth_pop
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
    
    x@contingency <-
      
      make_contingency_table(
        
        contingency =
          x@contingency,
        
        synth_pop =
          x@synth_pop,
        
        group_by =
          x@group_by,
        
        target_attribute =
          x@target_attribute,
        
        strategy =
          x@missing_group_strategy
        
      )
    
    pop <- data.table::copy(
      x@synth_pop
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
        x@contingency,
        unlist(group_values),
        x@group_by
      )
      
      contingency_group <-
        x@contingency[
          mask,
        ]
      
      #
      # This should never happen now
      # because make_contingency_table()
      # has already handled missing groups.
      #
      
      if (
        nrow(contingency_group) == 0
      ) {
        
        stop(
          paste(
            "make_contingency_table failed to create contingency group:",
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
    
    x@synth_pop <- pop
    
    x <- ratify(x)
    
    x
    
  }
)
