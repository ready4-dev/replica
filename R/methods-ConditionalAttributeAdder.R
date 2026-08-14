#' Add Margin Constraints to a ConditionalAttributeAdder
#'
#' Adds one or more margin tables to a
#' \code{ConditionalAttributeAdder} object.
#'
#' Margin tables are used to fit contingency tables to known
#' marginal distributions prior to attribute assignment.
#'
#' This functionality mirrors the Iterative Proportional
#' Fitting (IPF) workflow used in the original GenSynthPop
#' implementation.
#'
#' @param object A \code{ConditionalAttributeAdder} object.
#'
#' @param margins List of margin tables. Each table must contain
#' a \code{count} column and the variables specified in the
#' corresponding entry of \code{margins_names}.
#'
#' @param margins_names List describing the variables contained
#' in each margin table.
#'
#' @return An updated \code{ConditionalAttributeAdder} object.
#'
#' @details
#' Margin constraints are used when contingency information is
#' available at a lower level of aggregation than the available
#' marginal distributions.
#'
#' During execution:
#'
#' \enumerate{
#'   \item The contingency table is fitted to the supplied
#'         margins.
#'   \item Conditional probabilities are recalculated.
#'   \item Target attribute values are assigned.
#' }
#'
#' All margin tables must contain a \code{count} column.
#'
#' Each element of \code{margins_names} should correspond to
#' the variables represented in the matching entry of
#' \code{margins}.
#'
#' @examples
#' \dontrun{
#'
#' gender_margin <- data.frame(
#'   gender = c(
#'     "Male",
#'     "Female"
#'   ),
#'   count = c(
#'     100,
#'     120
#'   )
#' )
#'
#' age_margin <- data.frame(
#'   age_group = c(
#'     "0-17",
#'     "18-64",
#'     "65+"
#'   ),
#'   count = c(
#'     50,
#'     140,
#'     30
#'   )
#' )
#'
#' adder <- addMargins(
#'   adder,
#'   margins = list(
#'     gender_margin,
#'     age_margin
#'   ),
#'   margins_names = list(
#'     "gender",
#'     "age_group"
#'   )
#' )
#'
#' }
#'
#' @seealso
#' \code{\link{ConditionalAttributeAdder}},
#' \code{\link{run}},
#' \code{\link{verify}}
#'
#' @export
setMethod(
  "addMargins",
  "ConditionalAttributeAdder",
  
  function(
    object,
    margins,
    margins_names
  ) {
    
    stopifnot(
      length(margins) ==
        length(margins_names)
    )
    
    object@margins <- margins
    
    object@margins_names <- margins_names
    
    object@margins_group <-
      unique(
        unlist(
          margins_names
        )
      )
    
    validObject(object)
    
    object
  }
)
#' Run Household Generation
#'
#' Executes the complete household-generation workflow and
#' assigns synthetic households to agents in a synthetic
#' population.
#'
#' The method coordinates one or more
#' \code{\link{HouseholdType}} objects and generates household
#' structures according to their configuration.
#'
#' Household generation may include:
#'
#' \itemize{
#'   \item Single-adult household creation.
#'   \item Couple formation.
#'   \item Child grouping.
#'   \item Parent-child matching.
#'   \item Household identifier assignment.
#' }
#'
#' @param object A \code{HouseholdGrouper} object.
#'
#' @return A list containing:
#'
#' \describe{
#'   \item{synthetic_population}{
#'     Synthetic population with household identifiers assigned.
#'   }
#'   \item{synthetic_households}{
#'     Household-level summary table.
#'   }
#'   \item{object}{
#'     Updated \code{HouseholdGrouper} object.
#'   }
#' }
#'
#' @details
#' The workflow consists of the following stages:
#'
#' \enumerate{
#'   \item Update the state of each
#'         \code{\link{HouseholdType}}.
#'   \item Partition the synthetic population according to
#'         the specified grouping variables.
#'   \item Create households within each group using
#'         \code{\link{createFromMembers}}.
#'   \item Validate household assignments using
#'         \code{\link{checkIntegrity}}.
#'   \item Write household identifiers back to the synthetic
#'         population using
#'         \code{\link{agentToHousehold}}.
#'   \item Generate a household summary table using
#'         \code{\link{householdsToDataFrame}}.
#' }
#'
#' The resulting synthetic population and household table are
#' returned together to facilitate subsequent analysis and
#' validation.
#'
#' @examples
#' \dontrun{
#'
#' hg <- HouseholdGrouper(
#'   df_synth_pop = pop,
#'   group_by = "neighb_code"
#' )
#'
#' hg <- addHouseholdType(
#'   hg,
#'   hh
#' )
#'
#' result <- runHouseholdGrouper(
#'   hg
#' )
#'
#' synthetic_population <-
#'   result$synthetic_population
#'
#' synthetic_households <-
#'   result$synthetic_households
#'
#' }
#'
#' @seealso
#' \code{\link{HouseholdGrouper}},
#' \code{\link{HouseholdType}},
#' \code{\link{createFromMembers}},
#' \code{\link{checkIntegrity}},
#' \code{\link{agentToHousehold}},
#' \code{\link{householdsToDataFrame}}
#'
#' @export
setMethod(
  "run",
  "ConditionalAttributeAdder",
  
  function(object) {
    
    #
    # Ensure contingency table contains
    # all group combinations present
    # in the synthetic population
    #
    # print(
    #   object@missing_group_strategy
    # )
    object@contingency <-
      prepareContingencyTable(
        object@contingency,
        object@synth_pop,
        object@group_by,
        object@target_attribute
      )
    # print(
    #   unique(
    #     object@contingency$gender
    #   )
    # )
    
    pop <- data.table::copy(
      object@synth_pop
    )
    
    target <- object@target_attribute
    
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
          object@group_by,
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
            object@group_by,
            with = FALSE
          ]
          
        )
      
      mask <- getGroupMask(
        object@contingency,
        unlist(group_values),
        object@group_by
      )
      # print(nrow(contingency_group))
      contingency_group <-
        object@contingency[
          mask,
        ]
      
      #
      # Safety check
      #
      
      if (
        nrow(contingency_group) == 0
      ) {
        
        group_values_named <-
          unlist(group_values)
        
        names(group_values_named) <-
          object@group_by
        
        contingency_group <-
          
          resolveMissingGroup(
            object,
            group_values_named
          )
        
      }
      
      fractions_dt <-
        getGroupFractions(
          object,
          contingency_group
        )
      
      fractions <-
        fractions_dt$fraction
      
      names(fractions) <- fractions_dt[[target]]
      
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
    
    object@synth_pop <- pop
    
    verify(object)
    
    object
    
  }
)  
#' Verify a Conditionally Assigned Attribute
#'
#' Performs validation checks on a synthetic population after a
#' target attribute has been assigned.
#'
#' This method is typically called automatically by
#' \code{\link{run}} and is responsible for identifying
#' potential issues in the generated population.
#'
#' Validation includes:
#'
#' \itemize{
#'   \item Checking for missing target-attribute assignments.
#'   \item Comparing the resulting synthetic distribution to the
#'         source contingency table.
#'   \item Performing statistical goodness-of-fit checks.
#' }
#'
#' @param object A \code{ConditionalAttributeAdder} object.
#'
#' @return The supplied \code{ConditionalAttributeAdder}
#' object.
#'
#' @details
#' If agents remain without values for the target attribute,
#' a warning is generated.
#'
#' The method also evaluates whether the resulting synthetic
#' population remains statistically consistent with the source
#' contingency distribution.
#'
#' Statistical validation is performed using:
#'
#' \itemize{
#'   \item \code{\link{synthetic_population_to_contingency}}
#'   \item \code{\link{validate_synthetic_population_fit}}
#'   \item \code{\link{calculate_z_squared_score}}
#' }
#'
#' Warnings are issued when the generated distribution differs
#' substantially from the expected contingency-table
#' distribution.
#'
#' @examples
#' \dontrun{
#'
#' adder <- ConditionalAttributeAdder(
#'   synth_pop = population,
#'   contingency = contingency,
#'   target_attribute = "education",
#'   group_by = c(
#'     "age_group",
#'     "gender"
#'   )
#' )
#'
#' adder <- run(adder)
#'
#' adder <- verify(adder)
#'
#' }
#'
#' @seealso
#' \code{\link{run}},
#' \code{\link{validate_synthetic_population_fit}},
#' \code{\link{calculate_z_squared_score}},
#' \code{\link{synthetic_population_to_contingency}},
#' \code{\link{ConditionalAttributeAdder}}
#'
#' @export
setMethod(
  "verify",
  "ConditionalAttributeAdder",
  
  function(object) {
    
    target <-
      object@target_attribute
    
    if (
      any(
        is.na(
          object@synth_pop[[target]]
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
          object@margins_group,
          target
        )
      )
    
    try(
      
      validate_synthetic_population_fit(
        synthetic_population =
          object@synth_pop,
        
        expected =
          object@contingency,
        
        dimensions =
          dimensions,
        
        name =
          target
      ),
      
      silent = TRUE
    )
    
    object
  }
)