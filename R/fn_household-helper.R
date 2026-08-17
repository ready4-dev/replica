#' Create a Household Record and Assign a Household Identifier
#'
#' Creates a new synthetic household and stores it within a
#' \code{HouseholdType} object.
#'
#' Each household is assigned a unique household identifier of
#' the form:
#'
#' \preformatted{
#' SSH000001
#' SSH000002
#' SSH000003
#' }
#'
#' The newly-created household stores:
#'
#' \itemize{
#'   \item The complete list of household members.
#'   \item Members associated with the supplied household role.
#' }
#'
#' This function is used internally during household generation
#' by:
#'
#' \itemize{
#'   \item \code{\link{pair_partners}}
#'   \item \code{\link{matchAdultsWithChildren}}
#' }
#'
#' @param object A \code{HouseholdType} object.
#'
#' @param position Household-position definition returned by
#' \code{\link{getPositionForName}}.
#'
#' @param id_offset Integer offset used to generate a unique
#' household identifier.
#'
#' @param agents Character vector containing the agent IDs that
#' belong to the household.
#'
#' @return An updated \code{HouseholdType} object containing the
#' newly-created household.
#'
#' @details
#' The household is stored in the \code{households} slot.
#'
#' Each household contains:
#'
#' \describe{
#'   \item{all}{
#'     Character vector containing all household members.
#'   }
#'   \item{position_identifier}{
#'     Members assigned under the role associated with the
#'     supplied position definition.
#'   }
#' }
#'
#' Household identifiers are generated using:
#'
#' \preformatted{
#' sprintf("SSH%06d", id_offset)
#' }
#'
#' @examples
#' \dontrun{
#'
#' hh <- HouseholdType(
#'   "CoupleOnly"
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
#' hh <- create_household_with_id(
#'   hh,
#'   position = adult_position,
#'   id_offset = 1,
#'   agents = c(
#'     "A001",
#'     "A002"
#'   )
#' )
#'
#' names(hh@households)
#'
#' }
#'
#' @seealso
#' \code{\link{getPositionForName}},
#' \code{\link{pair_partners}},
#' \code{\link{matchAdultsWithChildren}},
#' \code{\link{HouseholdType}}
#'
#' @export
create_household_with_id <- function(
    #create_household_with_id() is currently storing the entire household under the "child" slot when called from matchAdultsWithChildren(). REFACTOR
    object,
    position,
    id_offset,
    agents
) {
  if (is.null(position))
    stop("position is NULL")
  
  if (is.null(position$position_identifier))
    stop("position does not contain a position_identifier")
  
  if (length(position$position_identifier) != 1)
    stop("position_identifier must contain exactly one value")
  
  household_id <- sprintf(
    "SSH%06d",
    id_offset
  )
  
  household <- list(
    all = agents
  )
  
  household[[position$position_identifier]] <- agents
  
  object@households[[household_id]] <- household
  
  return(object)
}
createSingles <- function(
    object,
    group_mask
) {
  
  # Adults eligible for this household type
  
  adult_mask <- group_mask &
    getBaseAdultMask(object)
  
  parent_position <- getPositionForName(
    object,
    "adult"
  )
  
  # Number of households required
  
  n_households <- ceiling(
    sum(adult_mask) /
      parent_position$amount
  )
  
  # If this household type contains children,
  # ensure sufficient parent groups exist
  
  if ("child" %in%
      names(object@position_identifiers)) {
    
    child_position <- getPositionForName(
      object,
      "child"
    )
    
    n_children <- ceiling(
      
      sum(
        group_mask &
          getBaseChildMask(object)
      ) /
        
        child_position$amount
      
    )
    
    n_households <- max(
      n_households,
      n_children
    )
  }
  
  single_households <- list()
  
  for (i in seq_len(n_households)) {
    
    p <- findPrimaryPartner(
      object,
      group_mask,
      parent_position$position,
      parent_position$backup_position_identifiers
    )
    
    object@sampled_agents <- c(
      object@sampled_agents,
      p$agent_id
    )
    
    single_households[[i]] <- list(
      c(
        p$agent_id,
        p$age,
        p$gender
      )
    )
    
  }
  
  attr(
    single_households,
    "object"
  ) <- object
  
  single_households
  
}
#' Find and Rank Couple Candidates
#'
#' Identifies and ranks potential secondary partners for a
#' selected primary partner.
#'
#' Candidates are restricted to eligible household-position
#' categories and are scored according to the age-gap
#' requirements currently being considered.
#'
#' This function is used internally by
#' \code{\link{findSecondaryPartner}} and
#' \code{\link{pair_partners}}.
#'
#' @param object A \code{HouseholdType} object.
#'
#' @param mask Logical vector identifying agents eligible for
#' partner selection.
#'
#' @param position_value Character vector containing eligible
#' household-position values.
#'
#' @param primary_partner Single-row data frame or data.table
#' representing the already-selected primary partner.
#'
#' @param gap_start Lower bound of the preferred age gap.
#'
#' @param gap_end Upper bound of the preferred age gap.
#'
#' @return A data frame or data.table containing candidate
#' partners ranked by suitability.
#'
#' @details
#' The function:
#'
#' \enumerate{
#'   \item Restricts candidates to the specified household
#'         positions.
#'   \item Removes agents already listed in
#'         \code{sampled_agents}.
#'   \item Removes the primary partner from consideration.
#'   \item Converts the supplied age gap into an acceptable age
#'         range using \code{\link{calculate_age_range_from_gap}}.
#'   \item Computes a suitability score for every candidate
#'         using
#'         score_suitability_by_age_disparity.
#'   \item Returns candidates sorted from best to worst match.
#' }
#'
#' Lower suitability scores indicate better matches.
#'
#' Candidates with a suitability score of zero fall within the
#' preferred age-gap range.
#'
#' @examples
#' \dontrun{
#'
#' candidates <- findCoupleCandidates(
#'   object = hh,
#'   mask = rep(
#'     TRUE,
#'     nrow(pop)
#'   ),
#'   position_value = "Parent",
#'   primary_partner = primary_partner,
#'   gap_start = -5,
#'   gap_end = 5
#' )
#'
#' candidates[
#'   ,
#'   c(
#'     "agent_id",
#'     "age",
#'     "suitability"
#'   )
#' ]
#'
#' }
#'
#' @seealso
#' \code{\link{findPrimaryPartner}},
#' \code{\link{findSecondaryPartner}},
#' \code{\link{pair_partners}},
#' \code{\link{calculate_age_range_from_gap}},
#'
#' @keywords internal
findCoupleCandidates <- function(
    object,
    mask,
    position_value,
    primary_partner,
    gap_start,
    gap_end
) {
  
  # Restrict to requested household positions
  
  mask <- mask &
    (
      object@df_synth_pop[[object@household_position_column]] %in% position_value
    )
  
  # Exclude agents already assigned elsewhere
  
  mask <- mask &
    !(
      object@df_synth_pop$agent_id %in%
        object@sampled_agents
    )
  
  candidates <- object@df_synth_pop[
    mask,
  ]
  
  # Prevent candidate being matched to themselves
  
  candidates <- candidates[
    candidates$agent_id !=
      primary_partner$agent_id,
  ]
  
  # Convert age gap into acceptable age range
  
  age_range <- calculate_age_range_from_gap(
    age = primary_partner$age,
    gap_start = gap_start,
    gap_end = gap_end
  )
  
  age_start <- as.numeric(
    age_range["age_start"]
  )
  
  age_end <- as.numeric(
    age_range["age_end"]
  )
  # Calculate suitability score
  
  candidates$suitability <- sapply(
    
    candidates$age,
    
    function(x) {
      
      score_suitability_by_age_disparity(
        partner_age = x,
        age_start = age_start,
        age_end = age_end
      )
      
    }
    
  )
  
  # Best candidates first
  
  candidates[
    order(candidates$suitability),
  ]
  
}
#' Find a Replacement Candidate of the Opposite Gender
#'
#' Identifies an available candidate of the opposite gender that
#' most closely resembles a supplied candidate.
#'
#' This function supports fallback partner-matching behaviour
#' within replica when the preferred gender composition cannot
#' be achieved directly from the primary candidate pool.
#'
#' @param object A \code{\link{HouseholdType}} object.
#'
#' @param wrong_candidate Candidate requiring replacement.
#'
#' @param mask Logical eligibility mask.
#'
#' @param position Household-position category to search.
#'
#' @return A single-row data frame or data.table containing the
#' selected replacement candidate.
#'
#' Returns \code{NULL} if no suitable replacement exists.
#'
#' @details
#' Candidate selection is restricted to agents who:
#'
#' \itemize{
#'   \item Occupy the specified household-position category.
#'   \item Have the opposite gender.
#'   \item Have not already been assigned.
#' }
#'
#' Candidates are ranked according to a simple similarity score
#' based on matching demographic and household characteristics.
#'
#' @examples
#' \dontrun{
#' replacement <-
#'   findOppositeGenderReplacementForCandidate(
#'     hh,
#'     wrong_candidate,
#'     mask,
#'     "SingleAdult"
#'   )
#' }
#'
#' @seealso
#' \code{\link{switchHouseholdPositions}},
#' \code{\link{findSecondaryPartner}}
#'
#' @keywords internal
findOppositeGenderReplacementForCandidate <- function(
    object,
    wrong_candidate,
    mask,
    position
) {
  
  dt <- object@df_synth_pop
  
  if (length(mask) != nrow(dt)) {
    
    stop(
      sprintf(
        "Mask length (%s) does not match number of rows (%s)",
        length(mask),
        nrow(dt)
      )
    )
    
  }
  
  wrong_gender <- wrong_candidate$gender[1]
  
  candidate_mask <-
    mask &
    (dt[[object@household_position_column]] == position) &
    (dt$gender != wrong_gender) &
    !(dt$agent_id %in% object@sampled_agents)
  
  candidates <- dt[
    candidate_mask,
  ]
  
  # No replacement candidates
  
  if (nrow(candidates) == 0) {
    
    return(NULL)
    
  }
  
  # Calculate similarity scores
  
  similarity_scores <- sapply(
    
    seq_len(nrow(candidates)),
    
    function(i) {
      
      candidate <- candidates[i, ]
      
      score <- 0
      
      for (col in names(candidate)) {
        
        if (
          col %in% c(
            "gender",
            "agent_id"
          )
        ) {
          next
        }
        
        if (
          candidate[[col]] ==
          wrong_candidate[[col]]
        ) {
          
          score <- score + 1
          
        }
        
      }
      
      score
      
    }
    
  )
  
  best_match <- which.max(
    similarity_scores
  )
  
  candidates[
    best_match,
  ]
  
}
#' Find a Primary Household Partner
#'
#' Selects the primary adult candidate for household formation.
#'
#' This function is used during both single-adult household
#' generation and couple formation.
#'
#' Candidate agents are selected from the synthetic population
#' using the specified household-position categories and an
#' eligibility mask.
#'
#' Optionally, candidate selection can be restricted to a
#' specific gender.
#'
#' @param object A \code{HouseholdType} object.
#'
#' @param mask Logical vector identifying agents eligible for
#' selection.
#'
#' @param primary_position_value Character vector containing the
#' household-position values that define the primary candidate
#' pool.
#'
#' @param backup_position_values Character vector containing
#' alternative household-position categories that may be used
#' if a suitable candidate cannot be found in the primary pool.
#'
#' @param gender Optional character string specifying the
#' required gender of the candidate.
#'
#' @return A single-row data frame or data.table representing
#' the selected candidate.
#'
#' @details
#' The function:
#'
#' \enumerate{
#'   \item Retrieves all remaining eligible agents in the
#'         specified position categories.
#'   \item Optionally filters candidates by gender.
#'   \item Excludes agents already recorded in
#'         \code{sampled_agents}.
#'   \item Returns the highest-priority candidate.
#' }
#'
#' If no suitable candidate can be found, an error is raised.
#'
#' The current implementation returns the first available
#' candidate after filtering. More sophisticated behaviour may
#' be applied when backup-position replacement logic is enabled.
#'
#' @examples
#' \dontrun{
#'
#' candidate <- findPrimaryPartner(
#'   hh,
#'   mask = rep(
#'     TRUE,
#'     nrow(pop)
#'   ),
#'   primary_position_value =
#'     "SingleAdult",
#'   backup_position_values =
#'     character()
#' )
#'
#' }
#'
#' @seealso
#' \code{\link{findSecondaryPartner}},
#' \code{\link{getRemainingAgentsInPosition}},
#' \code{\link{pair_partners}}
#'
#' @keywords internal
findPrimaryPartner <- function(
    object,
    mask,
    primary_position_value,
    backup_position_values,
    gender = NULL
) {
  
  candidates <- getRemainingAgentsInPosition(
    object,
    primary_position_value,
    mask
  )
  
  # Restrict to requested gender if supplied
  
  if (!is.null(gender)) {
    
    candidates <- candidates[
      candidates$gender == gender,
      ,
      drop = FALSE
    ]
    
  }
  
  # No suitable candidates available
  
  if (nrow(candidates) == 0) {
    
    stop(
      paste(
        "No suitable candidate found",
        if (!is.null(gender))
          paste("for gender", gender)
        else
          ""
      )
    )
    
  }
  
  # Return the first available candidate
  # This matches the initial behaviour
  # of the Python implementation
  
  return(
    candidates[1, , drop = FALSE]
  )
  
}
#' Find a Secondary Household Partner
#'
#' Selects the most suitable partner for a previously selected
#' primary partner.
#'
#' Candidate partners are ranked according to age-gap suitability
#' and filtered according to household-position and gender
#' requirements.
#'
#' This function is used internally by
#' \code{\link{pair_partners}} during couple formation.
#'
#' @param object A \code{HouseholdType} object.
#'
#' @param mask Logical vector identifying agents eligible for
#' partner selection.
#'
#' @param primary_partner Single-row data frame or data.table
#' representing the already-selected primary partner.
#'
#' @param primary_position_value Character vector identifying
#' household-position values eligible for secondary-partner
#' selection.
#'
#' @param backup_position_values Character vector containing
#' alternative household-position categories that may be used
#' when suitable candidates are unavailable in the primary pool.
#'
#' @param gap_start Lower age-gap bound.
#'
#' @param gap_end Upper age-gap bound.
#'
#' @param gender Character string specifying the required gender
#' of the secondary partner.
#'
#' @return A single-row data frame or data.table representing
#' the selected partner.
#'
#' Returns \code{NULL} if no suitable candidate can be found.
#'
#' @details
#' The function:
#'
#' \enumerate{
#'   \item Generates a ranked candidate list using
#'         \code{\link{findCoupleCandidates}}.
#'   \item Restricts candidates to the required gender.
#'   \item Selects the highest-ranked compatible candidate.
#'   \item Returns \code{NULL} if no compatible candidate is
#'         available.
#' }
#'
#' Candidate suitability is determined using:
#'
#' \itemize{
#'   \item Age-gap constraints.
#'   \item Household-position constraints.
#'   \item Availability of agents not already assigned.
#' }
#'
#' More advanced workflows may use backup-position replacement
#' logic via:
#'
#' \itemize{
#'   \item \code{\link{findOppositeGenderReplacementForCandidate}}
#'   \item \code{\link{switchHouseholdPositions}}
#' }
#'
#' @examples
#' \dontrun{
#'
#' secondary_partner <- findSecondaryPartner(
#'   object = hh,
#'   mask = rep(
#'     TRUE,
#'     nrow(pop)
#'   ),
#'   primary_partner = primary_partner,
#'   primary_position_value = "Parent",
#'   backup_position_values = character(),
#'   gap_start = -5,
#'   gap_end = 5,
#'   gender = "Female"
#' )
#'
#' }
#'
#' @seealso
#' \code{\link{findPrimaryPartner}},
#' \code{\link{findCoupleCandidates}},
#' \code{\link{pair_partners}},
#' \code{\link{findOppositeGenderReplacementForCandidate}}
#'
#' @keywords internal
findSecondaryPartner <- function(
    object,
    mask,
    primary_partner,
    primary_position_value,
    backup_position_values,
    gap_start,
    gap_end,
    gender
) {
  
  candidates <- findCoupleCandidates(
    object = object,
    mask = mask,
    position_value = primary_position_value,
    primary_partner = primary_partner,
    gap_start = gap_start,
    gap_end = gap_end
  )
  
  requested_gender <- as.character(gender)
  
  candidate_genders <- as.character(
    candidates[["gender"]]
  )
  
  keep <- candidate_genders == requested_gender
  
  other_gender_candidates <- candidates[
    keep,
  ]

  if (nrow(other_gender_candidates) == 0) {
    
    return(NULL)
    
  }
  
  return(
    other_gender_candidates[1, ]
  )
}
#' Find the Most Suitable Sibling Candidate
#'
#' Selects the most suitable sibling from a candidate pool based
#' on age similarity to one or more already-selected siblings.
#'
#' The suitability of a candidate is evaluated using
#' score_sibling_age_suitability.
#'
#' Candidates with ages closest to the existing sibling ages
#' receive the highest priority.
#'
#' This function is used internally by
#' \code{\link{group_children}} during sibling-group creation.
#'
#' @param pool Data frame or data.table containing candidate
#' children.
#'
#' @param mask Logical vector identifying which children in the
#' pool remain available for selection.
#'
#' @param sibling_ages Numeric vector containing the ages of
#' children already selected for the sibling group.
#'
#' @return A single-row data frame or data.table representing
#' the selected sibling candidate.
#'
#' @details
#' The function:
#'
#' \enumerate{
#'   \item Restricts the candidate pool using \code{mask}.
#'   \item Computes a suitability score for each remaining
#'         candidate.
#'   \item Sorts candidates by suitability.
#'   \item Returns the highest-ranked candidate.
#' }
#'
#' Lower suitability scores indicate better sibling matches.
#'
#' @examples
#' pool <- data.frame(
#'   age = c(
#'     4,
#'     7,
#'     10,
#'     15
#'   )
#' )
#'
#' findSiblingFromPool(
#'   pool,
#'   rep(TRUE, 4),
#'   c(8, 9)
#' )
#'
#' @seealso
#' \code{\link{group_children}},
#'
#' @rdname findSiblingFromPool
#' @keywords internal
#' @noRd
findSiblingFromPool <- function(
    pool,
    mask,
    sibling_ages
) {
  
  candidates <- pool[
    mask,
    ,
    drop = FALSE
  ]
  
  candidates$suitability <-
    sapply(
      candidates$age,
      function(x) {
        
        score_sibling_age_suitability(
          x,
          sibling_ages
        )
        
      }
    )
  
  candidates <-
    candidates[
      order(
        candidates$suitability
      ),
      ,
      drop = FALSE
    ]
  
  candidates[1, , drop = FALSE]
  
}

getHouseholdIds <- function(
    object
) {
  
  names(
    object@households
  )
  
}
#' Retrieve Eligible Unassigned Agents in Household Positions
#'
#' Returns agents occupying one or more specified household
#' positions that have not yet been assigned during household
#' generation.
#'
#' This function is a core candidate-selection utility used
#' throughout the household-generation workflow.
#'
#' Agents are retained only if:
#'
#' \itemize{
#'   \item Their household-position value matches one of the
#'         requested positions.
#'   \item They satisfy the supplied eligibility mask.
#'   \item They do not appear in the
#'         \code{sampled_agents} slot.
#' }
#'
#' @param object A \code{\link{HouseholdType}} object.
#'
#' @param position Character string or character vector
#' identifying eligible household-position values.
#'
#' Examples include:
#'
#' \itemize{
#'   \item \code{"Parent"}
#'   \item \code{"Child"}
#'   \item \code{"SingleAdult"}
#' }
#'
#' @param mask Optional logical vector identifying agents that
#' are currently eligible for selection.
#'
#' If omitted, all agents occupying the specified position
#' categories are considered.
#'
#' @return A data frame or data.table containing the remaining
#' eligible agents.
#'
#' @details
#' The function performs three filtering steps:
#'
#' \enumerate{
#'   \item Identify agents whose household-position values
#'         belong to the specified position categories.
#'   \item Apply the supplied logical mask.
#'   \item Remove agents already assigned and recorded in
#'         \code{sampled_agents}.
#' }
#'
#' This function is used by:
#'
#' \itemize{
#'   \item \code{\link{findPrimaryPartner}}
#'   \item \code{\link{findSecondaryPartner}}
#'   \item \code{\link{pair_partners}}
#' }
#'
#' and provides the candidate pools used by household-matching
#' algorithms.
#'
#' @examples
#' \dontrun{
#'
#' candidates <- getRemainingAgentsInPosition(
#'   hh,
#'   "Parent"
#' )
#'
#' head(candidates)
#'
#' }
#'
#' @examples
#' \dontrun{
#'
#' candidates <- getRemainingAgentsInPosition(
#'   hh,
#'   c(
#'     "Parent",
#'     "SingleAdult"
#'   )
#' )
#'
#' }
#'
#' @examples
#' \dontrun{
#'
#' candidates <- getRemainingAgentsInPosition(
#'   hh,
#'   "Parent",
#'   mask = age > 30
#' )
#'
#' }
#'
#' @seealso
#' \code{\link{findPrimaryPartner}},
#' \code{\link{findSecondaryPartner}},
#' \code{\link{pair_partners}},
#' \code{\link{HouseholdType}}
#'
#' @keywords internal
getRemainingAgentsInPosition <- function( # Make method
    object,
    position,
    mask = NULL
) {
  
  if (is.character(position)) {
    
    position <- c(position)
    
  }
  
  position_mask <-
    
    object@df_synth_pop[[object@household_position_column]] %in% position
  
  if (is.null(mask)) {
    
    mask <- position_mask
    
  } else {
    
    mask <- mask &
      position_mask
    
  }
  
  maskWithRemainingAgents(
    object,
    object@df_synth_pop,
    mask
  )
  
}
#' Group Children into Sibling Sets
#'
#' Creates sibling groups from eligible children within a
#' synthetic population.
#'
#' Children are grouped according to the child-position
#' specification stored in a \code{HouseholdType} object.
#'
#' The algorithm:
#'
#' \itemize{
#'   \item Identifies all eligible children.
#'   \item Randomises the candidate pool to avoid systematic
#'         ordering effects.
#'   \item Selects an initial child.
#'   \item Iteratively finds the most age-similar sibling using
#'         findSiblingFromPool.
#'   \item Creates sibling groups of the required size.
#'   \item Marks assigned children as unavailable for future
#'         household generation.
#' }
#'
#' This method is typically called indirectly through
#' \code{\link{createFromMembers}} during household generation.
#'
#' @param object A \code{HouseholdType} object.
#'
#' @param mask Logical vector identifying agents eligible for
#' child grouping.
#'
#' @param child_position Position definition returned by
#' \code{\link{getPositionForName}} for the \code{"child"}
#' role.
#'
#' @return A list of sibling groups.
#'
#' Each sibling group is represented as a character vector of
#' agent identifiers.
#'
#' The updated \code{HouseholdType} object is attached as:
#'
#' \preformatted{
#' attr(result, "object")
#' }
#'
#' @details
#' The number of children per sibling group is determined by
#' the \code{amount} element of the child-position definition.
#'
#' Children are assigned exactly once. Assigned children are
#' recorded in \code{sampled_agents} and removed from the pool
#' of eligible children.
#'
#' Age similarity between children is evaluated using
#' score_sibling_age_suitability.
#'
#' @examples
#' \dontrun{
#'
#' child_position <- getPositionForName(
#'   hh,
#'   "child"
#' )
#'
#' groups <- group_children(
#'   hh,
#'   mask = rep(
#'     TRUE,
#'     nrow(pop)
#'   ),
#'   child_position = child_position
#' )
#'
#' groups
#'
#' }
#'
#' @seealso
#' \code{\link{matchAdultsWithChildren}},
#' \code{\link{createFromMembers}},
#' \code{\link{HouseholdType}}
#'
#' @export
group_children <- function(
    object,
    mask,
    child_position
) {
  
  position <- child_position$position
  
  n_children <- child_position$amount
  
  households <- list()
  
  pool <- object@df_synth_pop[
    
    object@df_synth_pop[[object@household_position_column]] %in% position & mask,
    
  ]
  
  if (nrow(pool) == 0) {
    
    attr(households, "object") <- object
    
    return(households)
    
  }
  
  # Randomise order to mirror Python sample(frac=1)
  
  pool <- pool[
    sample(
      seq_len(nrow(pool))
    ),
  ]
  
  pool_mask <- rep(
    TRUE,
    nrow(pool)
  )
  
  while (sum(pool_mask) > 0) {
    
    first_child <- pool[
      which(pool_mask)[1],
    ]
    
    object@sampled_agents <- c(
      object@sampled_agents,
      first_child$agent_id
    )
    
    children <- c(
      first_child$agent_id
    )
    
    sibling_ages <- c(
      first_child$age
    )
    
    pool_mask[
      pool$agent_id ==
        first_child$agent_id
    ] <- FALSE
    
    for (i in seq_len(
      n_children - 1
    )) {
      
      if (sum(pool_mask) == 0) {
        break
      }
      
      sibling <-
        findSiblingFromPool(
          pool,
          pool_mask,
          sibling_ages
        )
      
      children <- c(
        children,
        sibling$agent_id
      )
      
      sibling_ages <- c(
        sibling_ages,
        sibling$age
      )
      
      pool_mask[
        pool$agent_id ==
          sibling$agent_id
      ] <- FALSE
      
      object@sampled_agents <- c(
        object@sampled_agents,
        sibling$agent_id
      )
      
    }
    
    # households[[length(households) + 1]] <- list(children)
    households[[length(households)+1]] <- children
    
  }
  
  attr(
    households,
    "object"
  ) <- object
  
  households
  
}

#' Match Adult Groups to Child Groups
#'
#' Creates family households by matching adult household groups
#' to sibling groups according to a parent-child age-gap
#' distribution.
#'
#' This function is the final family-construction stage of the
#' household-generation workflow and is typically called
#' indirectly via \code{\link{createFromMembers}}.
#'
#' The algorithm:
#'
#' \enumerate{
#'   \item Calculates representative ages for parent groups.
#'   \item Determines the age of the oldest child in each
#'         sibling group.
#'   \item Evaluates parent-child compatibility using the
#'         configured parent-child age-gap distribution.
#'   \item Selects the most suitable parent group for each
#'         child group.
#'   \item Creates family households.
#'   \item Creates childless households for any remaining
#'         unmatched adult groups.
#' }
#'
#' @param object A \code{HouseholdType} object.
#'
#' @param parents List of adult groups generated by
#' createSingles() or \code{\link{pair_partners}}.
#'
#' @param children List of sibling groups generated by
#' \code{\link{group_children}}.
#'
#' @param id_offset Integer household identifier offset used
#' when generating unique household IDs.
#'
#' @return A list containing:
#'
#' \describe{
#'   \item{object}{
#'     Updated \code{HouseholdType} object containing newly
#'     created household records.
#'   }
#'   \item{id_offset}{
#'     Updated household identifier offset.
#'   }
#' }
#'
#' @details
#' Parent-child compatibility is determined using
#' \code{parent_child_age_distribution}.
#'
#' Child groups are processed in descending order of oldest
#' child age.
#'
#' Parent suitability is evaluated using
#' score_suitability_by_age_disparity.
#'
#' A minimum age difference between parents and children is
#' enforced through the \code{strict_lower_bound} mechanism.
#'
#' The oldest child in each sibling group is used when
#' evaluating candidate parent groups.
#'
#' Parent groups that cannot be matched to any child group are
#' converted into childless households.
#'
#' Household records are created using
#' \code{\link{create_household_with_id}}.
#'
#' @examples
#' \dontrun{
#'
#' result <- matchAdultsWithChildren(
#'   object = hh,
#'   parents = parents,
#'   children = children,
#'   id_offset = 1
#' )
#'
#' names(result$object@households)
#'
#' }
#'
#' @seealso
#' \code{\link{pair_partners}},
#' \code{\link{group_children}},
#' \code{\link{create_household_with_id}},
#' \code{\link{HouseholdType}}
#'
#' @keywords internal
matchAdultsWithChildren <- function(
    object,
    parents,
    children,
    id_offset
) {
  
  age_mother <- calculate_group_counts(
    object@parent_child_age_distribution,
    length(children)
  )
  
  #
  # Determine representative parent ages
  #
  
  parent_ages <- c()
  
  if (
    getPositionForName(
      object,
      "adult"
    )$amount == 2
  ) {
    
    # Two-parent household
    
    for (parent_pair in parents) {
      
      p1 <- parent_pair[[1]]
      p2 <- parent_pair[[2]]
      
      parent_ages <- c(
        parent_ages,
        min(
          as.numeric(p1[2]),
          as.numeric(p2[2])
        )
      )
      
    }
    
  } else {
    
    # Single-parent household
    
    for (parent in parents) {
      
      parent_ages <- c(
        parent_ages,
        as.numeric(
          parent[[1]][2]
        )
      )
      
    }
    
  }
  children_with_ages <- lapply(
    
    children,
    
    function(child_group) {
      
      oldest_child_age <- max(
        
        object@df_synth_pop[
          agent_id %in% child_group,
          age
        ]
        
      )
      
      list(
        children = child_group,
        age = oldest_child_age
      )
      
    }
    
  )
  
  children_with_ages <-
    
    children_with_ages[
      order(
        sapply(
          children_with_ages,
          function(x) x$age
        ),
        decreasing = TRUE
      )
    ]
  
  available_parents <- seq_along(
    parent_ages
  )
  
  child_offset <- 1
  for (age_gap in names(age_mother)) {
    
    count <- age_mother[[age_gap]]
    
    bounds <- parse_age_gap(
      age_gap
    )
    
    gap_start <- as.numeric(
      bounds["lower"]
    )
    
    gap_end <- as.numeric(
      bounds["upper"]
    )
    
    for (i in seq_len(count)) {
      
      if (
        child_offset >
        length(children_with_ages)
      ) {
        break
      }
      
      child_group <-
        children_with_ages[[child_offset]]
      
      child_age <-
        child_group$age
      scores <- sapply(
        
        available_parents,
        
        function(idx) {
          
          score_suitability_by_age_disparity(
            
            partner_age =
              parent_ages[idx],
            
            age_start =
              child_age +
              gap_start,
            
            age_end =
              child_age +
              gap_end,
            
            strict_lower_bound =
              child_age + 14
            
          )
          
        }
        
      )
      
      selected_parent <-
        available_parents[
          which.min(scores)
        ]
      
      parent_group <-
        parents[[selected_parent]]
      ##
      adult_ids <- c()
      
      for (parent in parent_group) {
        
        adult_ids <- c(
          adult_ids,
          parent[1]
        )
        
      }
      
      child_ids <- child_group$children
      
      object <- createFamilyHouseholdWithId(
        object,
        id_offset,
        adult_ids,
        child_ids
      )
      ##
      available_parents <-
        setdiff(
          available_parents,
          selected_parent
        )
      
      id_offset <- id_offset + 1
      
      child_offset <- child_offset + 1
      
    }
    
  }
  if (
    length(available_parents) > 0
  ) {
    
    adult_position <- getPositionForName(
      object,
      "adult"
    )
    
    for (idx in available_parents) {
      
      parent_group <- parents[[idx]]
      
      household_agents <- c()
      
      for (parent in parent_group) {
        
        household_agents <- c(
          household_agents,
          parent[1]
        )
        
      }
      
      object <- create_household_with_id(
        object,
        adult_position,
        id_offset,
        household_agents
      )
      
      id_offset <- id_offset + 1
      
    }
    
  }
  list(
    object = object,
    id_offset = id_offset
  )
  
}
#' Create Couples from Eligible Adults
#'
#' Forms couples from eligible adults according to household
#' structure definitions, gender distributions and age-gap
#' distributions.
#'
#' This function is one of the core household-generation
#' algorithms in replica and is typically called
#' indirectly via \code{\link{createFromMembers}}.
#'
#' Couples are created by:
#'
#' \enumerate{
#'   \item Determining the required number of couples.
#'   \item Allocating couples according to the specified
#'         gender-distribution constraints.
#'   \item Allocating partner age gaps according to the
#'         specified age-gap distribution.
#'   \item Selecting a primary partner.
#'   \item Selecting the best available secondary partner.
#'   \item Recording assigned agents in
#'         \code{sampled_agents}.
#' }
#'
#' @param object A \code{HouseholdType} object.
#'
#' @param group_mask Logical vector identifying agents eligible
#' for couple formation.
#'
#' @return A list of couples.
#'
#' Each couple is represented as:
#'
#' \preformatted{
#' list(
#'   c(agent_id, age, gender),
#'   c(agent_id, age, gender)
#' )
#' }
#'
#' The updated \code{HouseholdType} object is attached as:
#'
#' \preformatted{
#' attr(result, "object")
#' }
#'
#' @details
#' Couple composition is controlled by:
#'
#' \itemize{
#'   \item \code{couple_gender_distribution}
#'   \item \code{couple_age_distribution}
#' }
#'
#' Age-gap specifications are interpreted using
#' \code{\link{parse_age_gap}}.
#'
#' Candidate partners are selected using:
#'
#' \itemize{
#'   \item \code{\link{findPrimaryPartner}}
#'   \item \code{\link{findSecondaryPartner}}
#'   \item \code{\link{findCoupleCandidates}}
#' }
#'
#' Agents assigned to a couple are added to the
#' \code{sampled_agents} slot to prevent subsequent
#' reassignment.
#'
#' @examples
#' \dontrun{
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
#' couples <- pair_partners(
#'   hh,
#'   rep(TRUE, nrow(pop))
#' )
#'
#' }
#'
#' @seealso
#' \code{\link{findPrimaryPartner}},
#' \code{\link{findSecondaryPartner}},
#' \code{\link{findCoupleCandidates}},
#' \code{\link{parse_age_gap}},
#' \code{\link{createFromMembers}},
#' \code{\link{HouseholdType}}
#'
#' @export
pair_partners <- function(
    object,
    group_mask
) {
  
  adult_mask <- group_mask &
    getBaseAdultMask(object)
  
  parent_position <- getPositionForName(
    object,
    "adult"
  )
  
  n_couples <- ceiling(
    sum(adult_mask) /
      parent_position$amount
  )
  
  gender_counts <- calculate_group_counts(
    object@couple_gender_distribution,
    n_couples
  )
  
  couples <- list()
  
  couple_idx <- 1
  
  for (pair_name in names(gender_counts)) {
    
    count <- gender_counts[[pair_name]]
    
    pair_parts <- strsplit(
      pair_name,
      "\\|"
    )[[1]]
    
    first_gender <- pair_parts[1]
    second_gender <- pair_parts[2]
    
    age_gap_counts <- calculate_group_counts(
      object@couple_age_distribution,
      count
    )
    
    for (gap_name in names(age_gap_counts)) {
      
      gap_count <- age_gap_counts[[gap_name]]
      
      gap <- parse_age_gap(
        gap_name
      )
      
      gap_start <- as.numeric(
        gap["lower"]
      )
      
      gap_end <- as.numeric(
        gap["upper"]
      )
      
      for (i in seq_len(gap_count)) {
        
        primary_partner <-
          findPrimaryPartner(
            object,
            group_mask,
            parent_position$position,
            parent_position$backup_position_identifiers,
            first_gender
          )
        
        object@sampled_agents <- c(
          object@sampled_agents,
          primary_partner$agent_id
        )
        
        secondary_partner <-
          findSecondaryPartner(
            object = object,
            mask = group_mask,
            primary_partner = primary_partner,
            primary_position_value =
              parent_position$position,
            backup_position_values =
              parent_position$backup_position_identifiers,
            gap_start = gap_start,
            gap_end = gap_end,
            gender = second_gender
          )
        
        if (is.null(secondary_partner)) {
          
          next
          
        }
        
        object@sampled_agents <- c(
          object@sampled_agents,
          secondary_partner$agent_id
        )
        
        couples[[couple_idx]] <- list(
          
          c(
            primary_partner$agent_id,
            primary_partner$age,
            primary_partner$gender
          ),
          
          c(
            secondary_partner$agent_id,
            secondary_partner$age,
            secondary_partner$gender
          )
          
        )
        
        couple_idx <- couple_idx + 1
        
      }
      
    }
    
  }
  
  attr(
    couples,
    "object"
  ) <- object
  
  couples
  
}
#' Parse an Age-Gap Specification
#'
#' Converts an age-gap specification into numeric lower and
#' upper bounds.
#'
#' Age-gap specifications are used throughout the household
#' generation workflow to define acceptable age differences
#' between:
#'
#' \itemize{
#'   \item Partners.
#'   \item Parents and children.
#' }
#'
#' Supported formats include:
#'
#' \preformatted{
#' "20-30"
#' "-5-5"
#' "-10--5"
#' "-10-5"
#' }
#'
#' @param age_gap Character string specifying an age-gap range.
#'
#' @return A named numeric vector containing:
#'
#' \describe{
#'   \item{lower}{
#'     Lower age-gap bound.
#'   }
#'   \item{upper}{
#'     Upper age-gap bound.
#'   }
#' }
#'
#' @details
#' Positive values indicate that the comparison individual is
#' expected to be older.
#'
#' Negative values indicate that the comparison individual is
#' expected to be younger.
#'
#' Examples:
#'
#' \describe{
#'   \item{\code{"20-30"}}{
#'     Parent should be between 20 and 30 years older than the
#'     child.
#'   }
#'
#'   \item{\code{"-5-5"}}{
#'     Partner may be up to 5 years younger or 5 years older.
#'   }
#'
#'   \item{\code{"-10--5"}}{
#'     Partner should be between 5 and 10 years younger.
#'   }
#'
#'   \item{\code{"-10-5"}}{
#'     Partner may be up to 10 years younger or up to 5 years
#'     older.
#'   }
#' }
#'
#' Invalid age-gap strings generate an error.
#'
#' @examples
#' parse_age_gap("20-30")
#'
#' parse_age_gap("-5-5")
#'
#' parse_age_gap("-10--5")
#'
#' parse_age_gap("-10-5")
#'
#' @seealso
#' \code{\link{pair_partners}},
#' \code{\link{matchAdultsWithChildren}},
#' \code{\link{calculate_age_range_from_gap}}
#'
#' @export
parse_age_gap <- function(
    age_gap
) {
  
  parts <- regmatches(
    age_gap,
    regexec(
      "^(-?\\d+)-(-?\\d+)$",
      age_gap
    )
  )[[1]]
  
  if (length(parts) != 3) {
    
    stop(
      paste(
        "Unable to parse age gap:",
        age_gap
      )
    )
    
  }
  
  c(
    lower = as.numeric(parts[2]),
    upper = as.numeric(parts[3])
  )
  
}

#' Calculate Sibling Age Suitability
#'
#' Computes a suitability score for a candidate sibling based on
#' the ages of one or more existing siblings.
#'
#' Lower scores indicate a closer age match and therefore a more
#' suitable sibling candidate.
#'
#' This function is used internally by
#' findSiblingFromPool during sibling-group
#' construction.
#'
#' @param age Numeric age of the candidate sibling.
#'
#' @param reference_ages Numeric vector containing the ages of
#' siblings already assigned to the sibling group.
#'
#' @return A numeric suitability score.
#'
#' @details
#' If the candidate age exactly matches one of the reference
#' ages, a score of \code{10} is returned.
#'
#' Otherwise, the score is the minimum absolute age difference
#' between the candidate and any reference age.
#'
#' Lower scores correspond to stronger sibling similarity.
#'
#' @examples
#' \dontrun{
#' score_sibling_age_suitability(
#'   age = 10,
#'   reference_ages = c(
#'     8,
#'     12
#'   )
#' )
#'
#' score_sibling_age_suitability(
#'   age = 15,
#'   reference_ages = c(
#'     8,
#'     12
#'   )
#' )
#' }
#'
#' @seealso
#' \code{\link{group_children}}
#'
#' @keywords internal
score_sibling_age_suitability <- function(
    age,
    reference_ages
) {
  
  if (age %in% reference_ages) {
    
    return(10)
    
  }
  
  min(
    abs(
      age - reference_ages
    )
  )
  
}
#' Score Candidate Suitability by Age Disparity
#'
#' Calculates a suitability score based on how closely a
#' candidate's age matches a desired age range.
#'
#' Lower scores indicate better matches.
#'
#' A score of zero indicates that the candidate age falls
#' within the desired age interval.
#'
#' This function is used throughout the household-generation
#' workflow when matching:
#'
#' \itemize{
#'   \item Partners.
#'   \item Parents and children.
#' }
#'
#' @param partner_age Numeric age of the candidate being
#' evaluated.
#'
#' @param age_start Numeric lower bound of the preferred age
#' range.
#'
#' @param age_end Numeric upper bound of the preferred age
#' range.
#'
#' @param strict_lower_bound Optional numeric minimum acceptable
#' age.
#'
#' Candidates below this age receive a large penalty to prevent
#' biologically implausible matches.
#'
#' @return A numeric suitability score.
#'
#' @details
#' Suitability is calculated as follows:
#'
#' \describe{
#'   \item{Within Range}{
#'     Returns \code{0}.
#'   }
#'
#'   \item{Below Range}{
#'     Returns the number of years below the lower bound.
#'   }
#'
#'   \item{Above Range}{
#'     Returns the number of years above the upper bound.
#'   }
#' }
#'
#' If \code{strict_lower_bound} is supplied and the candidate
#' falls below that value, an additional penalty of
#' \code{999} is added.
#'
#' This penalty mechanism is used by the parent-child matching
#' workflow to discourage unrealistic parent-child age
#' combinations.
#'
#' @examples
#' # Candidate inside preferred range
#' \dontrun{
#' score_suitability_by_age_disparity(
#'   partner_age = 30,
#'   age_start = 25,
#'   age_end = 35
#' )
#' }
#'
#' @examples
#' # Candidate too young
#' \dontrun{
#' score_suitability_by_age_disparity(
#'   partner_age = 20,
#'   age_start = 25,
#'   age_end = 35
#' )
#' }
#'
#' @examples
#' # Candidate too old
#' \dontrun{
#' score_suitability_by_age_disparity(
#'   partner_age = 40,
#'   age_start = 25,
#'   age_end = 35
#' )
#' }
#'
#' @examples
#' # Candidate violates strict lower bound
#' \dontrun{
#' score_suitability_by_age_disparity(
#'   partner_age = 12,
#'   age_start = 20,
#'   age_end = 25,
#'   strict_lower_bound = 14
#' )
#' }
#'
#' @seealso
#' \code{\link{calculate_age_range_from_gap}},
#' \code{\link{findCoupleCandidates}},
#' \code{\link{findSecondaryPartner}},
#' \code{\link{pair_partners}},
#' \code{\link{matchAdultsWithChildren}}
#'
#' @keywords internal
score_suitability_by_age_disparity <- function(
    partner_age,
    age_start,
    age_end,
    strict_lower_bound = NULL
) {
  
  if (partner_age >= age_start &&
      partner_age <= age_end) {
    
    return(0)
  }
  
  if (partner_age < age_start) {
    
    diff <- age_start - partner_age
    
    if (!is.null(strict_lower_bound) &&
        partner_age < strict_lower_bound) {
      
      diff <- diff + 999
    }
    
    return(diff)
  }
  
  partner_age - age_end
}
#' Exchange Household Positions Between Agents
#'
#' Swaps household-position classifications between two agents
#' in a synthetic population.
#'
#' This function supports fallback partner-matching logic in
#' replica when suitable candidates are unavailable within the
#' preferred household-position pool.
#'
#' @param object A \code{\link{HouseholdType}} object.
#'
#' @param agent_1 Identifier of the first agent.
#'
#' @param agent_2 Identifier of the second agent.
#'
#' @return An updated \code{\link{HouseholdType}} object.
#'
#' @details
#' The function:
#'
#' \enumerate{
#'   \item Retrieves both agents.
#'   \item Exchanges their household-position values.
#'   \item Updates the stored synthetic population.
#' }
#'
#' Both agents must belong to the same neighbourhood.
#'
#' @examples
#' \dontrun{
#' hh <- switchHouseholdPositions(
#'   hh,
#'   "A001",
#'   "A002"
#' )
#' }
#'
#' @seealso
#' \code{\link{findOppositeGenderReplacementForCandidate}}
#'
#' @keywords internal
switchHouseholdPositions <- function(
    object,
    agent_1,
    agent_2
) {
  
  dt <- data.table::copy(
    object@df_synth_pop
  )
  
  a1 <- dt[
    agent_id == agent_1,
  ]
  
  a2 <- dt[
    agent_id == agent_2,
  ]
  
  if (nrow(a1) == 0) {
    
    stop(
      paste(
        "Agent not found:",
        agent_1
      )
    )
    
  }
  
  if (nrow(a2) == 0) {
    
    stop(
      paste(
        "Agent not found:",
        agent_2
      )
    )
    
  }
  
  # Match Python behaviour:
  # both agents must belong to same neighbourhood
  
  if (
    a1$neighb_code !=
    a2$neighb_code
  ) {
    
    stop(
      "Agents belong to different neighbourhoods"
    )
    
  }
  
  pos1 <- a1[[object@household_position_column]]
  
  pos2 <- a2[[object@household_position_column]]
  
  dt[agent_id == agent_1, (object@household_position_column) := pos2]
  
  dt[
    agent_id == agent_2,
    (object@household_position_column) := pos1
  ]
  
  object@df_synth_pop <- dt
  
  object
  
}
