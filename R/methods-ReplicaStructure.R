#' @rdname manufacture
#'
#' @section ReplicaStructure Method:
#'
#' Creates a household-level summary table from a
#' \code{ReplicaStructure}.
#'
#' One row is returned per synthetic household.
#'
#' Household-level summaries typically include:
#'
#' \itemize{
#'   \item household identifiers;
#'   \item household type;
#'   \item household size; and
#'   \item grouping-region identifiers.
#' }
#'
#' The resulting table can be used for reporting,
#' validation and downstream analysis.
#'
#' @param x A \code{ReplicaStructure}.
#' 
#' @param ... Additional arguments
#'
#' @return A data.frame containing one row per synthetic
#' household.
#'
#' @examples
#' \dontrun{
#'
#' household_summary <- manufacture(
#'   STRUCTURE
#' )
#'
#' household_summary
#'
#' }
#'
#' @seealso
#' \code{\link{ReplicaStructure}},
#' \code{\link{manufacture}}
#'
#' @exportMethod manufacture
setMethod(
  "manufacture",
  signature(x = "ReplicaStructure"),
  
  function(x,
           ...) {
    
    if (length(x@households) == 0) {
      
      return(
        data.frame(
          household_id = character(),
          neighb_code = character(),
          household_type = character(),
          household_size = integer(),
          stringsAsFactors = FALSE
        )
      )
      
    }
    
    household_rows <- lapply(
      
      names(x@households),
      
      function(hid) {
        
        STRUCTURE <- x@households[[hid]]
        
        first_agent <- STRUCTURE$all[1]
        
        if ("neighb_code" %in% names(x@population)) {
          
          neighb_code <-
            
            x@population[
              agent_id == first_agent
            ][["neighb_code"]][1]
          
        } else {
          
          neighb_code <- NA_character_
          
        }
        
        data.frame(
          household_id = hid,
          neighb_code = neighb_code,
          household_type = x@household_type,
          household_size = length(STRUCTURE$all),
          stringsAsFactors = FALSE
        )
        
      }
      
    )
    
    result <- do.call(
      rbind,
      household_rows
    )
    
    rownames(result) <- NULL
    
    result
    
  }
  
)

#' @rdname procure
#'
#' @section ReplicaStructure Method:
#'
#' Retrieves components stored within a
#' \code{ReplicaStructure}.
#'
#' @param x A `ReplicaStructure`.
#' @param slot Character string naming the slot to retrieve.
#' @param ... Additional arguments passed to the method.
#'
#' @return The contents of the requested slot.
#'
#' @examples
#' \dontrun{
#'
#' procure(
#'   STRUCTURE,
#'   slot = "households"
#' )
#'
#' }
#'
#' @seealso
#' \code{\link{ReplicaStructure}}
#'
#' @export
setMethod(
  "procure",
  "ReplicaStructure",
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
#' @param x A \code{ReplicaStructure}.
#' @param output Character string specifying whether a
#' logical validation result (\code{"logical"}) or the
#' validated structure (\code{"self"}) should be returned.
#'
#' @exportMethod ratify
setMethod(
  "ratify",
  signature(x = "ReplicaStructure"),
  
  function(x,
           output = c("self", "logical")) {
    
    output <- match.arg(output)
    all_agents <- getAllAgents(
      x
    )
    
    duplicates <- unique(
      all_agents[
        duplicated(all_agents)
      ]
    )
    
    if (length(duplicates) > 0) {
      
      stop(
        paste(
          "Duplicate agents found:",
          paste(
            duplicates,
            collapse = ", "
          )
        )
      )
      
    }
    
    positions <- unlist(
      
      lapply(
        
        x@positions,
        
        function(x) {
          
          x$position
          
        }
        
      )
      
    )
    
    expected_agents <-
      
      x@population[
        
        x@population[[x@position_column]] %in% positions,
        
        agent_id
        
      ]
    
    missing_agents <-
      
      setdiff(
        expected_agents,
        all_agents
      )
    
    if (
      length(missing_agents) > 0
    ) {
      
      warning(
        paste(
          length(missing_agents),
          "agents not assigned to a household"
        )
      )
      
      valid_1L_lgl <- FALSE
      
    }else{
      valid_1L_lgl <- TRUE
    }
    if(output=="self"){
      if(!valid_1L_lgl){
        stop("unassigned agents")
      }else{
        result_xx <-x
      }
    }else{
      result_xx <- valid_1L_lgl
    }
    result_xx
  }
)

#' @rdname renew
#'
#' @section ReplicaStructure Method:
#'
#' Updates the configuration or state of a
#' \code{ReplicaStructure}.
#'
#' The operation performed is determined by the
#' \code{what} argument.
#'
#' Supported options are:
#'
#' \describe{
#'
#' \item{\code{"slot"}}{
#' Update one or more slots of a
#' \code{ReplicaStructure} using named arguments supplied via
#' \code{...}.
#' }
#'
#' \item{\code{"positions"}}{
#' Define or update household-member requirements.
#'
#' Household positions describe which synthetic agents are
#' eligible for household roles and how many members are
#' required.
#' }
#'
#' \item{\code{"state"}}{
#' Update the internal population state used during
#' household generation.
#'
#' This operation stores the synthetic population and
#' household-position column used by subsequent
#' household-generation methods.
#'
#' When \code{what = "state"}, the following named arguments
#' should be supplied via \code{...}:
#'
#' \itemize{
#'   \item \code{population}
#'   \item \code{position_column}
#' }
#' }
#'
#' \item{\code{"households"}}{
#' Transfer generated household assignments into the
#' synthetic population stored by the structure.
#' }
#'
#' }
#'
#' @param x A \code{ReplicaStructure}.
#'
#' @param what Character string specifying which update
#' operation should be performed.
#'
#' Options include:
#'
#' \itemize{
#'   \item \code{"slot"}
#'   \item \code{"positions"}
#'   \item \code{"state"}
#'   \item \code{"households"}
#' }
#'
#' @param household_position Household position category.
#'
#' @param position_identifier Internal household role
#' identifier used during household formation.
#'
#' @param amount Number of household members required.
#'
#' @param backup_position_identifiers Alternative
#' position identifiers that may be used if the primary
#' position is unavailable.
#'
#' @param ... Additional arguments.
#'
#' When \code{what = "slot"}, named arguments are interpreted
#' as slot updates.
#'
#' When \code{what = "state"}, named arguments should include:
#'
#' \itemize{
#'   \item \code{population}: the synthetic population used
#'   during household generation;
#'   \item \code{position_column}: the column containing
#'   household-position classifications.
#' }
#'
#' @return An updated \code{ReplicaStructure}.
#'
#' @examples
#' \dontrun{
#'
#' ## Update a slot
#'
#' STRUCTURE <- renew(
#'   STRUCTURE,
#'   population = population
#' )
#'
#' ## Update positions
#'
#' STRUCTURE <- renew(
#'   STRUCTURE,
#'   what = "positions",
#'   household_position = "Parent",
#'   position_identifier = "adult",
#'   amount = 2
#' )
#'
#' ## Update state
#'
#' STRUCTURE <- renew(
#'   STRUCTURE,
#'   what = "state",
#'   population = population,
#'   position_column =
#'     "household_position"
#' )
#'
#' ## Update household assignments
#'
#' STRUCTURE <- renew(
#'   STRUCTURE,
#'   what = "households"
#' )
#'
#' }
#'
#' @exportMethod renew
setMethod(
  "renew",
  signature(x = "ReplicaStructure"),
  function(
    x,
    what = c(
      "slot",
      "positions",
      "state",
      "households"
    ),
    household_position = NULL,
    position_identifier = NULL,
    amount = NULL,
    backup_position_identifiers =
      character(),
    ...
  ) {
    
    what <- match.arg(what)
    
    dots <- list(...)
    
    if (what == "slot") {
      
      if (length(dots) == 0) {
        stop("No slot updates supplied.")
      }
      
      x <- update_slots(
        x = x,
        dots = dots
      )
      
      return(x)
      
    }
    
    switch(
      
      what,
      
      positions = {
        
        pos <- list(
          position_identifier =
            position_identifier,
          
          position =
            if (is.character(household_position))
              household_position
          else
            as.character(
              household_position
            ),
          
          amount = amount,
          
          backup_position_identifiers =
            backup_position_identifiers
        )
        
        x@positions[[
          length(x@positions) + 1
        ]] <- pos
        
        x@position_identifiers[[position_identifier]] <- length(x@positions)
        
        x
        
      },
      
      state = {
        
        if (is.null(dots$population)) {
          
          stop(
            "population must be supplied when what = 'state'"
          )
          
        }
        
        if (is.null(dots$position_column)) {
          
          stop(
            paste(
              "position_column must be supplied",
              "when what = 'state'"
            )
          )
          
        }
        
        x@population <-
          data.table::as.data.table(
            dots$population
          )
        
        x@position_column <-
          dots$position_column
        
        x
        
      },
      
      households = {
        
        dt <- data.table::copy(
          x@population
        )
        
        for (hid in names(x@households)) {
          
          agents <-
            x@households[[hid]]$all
          
          idx <-
            dt$agent_id %in%
            agents
          
          dt[
            idx,
            household_id := hid
          ]
          
        }
        
        x@population <- dt
        
        x
        
      }
      
    )
    
  }
)


#' Create households from member assignments.
#'
#' Internal helper used during household generation.
#'
#' @keywords internal
setMethod(
  "createFromMembers",
  signature(object = "ReplicaStructure"),
  
  function(
    object,
    mask,
    id_offset
  ) {
    
    adult_position <-
      getPositionForName(
        object,
        "adult"
      )
    
    #
    # Create adult households
    #
    
    if (adult_position$amount == 2) {
      
      parents <- pair_partners(
        object,
        mask
      )
      
    } else {
      
      parents <- createSingles(
        object,
        mask
      )
      
    }
    
    #
    # If children are part of this
    # household type, attach them
    #
    
    if ("child" %in%
        names(object@position_identifiers)) {
      
      child_position <-
        getPositionForName(
          object,
          "child"
        )
      
      children <- group_children(
        object,
        mask,
        child_position
      )
      
      cat(
        length(children),
        "sets of children vs",
        length(parents),
        "sets of parents\n"
      )
      
      result <- matchAdultsWithChildren(
        object,
        parents,
        children,
        id_offset
      )
      
      object <- result$object
      
      id_offset <- result$id_offset
      
      # cat(
      #   "Created",
      #   length(object@households),
      #   "households\n"
      # )
      
    } else {
      
      # cat(
      #   "Creating households without children\n"
      # )
      
      for (parent in parents) {
        
        agent_ids <- sapply(
          parent,
          function(x) x[[1]]
        )
        
        object <- create_household_with_id(
          object,
          adult_position,
          id_offset,
          agent_ids
        )
        
        # cat(
        #   "Created HH",
        #   sprintf(
        #     "SSH%06d",
        #     id_offset
        #   ),
        #   "\n"
        # )
        
        id_offset <- id_offset + 1
        
      }
      
    }
    
    list(
      object = object,
      id_offset = id_offset
    )
    
  }
  
)
setMethod(
  "getAllAgents",
  signature(object = "ReplicaStructure"),
  
  function(object) {
    
    if (
      length(
        object@households
      ) == 0
    ) {
      
      return(
        character(0)
      )
      
    }
    
    agents <- unlist(
      
      lapply(
        
        object@households,
        
        function(STRUCTURE) {
          
          if (
            is.null(STRUCTURE)
          ) {
            
            return(
              character(0)
            )
            
          }
          
          if (
            is.null(STRUCTURE$all)
          ) {
            
            return(
              character(0)
            )
            
          }
          
          STRUCTURE$all
          
        }
        
      ),
      
      use.names = FALSE
      
    )
    
    as.character(
      agents
    )
    
  }
  
)
#' Identify Agents Eligible for Adult Roles
#'
#' Creates a logical mask identifying agents whose
#' household-position values correspond to adult household roles
#' defined within a \code{\link{ReplicaStructure}} object.
#'
#' This utility is used throughout the household-generation
#' workflow in replica when constructing:
#'
#' \itemize{
#'   \item Single-adult households.
#'   \item Couple households.
#'   \item Family households.
#' }
#'
#' @param object A \code{\link{ReplicaStructure}} object.
#'
#' @param strict Logical value controlling behaviour when no
#' adult position has been defined.
#'
#' If:
#'
#' \describe{
#'   \item{\code{TRUE}}{
#'     An error is raised.
#'   }
#'   \item{\code{FALSE}}{
#'     A logical vector of \code{FALSE} values is returned.
#'   }
#' }
#'
#' @return A logical vector indicating which agents belong to
#' configured adult household positions.
#'
#' @details
#' Adult positions are determined from the household-position
#' definition registered under:
#'
#' \preformatted{
#' position_identifier = "adult"
#' }
#'
#' @examples
#' \dontrun{
#' adult_mask <- getBaseAdultMask(STRUCTURE)
#' }
#'
#' @keywords internal
setMethod(
  "getBaseAdultMask",
  signature(object = "ReplicaStructure"),
  
  function(
    object,
    strict = TRUE
  ) {
    
    #
    # No adult role defined
    #
    
    if (
      !"adult" %in%
      names(
        object@position_identifiers
      )
    ) {
      
      if (strict) {
        
        stop(
          "Position does not exist: adult"
        )
        
      }
      
      return(
        rep(
          FALSE,
          nrow(
            object@population
          )
        )
      )
      
    }
    
    adult_position <- getPositionForName(
      object,
      "adult"
    )
    
    object@population[[object@position_column]] %in% adult_position$position
    
  }
  
)
#' Identify Agents Eligible for Child Roles
#'
#' Creates a logical mask identifying agents whose
#' household-position values correspond to child household roles
#' defined in a \code{\link{ReplicaStructure}} object.
#'
#' This utility is used by the household-generation workflow in
#' replica when constructing sibling groups and family
#' households.
#'
#' @param object A \code{\link{ReplicaStructure}} object.
#'
#' @return A logical vector indicating which agents belong to
#' configured child household positions.
#'
#' @details
#' Child positions are determined from the household-position
#' definition registered under:
#'
#' \preformatted{
#' position_identifier = "child"
#' }
#'
#' @examples
#' \dontrun{
#' child_mask <- getBaseChildMask(STRUCTURE)
#' }
#'
#'
#' @keywords internal
setMethod(
  "getBaseChildMask",
  signature(object = "ReplicaStructure"),
  
  function(object) {
    
    if (
      !"child" %in%
      names(
        object@position_identifiers
      )
    ) {
      
      return(
        rep(
          FALSE,
          nrow(
            object@population
          )
        )
      )
      
    }
    
    child_position <- getPositionForName(
      object,
      "child"
    )
    
    object@population[[object@position_column]] %in% child_position$position
    
  }
)
#' Retrieve a household position definition.
#'
#' Internal helper used by household-generation methods.
#'
#' @keywords internal
setMethod(
  "getPositionForName",
  signature(object = "ReplicaStructure"),
  
  function(
    object,
    position
  ) {
    
    if (
      !position %in%
      names(
        object@position_identifiers
      )
    ) {
      
      stop(
        paste(
          "Position does not exist:",
          position
        )
      )
      
    }
    
    object@positions[[object@position_identifiers[[position]]]]
    
  }
  
)

#' Filter to Agents Not Yet Assigned
#'
#' Applies an eligibility mask and removes agents already
#' assigned during synthetic household generation.
#'
#' This function is a core integrity safeguard in replica and
#' helps ensure that each synthetic agent is assigned to at most
#' one household.
#'
#' @param object A \code{\link{ReplicaStructure}} object.
#'
#' @param df Candidate-agent data frame or data.table.
#'
#' @param mask Logical vector identifying currently eligible
#' agents.
#'
#' @return A filtered data frame or data.table containing only
#' agents that remain available for assignment.
#'
#' @details
#' Agents recorded in:
#'
#' \preformatted{
#' object@assigned_agents
#' }
#'
#' are excluded from the returned candidate set.
#'
#' This function is used extensively by candidate-selection
#' routines throughout replica.
#'
#' @examples
#' \dontrun{
#' remaining <- maskWithRemainingAgents(
#'   STRUCTURE,
#'   procure(ADDER, "population"),
#'   rep(TRUE, nrow(procure(ADDER, "population")))
#' )
#' }
#'
#' @seealso
#' \code{\link{getRemainingAgentsInPosition}},
#' \code{\link{findPrimaryPartner}}
#'
#' @keywords internal
setMethod(
  "maskWithRemainingAgents",
  signature(object = "ReplicaStructure"),
  
  function(
    object,
    df,
    mask
  ) {
    
    remaining_mask <-
      
      mask &
      
      !(
        
        df$agent_id %in%
          
          object@assigned_agents
        
      )
    
    df[
      remaining_mask,
    ]
    
  }
  
)


