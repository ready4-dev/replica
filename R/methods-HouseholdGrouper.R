#' Add a HouseholdType to a HouseholdGrouper
#'
#' Registers a \code{\link{HouseholdType}} object with a
#' \code{\link{HouseholdGrouper}}.
#'
#' Household types define the structures that will be generated
#' during the household-generation workflow.
#'
#' Multiple household types may be added to the same grouper,
#' allowing different household structures to be constructed
#' within a single synthetic population.
#'
#' @param object A \code{HouseholdGrouper} object.
#'
#' @param household_type A \code{\link{HouseholdType}} object.
#'
#' @return An updated \code{HouseholdGrouper} object.
#'
#' @details
#' Added household types are stored internally in the
#' \code{household_types} slot.
#'
#' During execution,
#' \code{\link{runHouseholdGrouper}} iterates over all
#' registered household types and applies their corresponding
#' household-generation rules.
#'
#' Typical workflow:
#'
#' \enumerate{
#'   \item Create a \code{HouseholdGrouper}.
#'   \item Create one or more \code{HouseholdType} objects.
#'   \item Register the household types using
#'         \code{addHouseholdType()}.
#'   \item Execute household generation using
#'         \code{\link{runHouseholdGrouper}}.
#' }
#'
#' Household types are applied in the order in which they are
#' added.
#'
#' @examples
#' \dontrun{
#'
#' hg <- HouseholdGrouper(
#'   df_synth_pop = pop,
#'   group_by = "neighb_code"
#' )
#'
#' hh <- HouseholdType(
#'   "CoupleHousehold"
#' )
#'
#' hh <- addMembers(
#'   hh,
#'   household_position = "Parent",
#'   position_identifier = "adult",
#'   amount = 2,
#'   backup_position_identifiers = character()
#' )
#'
#' hg <- addHouseholdType(
#'   hg,
#'   hh
#' )
#'
#' }
#'
#' @seealso
#' \code{\link{HouseholdGrouper}},
#' \code{\link{HouseholdType}},
#' \code{\link{runHouseholdGrouper}}
#'
#' @export
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
#' Run Household Generation
#'
#' Executes the complete household-generation workflow for a
#' synthetic population.
#'
#' This method coordinates one or more
#' \code{\link{HouseholdType}} objects and generates synthetic
#' households according to their configured structures,
#' partner-matching distributions and parent-child matching
#' distributions.
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
#' @param object A \code{\link{HouseholdGrouper}} object.
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
#'     Updated \code{\link{HouseholdGrouper}} object.
#'   }
#' }
#'
#' @details
#' The workflow proceeds through the following stages:
#'
#' \enumerate{
#'
#'   \item Update each registered
#'         \code{\link{HouseholdType}} with the current
#'         synthetic population.
#'
#'   \item Partition the synthetic population according to
#'         the grouping variables specified by
#'         \code{group_by}.
#'
#'   \item Generate households independently within each
#'         grouping combination using
#'         \code{\link{createFromMembers}}.
#'
#'   \item Validate household assignments using
#'         \code{\link{checkIntegrity}}.
#'
#'   \item Assign household identifiers to agents using
#'         \code{\link{agentToHousehold}}.
#'
#'   \item Construct a household-level summary table using
#'         \code{\link{householdsToDataFrame}}.
#'
#' }
#'
#' Household identifiers are generated sequentially using the
#' current household offset.
#'
#' The returned synthetic population and household table are
#' suitable for downstream analysis, simulation and validation.
#'
#' @examples
#' \dontrun{
#'
#' hg <- HouseholdGrouper(
#'   df_synth_pop = pop,
#'   group_by = "neighb_code"
#' )
#'
#' hh <- HouseholdType(
#'   "CoupleHousehold"
#' )
#'
#' hh <- addMembers(
#'   hh,
#'   household_position = "Parent",
#'   position_identifier = "adult",
#'   amount = 2,
#'   backup_position_identifiers = character()
#' )
#'
#' hh@couple_gender_distribution <- c(
#'   "Male|Female" = 1
#' )
#'
#' hh@couple_age_distribution <- c(
#'   "-5-5" = 1
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
#' \code{\link{addHouseholdType}},
#' \code{\link{createFromMembers}},
#' \code{\link{agentToHousehold}},
#' \code{\link{householdsToDataFrame}},
#' \code{\link{checkIntegrity}}
#'
#' @export
setMethod(
  "runHouseholdGrouper",
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

