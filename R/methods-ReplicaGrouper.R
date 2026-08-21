#' @rdname renew
#'
#' @section ReplicaGrouper Method:
#'
#' Registers a \code{ReplicaStructure} with a
#' \code{ReplicaGrouper}.
#'
#' Registered structures are subsequently used during
#' household generation when \code{manufacture()} is
#' called on the grouper.
#'
#' @param x A \code{ReplicaGrouper}.
#'
#' @param household_type A \code{ReplicaStructure}
#' object to be registered.
#'
#' @return An updated \code{ReplicaGrouper}.
#'
#' @examples
#' \dontrun{
#'
#' grouper <- renew(
#'   grouper,
#'   household_type = structure
#' )
#'
#' }
#'
#' @exportMethod renew
setMethod(
  "renew",
  signature(x = "ReplicaGrouper"),
  
  function(
    x,
    household_type,
    ...
  ) {
    
    x@household_types <-
      c(
        x@household_types,
        list(household_type)
      )
    
    x
  }
)

#' @rdname manufacture
#'
#' @section ReplicaGrouper Method:
#'
#' Generates synthetic households from a synthetic
#' population using one or more registered
#' \code{ReplicaStructure} definitions.
#'
#' For each grouping region, the method:
#'
#' \enumerate{
#'   \item identifies eligible household members;
#'   \item applies registered household structures;
#'   \item matches agents according to demographic rules;
#'   \item generates synthetic households;
#'   \item assigns household identifiers; and
#'   \item creates household-level summary outputs.
#' }
#'
#' @param x A \code{ReplicaGrouper}.
#' 
#' @param ... Additional arguments.
#'
#' @return A list containing:
#'
#' \itemize{
#'   \item \code{synthetic_population};
#'   \item \code{synthetic_households}; and
#'   \item \code{object}.
#' }
#'
#' The \code{synthetic_population} table contains one row
#' per synthetic agent.
#'
#' The \code{synthetic_households} table contains one row
#' per synthetic household.
#'
#' @examples
#' \dontrun{
#'
#' result <- manufacture(
#'   grouper
#' )
#'
#' result$synthetic_population
#'
#' result$synthetic_households
#'
#' }
#'
#' @exportMethod manufacture
setMethod(
  "manufacture",
  signature(x = "ReplicaGrouper"),
  
  function(x, ...) {
    
    if (
      length(
        x@household_types
      ) == 0
    ) {
      
      stop(
        "No household types registered"
      )
      
    }
    
    offset <- 1
    
    for (
      i in seq_along(
        x@household_types
      )
    ) {
      # print("HOUSEHOLD TYPES")
      # print(x@household_types)
      # 
      # print("NAMES")
      # print(names(x@household_types))
      household_type <-
        x@household_types[[i]]
      
      household_type <- renew(
        household_type,
        what = "state",
        df_synth_pop = x@df_synth_pop,
        household_position_column = x@target_column
      )
      
      grouping <- split(
        
        seq_len(
          nrow(
            x@df_synth_pop
          )
        ),
        
        interaction(
          
          x@df_synth_pop[
            ,
            x@group_by,
            with = FALSE
          ],
          
          drop = TRUE
          
        )
        
      )
      
      for (idx in grouping) {
        
        mask <- rep(
          FALSE,
          nrow(
            x@df_synth_pop
          )
        )
        
        mask[idx] <- TRUE
        
        # print("RESULT")
        # str(result)
        # 
        # print("RESULT X")
        # print(result$x)
        # 
        # print("CLASS RESULT X")
        # print(class(result$x))
        
        result <- createFromMembers(
          household_type,
          mask,
          offset
        )
        
        household_type <- result$object
        
        offset <- result$id_offset
        
      }
      # print("DEBUG")
      # print(household_type)
      # print(class(household_type))
      # str(household_type)
      if (
        ratify(household_type,
               output = "logical")
      ) {
        
        household_type <-
          renew(
            household_type,
            what = "households"
          )
        
      }
      
      x@df_synth_pop <-
        household_type@df_synth_pop
      
      x@household_types[[i]] <-
        household_type
      
    }
    
    synthetic_households <- do.call(
      
      rbind,
      
      lapply(
        
        x@household_types,
        
        function(x)
          manufacture(x)
        
      )
      
    )
    
    list(
      
      synthetic_population =
        x@df_synth_pop,
      
      synthetic_households =
        synthetic_households,
      
      x = x
      
    )
    
  }
  
)

