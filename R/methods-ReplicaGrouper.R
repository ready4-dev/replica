
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
#'   GROUPER
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
        x@structures
      ) == 0
    ) {
      
      stop(
        "No household types registered"
      )
      
    }
    
    offset <- 1
    
    for (
      i in seq_along(
        x@structures
      )
    ) {
      # print("HOUSEHOLD TYPES")
      # print(x@structures)
      # 
      # print("NAMES")
      # print(names(x@structures))
      structure <-
        x@structures[[i]]
      
      structure <- renew(
        structure,
        what = "state",
        population = x@population,
        position_column = x@position_column
      )
      
      grouping <- split(
        
        seq_len(
          nrow(
            x@population
          )
        ),
        
        interaction(
          
          x@population[
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
            x@population
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
          structure,
          mask,
          offset
        )
        
        structure <- result$object
        
        offset <- result$id_offset
        
      }
      # print("DEBUG")
      # print(structure)
      # print(class(structure))
      # str(structure)
      if (
        ratify(structure,
               output = "logical")
      ) {
        
        structure <-
          renew(
            structure,
            what = "households"
          )
        
      }
      
      x@population <-
        structure@population
      
      x@structures[[i]] <-
        structure
      
    }
    
    synthetic_households <- do.call(
      
      rbind,
      
      lapply(
        
        x@structures,
        
        function(x)
          manufacture(x)
        
      )
      
    )
    
    list(
      
      synthetic_population =
        x@population,
      
      synthetic_households =
        synthetic_households,
      
      x = x
      
    )
    
  }
  
)

#' @rdname procure
#'
#' @section ReplicaGrouper Method:
#'
#' Retrieves components stored within a
#' \code{ReplicaGrouper}.
#'
#' @param x A `ReplicaGrouper`.
#' @param slot Character string naming the slot to retrieve.
#' @param ... Additional arguments passed to the method.
#'
#' @return The contents of the requested slot.
#'
#' @examples
#' \dontrun{
#'
#' procure(
#'   GROUPER,
#'   slot = "population"
#' )
#'
#' }
#'
#' @seealso
#' \code{\link{ReplicaGrouper}}
#'
#' @export
setMethod(
  "procure",
  "ReplicaGrouper",
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

#' @rdname renew
#'
#' @section ReplicaGrouper Method:
#'
#' Updates a \code{ReplicaGrouper}.
#'
#' By default, \code{renew()} updates one or more slots of a
#' \code{ReplicaGrouper} using named arguments supplied via
#' \code{...}.
#'
#' For example:
#'
#' \preformatted{
#' GROUPER <- renew(
#'   GROUPER,
#'   population = population,
#'   what = "structure"
#' )
#' }
#'
#' Slot names must correspond to slots defined for the
#' \code{ReplicaGrouper} class.
#'
#' Alternatively, setting:
#'
#' \preformatted{
#' what = "structure"
#' }
#'
#' registers a \code{ReplicaStructure} with the grouper.
#'
#' Registered structures are subsequently used during
#' household generation when \code{manufacture()} is
#' called.
#'
#' @param x A \code{ReplicaGrouper}.
#'
#' @param structure A \code{ReplicaStructure}
#' object to be registered when
#' \code{what = "structure"}.
#'
#' @param what Character string specifying the type of
#' update to perform.
#'
#' Options are:
#'
#' \itemize{
#'   \item \code{"slot"} updates one or more slots using
#'   named arguments supplied via \code{...};
#'   \item \code{"structure"} registers a
#'   \code{ReplicaStructure}.
#' }
#'
#' @param ... Named slot updates when
#' \code{what = "slot"}.
#'
#' @return An updated \code{ReplicaGrouper}.
#'
#' @examples
#' \dontrun{
#'
#' ## Update a slot
#'
#' GROUPER <- renew(
#'   GROUPER,
#'   population = population
#'   what = "structure"
#' )
#'
#' ## Register a household type
#'
#' GROUPER <- renew(
#'   GROUPER,
#'   what = "structure",
#'   structure = STRUCTURE
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
    structure = NULL,
    what = c("slot", "structure"),
    ...
  ) {
    
    what <- match.arg(what)
    
    dots <- list(...)
    
    if (what == "structure") {
      
      x@structures <-
        c(
          x@structures,
          list(structure)
        )
      
      return(x)
      
    } else {
      
      if (length(dots) == 0) {
        stop("No slot updates supplied.")
      }
      
      x <- update_slots(
        x = x,
        dots = dots
      )
      
    }
    
    x
    
  }
)
