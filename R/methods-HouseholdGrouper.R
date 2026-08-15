#' @rdname addHouseholdType
setMethod(
  "addHouseholdType",
  signature(object = "HouseholdGrouper"),
  
  function(
    object,
    household_type
  ) {
    
    object@household_types <-
      c(
        object@household_types,
        list(household_type)
      )
    
    object
  }
)
#' @rdname run
#'
#' @section HouseholdGrouper Method:
#'
#' Executes the complete household-generation workflow.
#'
#' Typical usage:
#'
#' \preformatted{
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
#' result <- run(hg)
#' }
#'
#' The method:
#'
#' \enumerate{
#'   \item Updates registered HouseholdType objects.
#'   \item Creates adult households.
#'   \item Groups children.
#'   \item Creates family households.
#'   \item Assigns household identifiers.
#'   \item Produces a household summary table.
#' }
setMethod(
  "run",
  signature(object = "HouseholdGrouper"),
  
  function(object) {
    
    if (
      length(
        object@household_types
      ) == 0
    ) {
      
      stop(
        "No household types registered"
      )
      
    }
    
    offset <- 1
    
    for (
      i in seq_along(
        object@household_types
      )
    ) {
      
      household_type <-
        object@household_types[[i]]
      
      household_type <- updateState(
        household_type,
        object@df_synth_pop,
        object@target_column
      )
      
      grouping <- split(
        
        seq_len(
          nrow(
            object@df_synth_pop
          )
        ),
        
        interaction(
          
          object@df_synth_pop[
            ,
            object@group_by,
            with = FALSE
          ],
          
          drop = TRUE
          
        )
        
      )
      
      for (idx in grouping) {
        
        mask <- rep(
          FALSE,
          nrow(
            object@df_synth_pop
          )
        )
        
        mask[idx] <- TRUE
        
        result <- createFromMembers(
          household_type,
          mask,
          offset
        )
        
        household_type <- result$object
        
        offset <- result$id_offset
        
      }
      
      if (
        checkIntegrity(
          household_type
        )
      ) {
        
        household_type <-
          agentToHousehold(
            household_type
          )
        
      }
      
      object@df_synth_pop <-
        household_type@df_synth_pop
      
      object@household_types[[i]] <-
        household_type
      
    }
    
    synthetic_households <- do.call(
      
      rbind,
      
      lapply(
        
        object@household_types,
        
        function(x)
          householdsToDataFrame(x)
        
      )
      
    )
    
    list(
      
      synthetic_population =
        object@df_synth_pop,
      
      synthetic_households =
        synthetic_households,
      
      object = object
      
    )
    
  }
  
)

