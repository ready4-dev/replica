#' Calculate Conditional Fractions from a Contingency Table
#'
#' Converts contingency-table counts into conditional
#' probabilities (fractions).
#'
#' For each conditioning group, the function computes the
#' proportion represented by each target-attribute category.
#'
#' The resulting fractions are subsequently used to allocate
#' synthetic agents during conditional attribute assignment.
#'
#' @param dt A contingency table containing a \code{count}
#' column.
#'
#' @param group_by Character vector containing the conditioning
#' variables.
#'
#' @param target_attribute Character string identifying the
#' target attribute.
#'
#' @param margins_group Optional character vector containing
#' additional grouping variables introduced through margin
#' fitting.
#'
#' @return The supplied contingency table with an additional
#' column named \code{fraction}.
#'
#' @details
#' Fractions are calculated separately within each conditioning
#' group.
#'
#' For a contingency table:
#'
#' \preformatted{
#' age_group gender education count
#' 18-64     Male   Degree    45
#' 18-64     Male   Diploma   25
#' 18-64     Male   School    30
#' }
#'
#' the resulting fractions are:
#'
#' \preformatted{
#' Degree   0.45
#' Diploma  0.25
#' School   0.30
#' }
#'
#' Groups whose total count equals zero receive fractions of
#' zero rather than \code{NA} or \code{NaN}.
#'
#' This behaviour prevents failures during synthetic-population
#' generation when contingency tables contain zero-count
#' groups.
#'
#' @examples
#' library(data.table)
#'
#' dt <- data.table(
#'   age_group = c(
#'     "18-64",
#'     "18-64",
#'     "18-64"
#'   ),
#'   gender = c(
#'     "Male",
#'     "Male",
#'     "Male"
#'   ),
#'   education = c(
#'     "Degree",
#'     "Diploma",
#'     "School"
#'   ),
#'   count = c(
#'     45,
#'     25,
#'     30
#'   )
#' )
#'
#' calculateFractions(
#'   dt,
#'   group_by = c(
#'     "age_group",
#'     "gender"
#'   ),
#'   target_attribute =
#'     "education"
#' )
#'
#' @examples
#' dt <- data.table(
#'   gender = c(
#'     "Female",
#'     "Female",
#'     "Female"
#'   ),
#'   education = c(
#'     "Degree",
#'     "Diploma",
#'     "School"
#'   ),
#'   count = c(
#'     0,
#'     0,
#'     0
#'   )
#' )
#'
#' calculateFractions(
#'   dt,
#'   group_by = "gender",
#'   target_attribute = "education"
#' )
#'
#' @seealso
#' \code{\link{getGroupFractions}},
#' \code{\link{calculateGroupCounts}},
#' \code{\link{ConditionalAttributeAdder}},
#' \code{\link{run}}
#'
#' @export

calculateFractions <- function(
    dt,
    group_by,
    target_attribute,
    margins_group = NULL
) {
  
  dt <- data.table::copy(dt)
  
  groups <- group_by
  
  if (!is.null(margins_group)) {
    
    groups <- c(
      groups,
      margins_group
    )
  }
  
  groups <- unique(groups)
  
  groups <-
    groups[
      groups %in% names(dt)
    ]
  
  groups <-
    setdiff(
      groups,
      target_attribute
    )
  
  dt[
    ,
    fraction := {
      total <- sum(count)
      
      if (total == 0) {
        rep(0, .N)
      } else {
        count / total
      }
    },
    by = groups
  ]
  
  dt
}
#' Convert Fractions into Integer Agent Counts
#'
#' Converts a vector of fractional probabilities into integer
#' counts while preserving the required total number of agents.
#'
#' Because synthetic agents cannot be subdivided, direct
#' multiplication of fractions by a target population size
#' generally produces non-integer values. Simple rounding can
#' also lead to totals that differ from the desired population
#' size.
#'
#' This function applies an iterative correction procedure that:
#'
#' \enumerate{
#'   \item Calculates initial rounded counts.
#'   \item Compares the resulting total with the desired
#'         population size.
#'   \item Identifies the category with the largest rounding
#'         discrepancy.
#'   \item Adjusts counts until the desired total is reached.
#' }
#'
#' @param fractions Named numeric vector containing category
#' probabilities or fractions.
#'
#' @param n_agents_total Integer total number of agents to
#' allocate.
#'
#' @return A named numeric vector containing integer counts.
#'
#' @details
#' The returned counts always sum to
#' \code{n_agents_total}.
#'
#' The allocation procedure attempts to preserve the supplied
#' proportions as closely as possible while maintaining an
#' integer-valued solution.
#'
#' This function is used throughout the package wherever
#' fractional distributions must be converted into agent-level
#' assignments.
#'
#' It is used by:
#'
#' \itemize{
#'   \item \code{\link{getAgentValuesFromFractions}}
#'   \item \code{\link{pairPartners}}
#'   \item \code{\link{matchAdultsWithChildren}}
#'   \item Conditional attribute assignment workflows
#' }
#'
#' @examples
#' fractions <- c(
#'   Degree = 0.45,
#'   Diploma = 0.25,
#'   School = 0.30
#' )
#'
#' calculateGroupCounts(
#'   fractions,
#'   10
#' )
#'
#' @examples
#' fractions <- c(
#'   A = 0.33,
#'   B = 0.33,
#'   C = 0.34
#' )
#'
#' calculateGroupCounts(
#'   fractions,
#'   100
#' )
#'
#' @seealso
#' \code{\link{getAgentValuesFromFractions}},
#' \code{\link{calculateFractions}},
#' \code{\link{pairPartners}},
#' \code{\link{matchAdultsWithChildren}}
#'
#' @export
calculateGroupCounts <- function(
    fractions,
    n_agents_total
) {
  
  if (length(fractions) == 0) {
    
    return(
      numeric(0)
    )
    
  }
  
  if (any(is.nan(fractions))) {
    stop("Fractions contain NaN values")
  }
  
  if (any(is.na(fractions))) {
    
    stop(
      "Fractions contain NA values"
    )
    
  }
  # print("fractions")
  # print(fractions)
  # 
  # print("n_agents_total")
  # print(n_agents_total)
  
  counts <- round(
    fractions * n_agents_total
  )
  
  # print("counts")
  # print(counts)
  
  
  repeat {
    
    total <- sum(counts)
    
    if (total == n_agents_total) {
      break
    }
    
    differences <-
      counts / n_agents_total -
      fractions
    
    if (total < n_agents_total) {
      
      idx <- which.min(differences)
      
      counts[idx] <- counts[idx] + 1
      
    } else {
      
      idx <- which.max(differences)
      
      counts[idx] <- counts[idx] - 1
    }
  }
  
  counts
}
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
expect_household_sizes_correct <- function(
    household_type
) {
  
  households <- householdsToDataFrame(
    household_type
  )
  
  expected_sizes <- sapply(
    household_type@households,
    function(x) length(x$all)
  )
  
  expect_equal(
    households$hh_size,
    as.integer(expected_sizes)
  )
  
}
expect_same_contingency <- function(
    r_result,
    py_result,
    dimensions
) {
  
  r_cont <-
    synthetic_population_to_contingency(
      r_result,
      dimensions
    )
  
  py_cont <-
    synthetic_population_to_contingency(
      py_result,
      dimensions
    )
  
  r_cont <- r_cont[
    do.call(
      order,
      r_cont[dimensions]
    ),
  ]
  
  py_cont <- py_cont[
    do.call(
      order,
      py_cont[dimensions]
    ),
  ]
  
  rownames(r_cont) <- NULL
  rownames(py_cont) <- NULL
  
  testthat::expect_equal(
    r_cont,
    py_cont
  )
  
}
expect_same_sampled_agents <- function(
    r_agents,
    py_agents
) {
  
  testthat::expect_equal(
    sort(r_agents),
    sort(py_agents)
  )
  
}
extract_age_gaps <- function(
    couples
) {
  
  sapply(
    
    couples,
    
    function(couple) {
      
      as.numeric(
        couple[[1]][2]
      ) -
        
        as.numeric(
          couple[[2]][2]
        )
      
    }
    
  )
  
}
extract_assigned_children <- function(
    updated_hh
) {
  
  sort(
    updated_hh@sampled_agents
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
    households
) {
  
  sort(
    households$hh_size
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
    households
) {
  
  sort(
    table(
      households$hh_type
    )
  )
  
}
fitContingencyIPF <- function(
    seed,
    targets,
    target_names
) {
  
  mipfp::Ipfp(
    seed = seed,
    target.list = target_names,
    target.data = targets
  )
}

#' Generate Agent Values from Conditional Fractions
#'
#' Converts a conditional probability distribution into a
#' vector of target-attribute values suitable for assignment
#' to synthetic agents.
#'
#' The function:
#'
#' \enumerate{
#'   \item Converts fractions into integer counts using
#'         \code{\link{calculateGroupCounts}}.
#'   \item Expands the counts into individual target-attribute
#'         values.
#'   \item Randomises the resulting values to avoid systematic
#'         ordering effects.
#' }
#'
#' This function is used internally by
#' \code{\link{run}} during conditional attribute assignment.
#'
#' @param fractions Named numeric vector containing conditional
#' probabilities or fractions.
#'
#' Each name represents a target-attribute category.
#'
#' @param group_size Integer number of synthetic agents to be
#' assigned values.
#'
#' @return A character vector containing one target-attribute
#' value for each synthetic agent in the group.
#'
#' @details
#' Fractions are first converted into integer counts using
#' \code{\link{calculateGroupCounts}}.
#'
#' For example:
#'
#' \preformatted{
#' Degree   0.50
#' Diploma  0.30
#' School   0.20
#' }
#'
#' with:
#'
#' \preformatted{
#' group_size = 10
#' }
#'
#' produces:
#'
#' \preformatted{
#' Degree   5
#' Diploma  3
#' School   2
#' }
#'
#' which is then expanded into:
#'
#' \preformatted{
#' Degree
#' Degree
#' Degree
#' Degree
#' Degree
#' Diploma
#' Diploma
#' Diploma
#' School
#' School
#' }
#'
#' The returned vector is randomly permuted before being
#' returned.
#'
#' @examples
#' fractions <- c(
#'   Degree = 0.50,
#'   Diploma = 0.30,
#'   School = 0.20
#' )
#'
#' values <- getAgentValuesFromFractions(
#'   fractions,
#'   group_size = 10
#' )
#'
#' length(values)
#'
#' @examples
#' fractions <- c(
#'   Degree = 0.45,
#'   Diploma = 0.25,
#'   School = 0.30
#' )
#'
#' getAgentValuesFromFractions(
#'   fractions,
#'   group_size = 20
#' )
#'
#' @seealso
#' \code{\link{calculateGroupCounts}},
#' \code{\link{calculateFractions}},
#' \code{\link{getGroupFractions}},
#' \code{\link{ConditionalAttributeAdder}},
#' \code{\link{run}}
#'
#' @keywords internal
getAgentValuesFromFractions <- function(
    fractions,
    group_size
) {
  
  counts <-
    calculateGroupCounts(
      fractions,
      group_size
    )
  
  values <- c()
  
  for (i in seq_along(counts)) {
    
    if (counts[i] > 0) {
      
      values <- c(
        values,
        rep(
          names(counts)[i],
          counts[i]
        )
      )
    }
  }
  
  sample(values)
}
#' Extract Conditional Fractions for a Target Attribute
#'
#' Computes and extracts conditional fractions from a
#' contingency table for use during attribute assignment.
#'
#' The function converts contingency-table counts into
#' conditional probabilities using
#' \code{\link{calculateFractions}} and returns the resulting
#' fractions indexed by the target attribute and any relevant
#' margin variables.
#'
#' This function is used internally by
#' \code{\link{run}} during conditional attribute assignment.
#'
#' @param object A \code{\link{ConditionalAttributeAdder}}
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
#'   \item \code{\link{getAgentValuesFromFractions}}
#'   \item \code{\link{calculateGroupCounts}}
#'   \item \code{\link{run}}
#' }
#'
#' If margin constraints have been supplied using
#' \code{\link{addMargins}}, the returned table will also
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
#' \code{\link{calculateFractions}},
#' \code{\link{calculateGroupCounts}},
#' \code{\link{getAgentValuesFromFractions}},
#' \code{\link{ConditionalAttributeAdder}},
#' \code{\link{run}}
#'
#' @keywords internal
getGroupFractions <- function(
    object,
    dt
) {
  
  dt <- calculateFractions(
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
long_to_array <- function(
    contingency,
    dimensions
) {
  
  xtabs(
    count ~ .,
    data =
      contingency[
        ,
        c(
          dimensions,
          "count"
        ),
        with = FALSE
      ]
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
prepareContingencyTable <- function(
    contingency,
    synth_pop,
    group_by,
    target_attribute,
    strategy = "borrow"
) {
  
  contingency <- as.data.frame(
    contingency
  )
  
  synth_pop <- as.data.frame(
    synth_pop
  )
  
  contingency_groups <- unique(
    contingency[
      ,
      group_by,
      drop = FALSE
    ]
  )
  
  population_groups <- unique(
    synth_pop[
      ,
      group_by,
      drop = FALSE
    ]
  )
  
  missing_groups <- population_groups[
    
    !apply(
      
      population_groups,
      
      1,
      
      function(row) {
        
        any(
          apply(
            contingency_groups,
            1,
            function(x)
              all(x == row)
          )
        )
        
      }
      
    ),
    
    ,
    drop = FALSE
    
  ]
  if (
    strategy == "error" &&
    nrow(missing_groups) > 0
  ) {
    
    stop(
      
      paste(
        
        "Missing contingency groups:",
        
        paste(
          
          apply(
            missing_groups,
            1,
            function(x)
              paste(
                x,
                collapse = ", "
              )
          ),
          
          collapse = "; "
          
        )
        
      )
      
    )
    
  }
  
  if (nrow(missing_groups) == 0) {
    
    return(
      data.table::as.data.table(
        contingency
      )
    )
    
  }
  
  additions <- list()
  for (i in seq_len(
    nrow(missing_groups)
  )) {
    
    group_row <- missing_groups[
      i,
      ,
      drop = FALSE
    ]
    if (strategy == "overall") {
      
      overall_distribution <- aggregate(
        
        count ~ .,
        
        contingency[
          ,
          c(
            target_attribute,
            "count"
          )
        ],
        
        sum
        
      )
      
      new_rows <- group_row[
        rep(
          1,
          nrow(
            overall_distribution
          )
        ),
        ,
        drop = FALSE
      ]
      
      new_rows[[target_attribute]] <- overall_distribution[[target_attribute]]
      
      new_rows$count <-
        overall_distribution$count
      
    }
    else 
      if (strategy == "borrow") {
      
      borrowed <- NULL
      
      reduced_group_by <- group_by
      
      while (length(reduced_group_by) > 0) {
        
        reduced_group_by <-
          reduced_group_by[
            -length(
              reduced_group_by
            )
          ]
        
        if (
          length(
            reduced_group_by
          ) == 0
        ) {
          break
        }
        
        mask <- rep(
          TRUE,
          nrow(contingency)
        )
        for (g in reduced_group_by) {
          
          mask <- mask &
            
            (
              contingency[[g]] ==
                group_row[[g]]
            )
          
        }
        if (
          is.null(borrowed) ||
          nrow(borrowed) == 0
        ) {
          
          borrowed <- aggregate(
            
            count ~ .,
            
            contingency[
              ,
              c(
                target_attribute,
                "count"
              )
            ],
            
            sum
            
          )
          
          new_rows <- group_row[
            rep(
              1,
              nrow(borrowed)
            ),
            ,
            drop = FALSE
          ]
          
          new_rows[[target_attribute]] <- borrowed[[target_attribute]]
          
          new_rows$count <-
            borrowed$count
        } else {
          
          new_rows <- borrowed
          
          for (g in group_by) {
            
            new_rows[[g]] <-
              group_row[[g]]
            
          }
          
        }
        
      }
      new_rows <- new_rows[
        ,
        names(contingency),
        drop = FALSE
      ]
      
      additions[[length(additions) + 1]] <- list(new_rows)
      
    }
    if (length(additions) > 0) {
      
      additions_df <- do.call(
        rbind,
        additions
      )
      
      contingency <- rbind(
        contingency,
        additions_df
      )
      
    }
    
    rownames(contingency) <- NULL
    
    data.table::as.data.table(
      contingency
    )
    
  }
}
#' Prepare a Contingency Table for Attribute Assignment
#'
#' Ensures that all conditioning-group combinations present in a
#' synthetic population are represented in a contingency table.
#'
#' Missing contingency groups can be handled using one of three
#' configurable strategies:
#'
#' \describe{
#'   \item{borrow}{
#'     Borrow the nearest available conditional distribution.
#'   }
#'   \item{overall}{
#'     Use the overall target-attribute distribution.
#'   }
#'   \item{error}{
#'     Stop with an error if required groups are missing.
#'   }
#' }
#'
#' This function is typically invoked automatically by
#' \code{\link{run}} before conditional attribute assignment
#' begins.
#'
#' @param contingency A contingency table containing the target
#' attribute and a \code{count} column.
#'
#' @param synth_pop A synthetic population used to determine
#' which conditioning-group combinations must be represented.
#'
#' @param group_by Character vector containing the conditioning
#' variables used during attribute assignment.
#'
#' @param target_attribute Character string identifying the
#' target attribute.
#'
#' @param strategy Character string specifying how missing
#' contingency groups should be handled.
#'
#' One of:
#'
#' \itemize{
#'   \item \code{"borrow"}
#'   \item \code{"overall"}
#'   \item \code{"error"}
#' }
#'
#' @return A completed contingency table returned as a
#' \code{data.table}.
#'
#' @details
#' The function compares all unique combinations of
#' \code{group_by} variables found in the synthetic population
#' against those present in the contingency table.
#'
#' Any missing combinations are handled according to the
#' specified strategy.
#'
#' For \code{"borrow"}, the function attempts to construct a
#' distribution using a less-specific grouping level before
#' falling back to the overall distribution.
#'
#' For \code{"overall"}, the function uses the overall
#' target-attribute distribution computed from the contingency
#' table.
#'
#' For \code{"error"}, an exception is raised whenever one or
#' more required conditioning groups are missing.
#'
#' This function prevents failures during attribute assignment
#' caused by incomplete contingency tables and provides a
#' configurable mechanism for handling sparse input data.
#'
#' @examples
#' \dontrun{
#'
#' population <- data.frame(
#'   age_group = c(
#'     "18-64",
#'     "18-64"
#'   ),
#'   gender = c(
#'     "Male",
#'     "Female"
#'   )
#' )
#'
#' contingency <- data.frame(
#'   age_group = c(
#'     "18-64",
#'     "18-64",
#'     "18-64"
#'   ),
#'   gender = c(
#'     "Male",
#'     "Male",
#'     "Male"
#'   ),
#'   education = c(
#'     "Degree",
#'     "Diploma",
#'     "School"
#'   ),
#'   count = c(
#'     50,
#'     30,
#'     20
#'   )
#' )
#'
#' expanded <- prepareContingencyTable(
#'   contingency = contingency,
#'   synth_pop = population,
#'   group_by = c(
#'     "age_group",
#'     "gender"
#'   ),
#'   target_attribute = "education",
#'   strategy = "borrow"
#' )
#'
#' }
#'
#' @seealso
#' \code{\link{ConditionalAttributeAdder}},
#' \code{\link{run}},
#' \code{\link{calculateFractions}},
#' \code{\link{synthetic_population_to_contingency}}
#'
#' @export
prepareContingencyTable <- function(
    contingency,
    synth_pop,
    group_by,
    target_attribute,
    strategy = "borrow"
) {
  
  contingency <- as.data.frame(contingency)
  
  synth_pop <- as.data.frame(synth_pop)
  
  target_values <- unique(
    contingency[[target_attribute]]
  )
  
  additions <- list()
  
  #
  # Groups present in contingency
  #
  
  contingency_groups <- unique(
    contingency[
      ,
      group_by,
      drop = FALSE
    ]
  )
  
  #
  # Groups present in synthetic population
  #
  
  population_groups <- unique(
    synth_pop[
      ,
      group_by,
      drop = FALSE
    ]
  )
  
  #
  # Determine missing groups
  #
  
  missing_groups <- population_groups[
    
    !apply(
      
      population_groups,
      
      1,
      
      function(row) {
        
        any(
          apply(
            contingency_groups,
            1,
            function(x)
              all(x == row)
          )
        )
        
      }
      
    ),
    
    ,
    drop = FALSE
    
  ]
  
  #
  # Strategy: error
  #
  
  if (
    strategy == "error" &&
    nrow(missing_groups) > 0
  ) {
    
    stop(
      
      paste(
        
        "Missing contingency groups:",
        
        paste(
          
          apply(
            missing_groups,
            1,
            function(x)
              paste(
                x,
                collapse = ", "
              )
          ),
          
          collapse = "; "
          
        )
        
      )
      
    )
    
  }
  
  #
  # Nothing to do
  #
  
  if (nrow(missing_groups) == 0) {
    
    return(
      data.table::as.data.table(
        contingency
      )
    )
    
  }
  
  #
  # Build missing groups
  #
  
  for (i in seq_len(nrow(missing_groups))) {
    
    group_row <- missing_groups[
      i,
      ,
      drop = FALSE
    ]
    
    #
    # Strategy: overall
    #
    
    if (strategy == "overall") {
      
      overall_distribution <- aggregate(
        
        count ~ .,
        
        contingency[
          ,
          c(
            target_attribute,
            "count"
          ),
          drop = FALSE
        ],
        
        sum
        
      )
      
      new_rows <- group_row[
        rep(
          1,
          nrow(overall_distribution)
        ),
        ,
        drop = FALSE
      ]
      
      new_rows[[target_attribute]] <-  overall_distribution[[target_attribute]]
      
      new_rows$count <-
        overall_distribution$count
      
    }
    
    #
    # Strategy: borrow
    #
    
    else if (strategy == "borrow") {
      
      borrowed <- contingency
      
      #
      # Borrow from a less-specific group
      #
      
      if (length(group_by) > 1) {
        
        for (g in group_by[-length(group_by)]) {
          
          borrowed <- borrowed[
            borrowed[[g]] ==
              group_row[[g]],
            ,
            drop = FALSE
          ]
          
        }
        
      }
      
      #
      # If no suitable distribution exists,
      # fall back to overall distribution
      #
      
      if (nrow(borrowed) == 0) {
        
        borrowed <- aggregate(
          
          count ~ .,
          
          contingency[
            ,
            c(
              target_attribute,
              "count"
            ),
            drop = FALSE
          ],
          
          sum
          
        )
        
        new_rows <- group_row[
          rep(
            1,
            nrow(borrowed)
          ),
          ,
          drop = FALSE
        ]
        
        new_rows[[target_attribute]] <- borrowed[[target_attribute]]
        
        new_rows$count <-
          borrowed$count
        
      } else {
        
        new_rows <- borrowed
        
        for (g in group_by) {
          
          new_rows[[g]] <-
            group_row[[g]]
          
        }
        
      }
      
    }
    
    #
    # Ensure column order matches
    #
    
    new_rows <- new_rows[
      ,
      names(contingency),
      drop = FALSE
    ]
    
    additions[[length(additions) + 1]] <- new_rows
    
  }
  
  #
  # Append additions
  #
  
  additions_df <- do.call(
    rbind,
    additions
  )
  
  contingency <- rbind(
    contingency,
    additions_df
  )
  
  rownames(contingency) <- NULL
  
  data.table::as.data.table(
    contingency
  )
  
}
