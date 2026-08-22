extract_assigned_children <- function(
    updated_hh
) {
  
  sort(
    updated_hh@assigned_agents
  )
  
}
extract_gender_pairs <- function(
    couples
) {
  
  sapply(
    
    couples,
    
    function(couple) {
      
      paste(
        couple[[1]][3],
        couple[[2]][3],
        sep = "-"
      )
      
    }
    
  )
  
}
extract_group_sizes <- function(
    groups
) {
  
  sapply(
    groups,
    length
  )
  
}
extract_household_size_distribution <- function(
    households, column = "household_size"
) {
  
  sort(
    households[[column]]
  )
  
}
extract_household_sizes <- function(
    households
) {
  
  sapply(
    households,
    function(x)
      length(x$all)
  )
  
}
extract_household_type_distribution <- function(
    households, column = "household_type"
) {
  
  sort(
    table(
      households[[column]]
    )
  )
  
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
#' \code{pair_partners}.
#'
#' @param object A \code{ReplicaStructure} object.
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
#'         \code{assigned_agents}.
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
      object@population[[object@position_column]] %in% position_value
    )
  
  # Exclude agents already assigned elsewhere
  
  mask <- mask &
    !(
      object@population$agent_id %in%
        object@assigned_agents
    )
  
  candidates <- object@population[
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
#' @param object A \code{\link{ReplicaStructure}} object.
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
  
  dt <- object@population
  
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
    (dt[[object@position_column]] == position) &
    (dt$gender != wrong_gender) &
    !(dt$agent_id %in% object@assigned_agents)
  
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
#' @param object A \code{ReplicaStructure} object.
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
#'         \code{assigned_agents}.
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
#' \code{\link{getRemainingAgentsInPosition}}
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
    
    requested_gender <- gender
    
    candidates <- candidates[
      candidates[["gender"]] ==
        requested_gender
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
#' \code{pair_partners} during couple formation.
#'
#' @param object A \code{ReplicaStructure} object.
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
#' \code{group_children} during sibling-group creation.
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

#' Extract Conditional Fractions for a Target Attribute
#'
#' Computes and extracts conditional fractions from a
#' contingency table for use during attribute assignment.
#'
#' The function converts contingency-table counts into
#' conditional probabilities using
#' \code{\link{calculate_fractions}} and returns the resulting
#' fractions indexed by the target attribute and any relevant
#' margin variables.
#'
#' This function is used internally by
#' \code{\link{enhance}} during conditional attribute assignment.
#'
#' @param object A \code{\link{ReplicaAdder}}
#' object.
#'
#' @param dt A contingency table containing the target
#' attribute and a \code{count} column.
#'
#' @return A data frame or data.table containing:
#'
#' \itemize{
#'   \item The target attribute.
#'   \item Any relevant margin variables.
#'   \item A \code{fraction} column.
#' }
#'
#' @details
#' Fractions are calculated separately within each
#' conditioning group.
#'
#' The result is subsequently used by:
#'
#' \itemize{
#'   \item \code{\link{calculate_group_counts}}
#'   \item \code{\link{enhance}}
#' }
#'
#' If margin constraints have been supplied using
#' \code{\link{renew}}, the returned table will also
#' include the corresponding margin variables.
#'
#' The function automatically removes duplicate index names
#' when margins overlap with the target attribute.
#'
#' @examples
#' \dontrun{
#'
#' fractions <- getGroupFractions(
#'   adder,
#'   contingency_group
#' )
#'
#' fractions
#'
#' }
#'
#' @examples
#' \dontrun{
#'
#' # Typical output
#'
#' # education fraction
#' # Degree      0.45
#' # Diploma     0.25
#' # School      0.30
#'
#' }
#'
#' @seealso
#' \code{\link{calculate_fractions}},
#' \code{\link{calculate_group_counts}},
#' \code{\link{ReplicaAdder}},
#' \code{\link{enhance}}
#'
#' @keywords internal
getGroupFractions <- function(
    object,
    dt
) {
  
  dt <- calculate_fractions(
    dt,
    object@group_by,
    object@target_attribute,
    object@margins_group
  )
  
  idx <- object@target_attribute
  
  if (length(object@margins_names) > 0) {
    
    idx <- unique(
      c(
        idx,
        unlist(
          object@margins_names
        )
      )
    )
  }
  
  dt[
    ,
    c(idx, "fraction"),
    with = FALSE
  ]
}
getHouseholdIds <- function(
    object
) {
  
  names(
    object@households
  )
  
}


#' Generate Multiple Margin Tables from a Synthetic Population
#'
#' Creates a collection of marginal distributions from a
#' synthetic population.
#'
#' This function is useful when multiple margin tables are
#' required for:
#'
#' \itemize{
#'   \item Validation.
#'   \item Iterative proportional fitting (IPF).
#'   \item Statistical reporting.
#' }
#'
#' @param population A synthetic population stored as
#' a data.frame or \code{data.table}.
#'
#' @param margins List of variable names defining the
#' requested margins.
#'
#' Each list entry specifies the variables that will be
#' aggregated together.
#'
#' @return A list of margin tables.
#'
#' @details
#' For each entry in \code{margin_names}, the function computes
#' the corresponding marginal distribution and returns the
#' collection as a named list.
#'
#' This utility is commonly used when preparing inputs for IPF
#' workflows and validating synthetic populations against known
#' marginals.
#'
#' @examples
#' \dontrun{
#'
#' margins <- get_margin_frames_from_synthetic_population(
#'   population,
#'   list(
#'     "gender",
#'     "age_group"
#'   )
#' )
#'
#' }
#'
#' @seealso
#' \code{\link{get_margin_series_from_synthetic_population}},
#' \code{\link{ReplicaAdder}}
#'
#' @export
get_margin_frames_from_synthetic_population <- function(
    population,
    margins
) {
  
  setNames(
    lapply(
      margins,
      function(names_vec) {
        
        transform_to_contingency(
          population,
          columns = names_vec,
          full_crosstab = length(names_vec) > 1
        )
        
      }
    ),
    vapply(
      margins,
      paste,
      collapse = "|",
      FUN.VALUE = character(1)
    )
  )
}

#' Extract a Margin Distribution from a Synthetic Population
#'
#' Calculates a marginal distribution for one or more variables
#' in a synthetic population.
#'
#' The resulting margin can be used for:
#'
#' \itemize{
#'   \item Validation.
#'   \item Comparison with external data sources.
#'   \item Iterative proportional fitting (IPF).
#'   \item Diagnostic reporting.
#' }
#'
#' @param population A synthetic population stored as
#' a data.frame or \code{data.table}.
#'
#' @param margins Character vector identifying the
#' variables that define the margin.
#'
#' @return A data frame containing the requested grouping
#' variables and a \code{count} column.
#'
#' @details
#' The function aggregates the synthetic population over the
#' supplied variables and counts the number of agents in each
#' resulting category.
#'
#' Unlike
#' \code{\link{transform_to_contingency}},
#' this function is intended specifically for marginal
#' distributions rather than higher-dimensional contingency
#' tables.
#'
#' @examples
#' population <- data.frame(
#'   gender = c(
#'     "Male",
#'     "Male",
#'     "Female"
#'   )
#' )
#'
#' get_margin_series_from_synthetic_population(
#'   population,
#'   "gender"
#' )
#'
#' @seealso
#' \code{\link{get_margin_frames_from_synthetic_population}},
#' \code{\link{transform_to_contingency}}
#'
#' @export
get_margin_series_from_synthetic_population <- function(
    population,
    margins
) {
  
  results <- list()
  
  for (names_vec in margins) {
    
    key <- paste(names_vec,
                 collapse = "|")
    
    contingency <-
      transform_to_contingency(
        population,
        names_vec,
        full_crosstab =
          length(names_vec) > 1
      )
    
    results[[key]] <-
      contingency$count
  }
  
  results
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
#'         \code{assigned_agents} slot.
#' }
#'
#' @param object A \code{\link{ReplicaStructure}} object.
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
#'         \code{assigned_agents}.
#' }
#'
#' This function is used by:
#'
#' \itemize{
#'   \item \code{\link{findPrimaryPartner}}
#'   \item \code{\link{findSecondaryPartner}}
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
#' \code{\link{ReplicaStructure}}
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
    
    object@population[[object@position_column]] %in% position
  
  if (is.null(mask)) {
    
    mask <- position_mask
    
  } else {
    
    mask <- mask &
      position_mask
    
  }
  
  maskWithRemainingAgents(
    object,
    object@population,
    mask
  )
  
}
get_validation_structure <- function(
    validation_result
) {
  
  details <- validation_result$details
  
  metric_columns <- c(
    "count_x",
    "count_y",
    "observed_pct",
    "expected_pct",
    "difference_pct"
  )
  
  dimensions <- setdiff(
    names(details),
    metric_columns
  )
  
  outcome_variable <- utils::tail(
    dimensions,
    1
  )
  
  conditioning_variables <- utils::head(
    dimensions,
    -1
  )
  
  list(
    details = details,
    dimensions = dimensions,
    outcome_variable = outcome_variable,
    conditioning_variables =
      conditioning_variables
  )
  
}
