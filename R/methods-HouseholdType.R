#' Add Household Members to a HouseholdType
#'
#' Defines one component of a household structure used during
#' synthetic household generation.
#'
#' This method specifies:
#'
#' \itemize{
#'   \item The household position (for example, \code{"Parent"} or \code{"Child"}).
#'   \item A position identifier used internally by the household generation
#'         algorithms (for example, \code{"adult"} or \code{"child"}).
#'   \item The number of agents required for that position.
#'   \item Optional backup positions that may be used when suitable agents
#'         cannot be found in the primary position pool.
#' }
#'
#' Multiple calls to \code{addMembers()} can be used to define complex
#' household structures.
#'
#' For example, a household consisting of two parents and two children can
#' be defined by:
#'
#' \preformatted{
#' hh <- addMembers(
#'   hh,
#'   household_position = "Parent",
#'   position_identifier = "adult",
#'   amount = 2,
#'   backup_position_identifiers = character()
#' )
#'
#' hh <- addMembers(
#'   hh,
#'   household_position = "Child",
#'   position_identifier = "child",
#'   amount = 2,
#'   backup_position_identifiers = character()
#' )
#' }
#'
#' @param object A \code{HouseholdType} object.
#'
#' @param household_position Character vector identifying one or more
#' household-position values in the synthetic population.
#'
#' @param position_identifier Internal identifier used by the household
#' generation algorithms. Typical values are \code{"adult"} and \code{"child"}.
#'
#' @param amount Number of agents required for this position.
#'
#' @param backup_position_identifiers Character vector of alternative
#' household-position categories that may be used when insufficient
#' suitable agents are available in the primary pool.
#'
#' @return An updated \code{HouseholdType} object.
#'
#' @examples
#' hh <- HouseholdType("Family")
#'
#' hh <- addMembers(
#'   hh,
#'   household_position = "Parent",
#'   position_identifier = "adult",
#'   amount = 2,
#'   backup_position_identifiers = character()
#' )
#'
#' hh <- addMembers(
#'   hh,
#'   household_position = "Child",
#'   position_identifier = "child",
#'   amount = 2,
#'   backup_position_identifiers = character()
#' )
#'
#' @seealso
#' \code{\link{createFromMembers}},
#' \code{\link{updateState}},
#' \code{\link{HouseholdType}}
#'
#' @export
setMethod(
  "addMembers",
  signature(object = "HouseholdType"),
  
  function(
    object,
    household_position,
    position_identifier,
    amount,
    backup_position_identifiers
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
    
    object@positions[[length(object@positions) + 1]] <- pos
    
    object@position_identifiers[[position_identifier]] <- length(object@positions)
    
    object
  }
)
#' Assign Household Identifiers to Agents
#'
#' Writes household identifiers from the household structures
#' stored within a \code{HouseholdType} object back into the
#' associated synthetic population.
#'
#' Each agent belonging to a generated household receives the
#' corresponding household identifier in the
#' \code{household_id} column of the synthetic population.
#'
#' This method is typically called after household generation
#' and before household-level summary tables are created using
#' \code{\link{householdsToDataFrame}}.
#'
#' @param object A \code{HouseholdType} object.
#'
#' @return An updated \code{HouseholdType} object containing
#' household identifiers in the synthetic population stored in
#' the \code{df_synth_pop} slot.
#'
#' @details
#' Household membership is obtained from the
#' \code{households} slot.
#'
#' For each household:
#'
#' \itemize{
#'   \item Agents listed in \code{household$all} are identified.
#'   \item The household identifier is written to the
#'         \code{household_id} column of the synthetic population.
#' }
#'
#' After this method executes, each assigned agent can be linked
#' directly to a synthetic household using:
#'
#' \preformatted{
#' object@df_synth_pop$household_id
#' }
#'
#' @examples
#' \dontrun{
#'
#' hh <- HouseholdType(
#'   "CoupleOnly"
#' )
#'
#' hh@households <- list(
#'
#'   SSH000001 = list(
#'     all = c(
#'       "A001",
#'       "A002"
#'     )
#'   )
#'
#' )
#'
#' hh <- agentToHousehold(
#'   hh
#' )
#'
#' head(
#'   hh@df_synth_pop
#' )
#'
#' }
#'
#' @seealso
#' \code{\link{householdsToDataFrame}},
#' \code{\link{createHouseholdWithId}},
#' \code{\link{checkIntegrity}},
#' \code{\link{HouseholdType}}
#'
#' @export
setMethod(
  "agentToHousehold",
  signature(object = "HouseholdType"),
  
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
setMethod(
  "checkIntegrity",
  signature(object = "HouseholdType"),
  
  function(object) {
    
    all_agents <- getAllAgents(
      object
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
        
        object@positions,
        
        function(x) {
          
          x$position
          
        }
        
      )
      
    )
    
    expected_agents <-
      
      object@df_synth_pop[
        
        object@df_synth_pop[[object@household_position_column]] %in% positions,
        
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
      
      return(FALSE)
      
    }
    
    TRUE
    
  }
)
#' Create Households from Household Members
#'
#' Executes the household-construction workflow for a single
#' \code{\link{HouseholdType}}.
#'
#' Depending on the household structure, this method:
#'
#' \itemize{
#'   \item Creates single-adult households using
#'         \code{\link{createSingles}}.
#'   \item Creates couples using
#'         \code{\link{pairPartners}}.
#'   \item Groups children using
#'         \code{\link{groupChildren}}.
#'   \item Matches adults and children using
#'         \code{\link{matchAdultsWithChildren}}.
#'   \item Creates household records and household identifiers.
#' }
#'
#' This method forms the core execution step of the
#' \code{\link{HouseholdType}} workflow and is typically
#' invoked by \code{\link{runHouseholdGrouper}}.
#'
#' @param object A \code{\link{HouseholdType}} object.
#'
#' @param mask Logical vector identifying agents eligible for
#' household construction.
#'
#' @param id_offset Integer household identifier offset used
#' to generate unique household IDs.
#'
#' @return A list containing:
#'
#' \describe{
#'   \item{object}{
#'     Updated \code{\link{HouseholdType}} object containing
#'     newly-created household records.
#'   }
#'   \item{id_offset}{
#'     Updated household identifier offset.
#'   }
#' }
#'
#' @details
#' Household creation proceeds in several stages.
#'
#' First, adult groups are created:
#'
#' \itemize{
#'   \item If the household requires two adults, couples are
#'         created using \code{\link{pairPartners}}.
#'   \item Otherwise, single-adult households are created using
#'         \code{\link{createSingles}}.
#' }
#'
#' If a child role has been defined:
#'
#' \itemize{
#'   \item Children are grouped into sibling sets using
#'         \code{\link{groupChildren}}.
#'   \item Adult groups are matched to child groups using
#'         \code{\link{matchAdultsWithChildren}}.
#' }
#'
#' If no child role has been defined, adult households are
#' created directly.
#'
#' Newly-created households are stored in the
#' \code{households} slot of the returned object.
#'
#' @examples
#' \dontrun{
#'
#' result <- createFromMembers(
#'   hh,
#'   mask = rep(
#'     TRUE,
#'     nrow(pop)
#'   ),
#'   id_offset = 1
#' )
#'
#' hh <- result$object
#'
#' }
#'
#' @seealso
#' \code{\link{createSingles}},
#' \code{\link{pairPartners}},
#' \code{\link{groupChildren}},
#' \code{\link{matchAdultsWithChildren}},
#' \code{\link{createHouseholdWithId}},
#' \code{\link{runHouseholdGrouper}},
#' \code{\link{HouseholdType}}
#'
#' @export
setMethod(
  "createFromMembers",
  signature(object = "HouseholdType"),
  
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
      
      parents <- pairPartners(
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
      
      children <- groupChildren(
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
      
      cat(
        "Created",
        length(object@households),
        "households\n"
      )
      
    } else {
      
      cat(
        "Creating households without children\n"
      )
      
      for (parent in parents) {
        
        agent_ids <- sapply(
          parent,
          function(x) x[[1]]
        )
        
        object <- createHouseholdWithId(
          object,
          adult_position,
          id_offset,
          agent_ids
        )
        
        cat(
          "Created HH",
          sprintf(
            "SSH%06d",
            id_offset
          ),
          "\n"
        )
        
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
  signature(object = "HouseholdType"),
  
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
setMethod(
  "getBaseAdultMask",
  signature(object = "HouseholdType"),
  
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
setMethod(
  "getBaseChildMask",
  signature(object = "HouseholdType"),
  
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
#' Retrieve a Household Position Definition
#'
#' Returns a household-position definition stored within a
#' \code{HouseholdType} object.
#'
#' Household positions are created using
#' \code{\link{addMembers}} and describe the structure of a
#' household type.
#'
#' Typical position identifiers include:
#'
#' \itemize{
#'   \item \code{"adult"}
#'   \item \code{"child"}
#' }
#'
#' The returned object contains:
#'
#' \describe{
#'   \item{position_identifier}{
#'     Internal role identifier.
#'   }
#'   \item{position}{
#'     Household-position value(s) in the synthetic population.
#'   }
#'   \item{amount}{
#'     Number of agents required for the role.
#'   }
#'   \item{backup_position_identifiers}{
#'     Alternative position categories that may be used if
#'     suitable agents cannot be found in the primary pool.
#'   }
#' }
#'
#' This method is used extensively throughout the household
#' generation workflow by:
#'
#' \itemize{
#'   \item \code{\link{createSingles}}
#'   \item \code{\link{pairPartners}}
#'   \item \code{\link{groupChildren}}
#'   \item \code{\link{matchAdultsWithChildren}}
#'   \item \code{\link{createFromMembers}}
#' }
#'
#' @param object A \code{HouseholdType} object.
#'
#' @param position Character string identifying the required
#' household role.
#'
#' @return A list describing the requested household position.
#'
#' @examples
#' \dontrun{
#'
#' hh <- HouseholdType(
#'   "Family"
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
#' adult_position <- getPositionForName(
#'   hh,
#'   "adult"
#' )
#'
#' adult_position$amount
#'
#' }
#'
#' @seealso
#' \code{\link{addMembers}},
#' \code{\link{createSingles}},
#' \code{\link{pairPartners}},
#' \code{\link{HouseholdType}}
#'
#' @export
setMethod(
  "getPositionForName",
  signature(object = "HouseholdType"),
  
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
#' Convert Household Structures to a Data Frame
#'
#' Constructs a household-level data frame from the households
#' stored within a \code{HouseholdType} object.
#'
#' Each row of the returned data frame represents a single
#' synthetic household and contains:
#'
#' \itemize{
#'   \item Household identifier.
#'   \item Neighbourhood code.
#'   \item Household type.
#'   \item Household size.
#' }
#'
#' This method is typically called after household generation
#' has completed and household identifiers have been assigned to
#' agents via \code{\link{agentToHousehold}}.
#'
#' @param object A \code{HouseholdType} object.
#'
#' @return A data frame containing one row per synthetic
#' household.
#'
#' @details
#' Household size is calculated as the number of agents listed
#' in the household's \code{all} member vector.
#'
#' The neighbourhood code is obtained from the first agent in
#' each household and is assumed to be common to all household
#' members.
#'
#' If no households have been created, an empty data frame with
#' the expected columns is returned.
#'
#' Returned columns include:
#'
#' \describe{
#'   \item{household_id}{
#'     Unique household identifier.
#'   }
#'   \item{neighb_code}{
#'     Neighbourhood code associated with the household.
#'   }
#'   \item{hh_type}{
#'     Household type.
#'   }
#'   \item{hh_size}{
#'     Number of agents assigned to the household.
#'   }
#' }
#'
#' @examples
#' \dontrun{
#'
#' households <- householdsToDataFrame(
#'   hh
#' )
#'
#' head(households)
#'
#' }
#'
#' @seealso
#' \code{\link{agentToHousehold}},
#' \code{\link{createHouseholdWithId}},
#' \code{\link{runHouseholdGrouper}},
#' \code{\link{HouseholdType}}
#'
#' @export
setMethod(
  "householdsToDataFrame",
  signature(object = "HouseholdType"),
  
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
setMethod(
  "maskWithRemainingAgents",
  signature(object = "HouseholdType"),
  
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

#' Update the Internal HouseholdType State
#'
#' Attaches the current synthetic population and the household
#' position column to a \code{HouseholdType} object.
#'
#' This method is typically called by household-generation
#' workflows such as \code{\link{runHouseholdGrouper}} prior to
#' household construction.
#'
#' The synthetic population stored by this method is subsequently
#' used by:
#'
#' \itemize{
#'   \item \code{\link{createSingles}}
#'   \item \code{\link{pairPartners}}
#'   \item \code{\link{groupChildren}}
#'   \item \code{\link{matchAdultsWithChildren}}
#'   \item \code{\link{agentToHousehold}}
#' }
#'
#' @param object A \code{HouseholdType} object.
#'
#' @param df_synth_pop A data frame or data.table containing the
#' synthetic population.
#'
#' @param household_position_column Character string identifying
#' the column containing household-position classifications such
#' as \code{"Parent"}, \code{"Child"}, or
#' \code{"SingleAdult"}.
#'
#' @return An updated \code{HouseholdType} object.
#'
#' @details
#' The supplied synthetic population is stored internally in the
#' \code{df_synth_pop} slot.
#'
#' The supplied household-position column name is stored in the
#' \code{household_position_column} slot and used throughout the
#' household-generation workflow.
#'
#' @examples
#' \dontrun{
#'
#' library(data.table)
#'
#' pop <- data.table(
#'   agent_id = c(
#'     "A001",
#'     "A002"
#'   ),
#'   household_position = c(
#'     "Parent",
#'     "Parent"
#'   )
#' )
#'
#' hh <- HouseholdType(
#'   "CoupleOnly"
#' )
#'
#' hh <- updateState(
#'   hh,
#'   pop,
#'   "household_position"
#' )
#'
#' hh@household_position_column
#'
#' }
#'
#' @seealso
#' \code{\link{HouseholdType}},
#' \code{\link{createSingles}},
#' \code{\link{pairPartners}},
#' \code{\link{groupChildren}},
#' \code{\link{matchAdultsWithChildren}},
#' \code{\link{runHouseholdGrouper}}
#'
#' @export
setMethod(
  "updateState",
  signature(object = "HouseholdType"),
  
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
