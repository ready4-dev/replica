#' @rdname renew
#'
#' @section ReplicaStructure Method:
#'
#' For a `ReplicaStructure`, `renew()` defines or updates
#' household-member requirements.
#'
#' Household positions specify which synthetic agents are
#' eligible for a role, while position identifiers define the
#' household roles used internally by the matching algorithm.
#'
#' @param x A `ReplicaStructure`.
#' @param household_position Household position category.
#' @param position_identifier Internal household role
#' identifier used during household formation.
#' @param amount Number of household members required.
#' @param backup_position_identifiers Alternative position
#' identifiers that may be used when primary positions are
#' unavailable.
#'
#' @return An updated `ReplicaStructure`.
#'
#' @exportMethod renew
setMethod(
  "renew",
  signature(x = "ReplicaStructure"),
  
  function(
    x,
    household_position,
    position_identifier,
    amount,
    backup_position_identifiers,
    ...
  ) {
    
    pos <- list(
      position_identifier = position_identifier,
      
      position =
        if (is.character(household_position))
          household_position
      else
        as.character(household_position),
      
      amount = amount,
      
      backup_position_identifiers = backup_position_identifiers)
    
    x@positions[[length(x@positions) + 1]] <- pos
    
    x@position_identifiers[[position_identifier]] <- length(x@positions)
    
    x
  }
)
#' @rdname agentToHousehold
setMethod(
  "agentToHousehold",
  signature(object = "ReplicaStructure"),
  
  function(object) {
    
    dt <- data.table::copy(
      object@df_synth_pop
    )
    
    for (hid in names(object@households)) {
      
      agents <-
        object@households[[hid]]$all
      
      idx <-
        dt$agent_id %in%
        agents
      
      dt[
        idx,
        household_id := hid
      ]
      
    }
    
    object@df_synth_pop <- dt
    
    object
    
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
      
      x@df_synth_pop[
        
        x@df_synth_pop[[x@household_position_column]] %in% positions,
        
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
        
        function(hh) {
          
          if (
            is.null(hh)
          ) {
            
            return(
              character(0)
            )
            
          }
          
          if (
            is.null(hh$all)
          ) {
            
            return(
              character(0)
            )
            
          }
          
          hh$all
          
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
#' adult_mask <- getBaseAdultMask(hh)
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
            object@df_synth_pop
          )
        )
      )
      
    }
    
    adult_position <- getPositionForName(
      object,
      "adult"
    )
    
    object@df_synth_pop[[object@household_position_column]] %in% adult_position$position
    
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
#' child_mask <- getBaseChildMask(hh)
#' }
#'
#' @seealso
#' \code{\link{group_children}},
#' \code{\link{matchAdultsWithChildren}}
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
            object@df_synth_pop
          )
        )
      )
      
    }
    
    child_position <- getPositionForName(
      object,
      "child"
    )
    
    object@df_synth_pop[[object@household_position_column]] %in% child_position$position
    
  }
  
)
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
#' @rdname householdsToDataFrame
setMethod(
  "householdsToDataFrame",
  signature(object = "ReplicaStructure"),
  
  function(object) {
    
    if (length(object@households) == 0) {
      
      return(
        data.frame(
          household_id = character(),
          neighb_code = character(),
          hh_type = character(),
          hh_size = integer(),
          stringsAsFactors = FALSE
        )
      )
      
    }
    
    household_rows <- lapply(
      
      names(object@households),
      
      function(hid) {
        
        hh <- object@households[[hid]]
        
        first_agent <- hh$all[1]
        
        if ("neighb_code" %in% names(object@df_synth_pop)) {
          
          neighb_code <-
            
            object@df_synth_pop[
              agent_id == first_agent
            ][["neighb_code"]][1]
          
        } else {
          
          neighb_code <- NA_character_
          
        }
        
        data.frame(
          household_id = hid,
          neighb_code = neighb_code,
          hh_type = object@hh_type,
          hh_size = length(hh$all),
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
#' object@sampled_agents
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
#'   hh,
#'   hh@df_synth_pop,
#'   rep(TRUE, nrow(hh@df_synth_pop))
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
          
          object@sampled_agents
        
      )
    
    df[
      remaining_mask,
    ]
    
  }
  
)

#' @rdname updateState
setMethod(
  "updateState",
  signature(object = "ReplicaStructure"),
  
  function(
    object,
    df_synth_pop,
    household_position_column
  ) {
    
    object@df_synth_pop <-
      data.table::as.data.table(
        df_synth_pop
      )
    
    object@household_position_column <-
      household_position_column
    
    object
  }
)
