#' @rdname addMargins
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
#' @rdname run
#'
#' @section ConditionalAttributeAdder Method:
#'
#' Executes the conditional attribute-assignment workflow.
#'
#' Typical usage:
#'
#' \preformatted{
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
#' result <- adder@synth_pop
#' }
#'
#' The method:
#'
#' \enumerate{
#'   \item Completes missing contingency groups.
#'   \item Calculates conditional fractions.
#'   \item Converts fractions into agent allocations.
#'   \item Assigns target-attribute values.
#'   \item Verifies the resulting synthetic population.
#' }
setMethod(
  "run",
  "ConditionalAttributeAdder",
  
  function(object) {
    
    #
    # Ensure contingency table contains
    # all group combinations present
    # in the synthetic population
    #
    
    object@contingency <-
      
      prepareContingencyTable(
        
        contingency =
          object@contingency,
        
        synth_pop =
          object@synth_pop,
        
        group_by =
          object@group_by,
        
        target_attribute =
          object@target_attribute,
        
        strategy =
          object@missing_group_strategy
        
      )
    
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
      
      contingency_group <-
        object@contingency[
          mask,
        ]
      
      #
      # This should never happen now
      # because prepareContingencyTable()
      # has already handled missing groups.
      #
      
      if (
        nrow(contingency_group) == 0
      ) {
        
        stop(
          paste(
            "prepareContingencyTable failed to create contingency group:",
            paste(
              unlist(group_values),
              collapse = ", "
            )
          )
        )
        
      }
      
      fractions_dt <-
        getGroupFractions(
          object,
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
    
    object@synth_pop <- pop
    
    verify(object)
    
    object
    
  }
)
#' @rdname verify
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