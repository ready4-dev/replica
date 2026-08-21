createFamilyHouseholdWithId <- function(
    object,
    id_offset,
    adult_ids,
    child_ids
) {
  
  household_id <- sprintf(
    "SSH%06d",
    id_offset
  )
  
  household <- list(
    
    all = c(
      adult_ids,
      child_ids
    ),
    
    adult = adult_ids,
    
    child = child_ids
    
  )
  
  object@households[[household_id]] <- household
  
  object
  
}
#' Create a Household Record and Assign a Household Identifier
#'
#' Creates a new synthetic household and stores it within a
#' \code{ReplicaStructure} object.
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
#'   \item \code{pair_partners}
#'   \item \code{\link{matchAdultsWithChildren}}
#' }
#'
#' @param object A \code{ReplicaStructure} object.
#'
#' @param position Household-position definition returned by
#' \code{getPositionForName}.
#'
#' @param id_offset Integer offset used to generate a unique
#' household identifier.
#'
#' @param agents Character vector containing the agent IDs that
#' belong to the household.
#'
#' @return An updated \code{ReplicaStructure} object containing the
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
#' hh <- ReplicaStructure(
#'   "CoupleOnly"
#' )
#'
#' hh <- renew(
#'   hh,
#'   what = "positions",
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
#' \code{\link{matchAdultsWithChildren}},
#' \code{\link{ReplicaStructure}}
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
create_table_row <- function(
    combined_data,
    target_attribute,
    jointed_over
) {
  
  zres <-
    calculate_z_squared_score(
      combined_data
    )
  
  gof <-
    calculate_goodness_of_fit(
      combined_data
    )
  
  data.frame(
    TargetAttribute =
      target_attribute,
    
    JointDistribution =
      jointed_over,
    
    DoF = zres$dof,
    
    ZSquare =
      zres$z_square,
    
    ZPValue =
      zres$p,
    
    XSquare =
      gof$score,
    
    XPValue =
      gof$p,
    
    TAE =
      total_absolute_error(
        combined_data
      ),
    
    SAE =
      standardised_absolute_error(
        combined_data
      )
  )
}
getGroupMask <- function(
    df,
    group_name,
    group_by
) {
  
  mask <- rep(TRUE, nrow(df))
  
  if (length(group_by) == 0) {
    return(mask)
  }
  
  for (i in seq_along(group_by)) {
    
    attr <- group_by[i]
    
    if (attr %in% names(df)) {
      
      mask <- mask &
        (df[[attr]] == group_name[i])
      
    }
  }
  
  mask
}

#' Group Children into Sibling Sets
#'
#' Creates sibling groups from eligible children within a
#' synthetic population.
#'
#' Children are grouped according to the child-position
#' specification stored in a \code{ReplicaStructure} object.
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
#' \code{createFromMembers} during household generation.
#'
#' @param object A \code{ReplicaStructure} object.
#'
#' @param mask Logical vector identifying agents eligible for
#' child grouping.
#'
#' @param child_position Position definition returned by
#' \code{getPositionForName} for the \code{"child"}
#' role.
#'
#' @return A list of sibling groups.
#'
#' Each sibling group is represented as a character vector of
#' agent identifiers.
#'
#' The updated \code{ReplicaStructure} object is attached as:
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
#' \code{\link{ReplicaStructure}}
#' @keywords internal
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
#' Create Synthetic Agents From Aggregate Counts
#'
#' Expands a marginal distribution or contingency table into an
#' agent-level synthetic population.
#'
#' Each row of the input table is replicated according to its
#' count value, generating one row per synthetic agent.
#'
#' @param counts A data frame or data.table containing one or
#'   more attribute columns and a count column.
#' @param count_col Name of the count column.
#' @param agent_id_col Name of the generated agent identifier
#'   column.
#' @param prefix Prefix used when generating agent identifiers.
#'
#' @return A data.table containing one row per synthetic
#'   agent.
#'
#' @examples
#' age_margin <- data.frame(
#'   age_group = c(
#'     "0-17",
#'     "18-64"
#'   ),
#'   count = c(
#'     2,
#'     3
#'   )
#' )
#'
#' make_agents(
#'   age_margin
#' )
#'
#' @export
make_agents <- function(
    counts,
    count_col = "count",
    agent_id_col = "agent_id",
    prefix = "Agent_"
) {
  
  counts <-
    data.table::as.data.table(
      counts
    )
  
  if (
    !(count_col %in% names(counts))
  ) {
    
    stop(
      sprintf(
        "Column '%s' not found.",
        count_col
      )
    )
    
  }
  
  if (
    any(
      is.na(
        counts[[count_col]]
      )
    )
  ) {
    
    stop(
      sprintf(
        "Column '%s' contains missing values.",
        count_col
      )
    )
    
  }
  
  if (
    any(
      counts[[count_col]] < 0
    )
  ) {
    
    stop(
      sprintf(
        "Column '%s' contains negative values.",
        count_col
      )
    )
    
  }
  
  if (
    any(
      counts[[count_col]] !=
      floor(
        counts[[count_col]]
      )
    )
  ) {
    
    stop(
      sprintf(
        "Column '%s' must contain integer counts.",
        count_col
      )
    )
    
  }
  
  attribute_cols <-
    
    setdiff(
      names(counts),
      count_col
    )
  
  expanded <-
    
    counts[
      rep(
        seq_len(.N),
        get(count_col)
      ),
      ..attribute_cols
    ]
  
  id_width <- nchar(
    as.character(
      nrow(expanded)
    )
  )
  
  expanded[
    ,
    (agent_id_col) :=
      paste0(
        prefix,
        sprintf(
          paste0(
            "%0",
            id_width,
            "d"
          ),
          seq_len(.N)
        )
      )
  ]
  
  data.table::setcolorder(
    expanded,
    c(
      agent_id_col,
      attribute_cols
    )
  )
  
  expanded
  
}
make_couple_household <- function(
    pop,
    gender_distribution = c(
      "Male|Female" = 1
    ),
    age_distribution = c(
      "-5-5" = 1
    )
) {
  
  hh <- ReplicaStructure(
    "CoupleHousehold"
  )
  
  hh <- renew(
    hh,
    what = "positions",
    household_position = "Parent",
    position_identifier = "adult",
    amount = 2,
    backup_position_identifiers = character()
  )
  
  hh <- renew(
    hh,
    what = "state",
    df_synth_pop = pop,
    household_position_column = "household_position"
  )
  
  hh@couple_gender_distribution <-
    gender_distribution
  
  hh@couple_age_distribution <-
    age_distribution
  
  hh@sampled_agents <- character()
  
  hh
  
}
make_household_population <- function() {
  
  data.table(
    
    agent_id = c(
      "A001",
      "A002",
      "A003",
      "A004"
    ),
    
    neighb_code = c(
      "N1",
      "N1",
      "N1",
      "N1"
    ),
    
    age = c(
      40,
      35,
      50,
      45
    ),
    
    gender = c(
      "Male",
      "Female",
      "Male",
      "Female"
    ),
    
    household_position = c(
      "Parent",
      "Parent",
      "Parent",
      "Parent"
    )
    
  )
  
}

#' Match Adult Groups to Child Groups
#'
#' Creates family households by matching adult household groups
#' to sibling groups according to a parent-child age-gap
#' distribution.
#'
#' This function is the final family-construction stage of the
#' household-generation workflow and is typically called
#' indirectly via \code{createFromMembers}.
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
#' @param object A \code{ReplicaStructure} object.
#'
#' @param parents List of adult groups generated by
#' createSingles() or \code{pair_partners}.
#'
#' @param children List of sibling groups generated by
#' \code{group_children}.
#'
#' @param id_offset Integer household identifier offset used
#' when generating unique household IDs.
#'
#' @return A list containing:
#'
#' \describe{
#'   \item{object}{
#'     Updated \code{ReplicaStructure} object containing newly
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
#' \code{\link{create_household_with_id}},
#' \code{\link{ReplicaStructure}}
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
#' indirectly via \code{createFromMembers}.
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
#' @param object A \code{ReplicaStructure} object.
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
#' The updated \code{ReplicaStructure} object is attached as:
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
#' hh <- ReplicaStructure(
#'   "CoupleHousehold"
#' )
#'
#' hh <- renew(
#'   hh,
#'   what = "positions",
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
#' \code{\link{ReplicaStructure}}
#' @keywords internal
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
            
            object = object,
            
            mask = group_mask,
            
            primary_position_value =
              parent_position$position,
            
            backup_position_values =
              parent_position$backup_position_identifiers,
            
            gender = first_gender
            
          )
        
        if (is.null(primary_partner)) {
          
          next
          
        }
        
        secondary_partner <-
          
          findSecondaryPartner(
            
            object = object,
            
            mask = group_mask,
            
            primary_partner =
              primary_partner,
            
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
        
        #
        # Only sample agents once a valid
        # couple has been formed.
        #
        
        object@sampled_agents <- c(
          
          object@sampled_agents,
          
          primary_partner$agent_id,
          
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
score_distribution <- function(df) {
  
  z_result <-
    calculate_z_squared_score(df)
  
  gof_result <-
    calculate_goodness_of_fit(df)
  
  data.frame(
    
    Metric = c(
      "Z-score",
      "Goodness of Fit"
    ),
    
    Statistic = c(
      z_result$z_square,
      gof_result$score
    ),
    
    DoF = c(
      z_result$dof,
      gof_result$dof
    ),
    
    PValue = c(
      z_result$p,
      gof_result$p
    )
  )
}
