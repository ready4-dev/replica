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
#' calculate_fractions(
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
#' calculate_fractions(
#'   dt,
#'   group_by = "gender",
#'   target_attribute = "education"
#' )
#'
#' @seealso
#' \code{\link{getGroupFractions}},
#' \code{\link{calculate_group_counts}},
#' \code{\link{ConditionalAttributeAdder}},
#' \code{\link{run}}
#'
#' @export

calculate_fractions <- function(
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

calculate_goodness_of_fit <- function(df,
                                      CRITICAL_ALPHA = c(0.05)) {
  
  dof <- nrow(df)
  
  numerator <-
    (df$count_x - df$count_y)^2
  
  denominator <-
    ifelse(df$count_y == 0,
           1,
           df$count_y)
  
  x2 <- sum(numerator / denominator)
  
  p_value <-
    1 - stats::pchisq(
      x2,
      df = dof
    )
  
  critical_values <-
    stats::qchisq(
      1 - CRITICAL_ALPHA,
      df = dof
    )
  
  list(
    score = x2,
    p = p_value,
    dof = dof,
    critical_values = critical_values
  )
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
#'   \item \code{\link{pair_partners}}
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
#' calculate_group_counts(
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
#' calculate_group_counts(
#'   fractions,
#'   100
#' )
#'
#' @seealso
#' \code{\link{calculate_fractions}},
#' \code{\link{pair_partners}},
#' \code{\link{matchAdultsWithChildren}}
#'
#' @export
calculate_group_counts <- function(
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

#' @keywords internal
#' @noRd
calculate_one_z_squared_score <- function(
    row
) {
  
  observed_proportion <-
    row$count_x /
    row$observed_total
  
  expected_proportion <-
    row$count_y /
    row$expected_total
  
  enumerator <-
    observed_proportion -
    expected_proportion
  
  #
  # Continuity correction
  #
  
  if (row$count_y != 0) {
    
    continuity_correction_factor <-
      1 / (
        2 *
          row$expected_total
      )
    
    if (row$expected_total != 0) {
      
      if (enumerator >= 0) {
        
        enumerator <-
          enumerator -
          continuity_correction_factor
        
      } else {
        
        enumerator <-
          enumerator +
          continuity_correction_factor
        
      }
      
    }
    
  }
  
  #
  # Expected value is zero
  #
  
  if (row$count_y == 0) {
    
    expected_proportion <-
      1 / row$expected_total
    
  }
  
  denominator <-
    
    sqrt(
      
      expected_proportion *
        
        (1 - expected_proportion) /
        
        row$expected_total
      
    )
  
  row$z <-
    enumerator /
    denominator
  
  row
  
}

#' Calculate a Z-Squared Goodness-of-Fit Statistic
#'
#' Calculates a z-squared goodness-of-fit statistic comparing
#' observed and expected frequencies.
#'
#' The implementation follows the approach described by
#' Voas and Williamson and incorporates the continuity
#' correction proposed by Fleiss (1981).
#'
#' The resulting z-squared statistic can be interpreted in a
#' similar manner to a chi-squared test statistic and may be
#' used to assess the fit of a synthetic population to a
#' reference distribution.
#'
#' @param df A data frame containing:
#'
#' \describe{
#'   \item{count_x}{
#'     Observed frequencies.
#'   }
#'
#'   \item{count_y}{
#'     Expected frequencies.
#'   }
#'
#'   \item{observed_total}{
#'     Optional observed population total.
#'   }
#'
#'   \item{expected_total}{
#'     Optional expected population total.
#'   }
#' }
#'
#' If totals are not supplied they are calculated from
#' \code{count_x} and \code{count_y}.
#'
#' @return A list containing:
#'
#' \describe{
#'   \item{z_square}{
#'     Overall z-squared statistic.
#'   }
#'
#'   \item{p_value}{
#'     Chi-squared p-value.
#'   }
#'
#'   \item{degrees_of_freedom}{
#'     Number of degrees of freedom.
#'   }
#'
#'   \item{critical_value}{
#'     Chi-squared critical value at the 0.05 significance
#'     level.
#'   }
#'
#'   \item{details}{
#'     Data frame containing cell-level z scores and
#'     probabilities.
#'   }
#' }
#'
#' @details
#' For each contingency-table cell:
#'
#' \enumerate{
#'   \item Observed and expected proportions are calculated.
#'   \item A continuity correction is applied when the expected
#'         frequency is non-zero.
#'   \item Cell-level z scores are calculated.
#'   \item Squared z scores are summed to create an overall
#'         z-squared statistic.
#' }
#'
#' When the expected count equals zero, a small surrogate
#' expected proportion is used in the denominator to avoid
#' division-by-zero problems.
#'
#' This function is primarily intended for evaluating the fit
#' of synthetic populations generated by replica.
#'
#' @references
#' Fleiss JL (1981). \emph{Statistical Methods for Rates and
#' Proportions}. Wiley.
#'
#' Voas D, Williamson P (2001). "The Diversity of Diversity:
#' A Critique of Geodemographic Classification".
#'
#' @examples
#' df <- data.frame(
#'   count_x = c(
#'     40,
#'     35,
#'     25
#'   ),
#'   count_y = c(
#'     45,
#'     30,
#'     25
#'   )
#' )
#'
#' result <- calculate_z_squared_score(
#'   df
#' )
#'
#' result$z_square
#'
#' result$p_value
#'
#' @seealso
#' \code{\link{validate_synthetic_population_fit}},
#' \code{\link{synthetic_population_to_contingency}}
#'
#' @export
calculate_z_squared_score <- function(
    df
) {
  
  df <- as.data.frame(df)
  
  if (
    !"observed_total" %in%
    names(df)
  ) {
    
    df$observed_total <-
      sum(df$count_x)
    
  }
  
  if (
    !"expected_total" %in%
    names(df)
  ) {
    
    df$expected_total <-
      sum(df$count_y)
    
  }
  
  #
  # Calculate z scores
  #
  
  rows <- lapply(
    
    seq_len(nrow(df)),
    
    function(i) {
      
      calculate_one_z_squared_score(
        df[i, ]
      )
      
    }
    
  )
  
  df <- do.call(
    rbind,
    rows
  )
  
  #
  # One-sided p-value
  #
  
  df$p <-
    1 -
    stats::pnorm(
      df$z
    )
  
  dof <- nrow(df)
  
  z_square <-
    sum(
      df$z^2
    )
  
  p_value <-
    1 -
    stats::pchisq(
      z_square,
      df = dof
    )
  
  critical_value <-
    stats::qchisq(
      0.95,
      df = dof
    )
  
  list(
    
    z_square =
      z_square,
    
    p_value =
      p_value,
    
    degrees_of_freedom =
      dof,
    
    critical_value =
      critical_value,
    
    details =
      df
    
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
#'         \code{\link{calculate_group_counts}}.
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
#' \code{\link{calculate_group_counts}}.
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
#' \dontrun{
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
#' }
#'
#' @examples
#' \dontrun{
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
#' }
#'
#' @seealso
#' \code{\link{calculate_group_counts}},
#' \code{\link{calculate_fractions}},
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
    calculate_group_counts(
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
percentage_points_difference <- function(df) {
  
  df <- data.table::as.data.table(df)
  
  if ("neighb_code" %in% names(df)) {
    
    df[
      ,
      total_x := sum(count_x),
      by = neighb_code
    ]
    
    df[
      ,
      total_y := sum(count_y),
      by = neighb_code
    ]
    
    df[
      ,
      count_y := count_y / total_y * total_x
    ]
    
  } else {
    
    df[, total_x := sum(count_x)]
    df[, total_y := sum(count_y)]
  }
  
  df[
    ,
    frac_x := count_x / total_x
  ]
  
  df[
    ,
    frac_y := count_y / total_y
  ]
  
  sum(abs(df$frac_x - df$frac_y))
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

standardised_absolute_error <- function(df) {
  
  total_absolute_error(df) /
    sum(df$count_y)
  
}

total_absolute_error <- function(df) {
  
  df <- as.data.frame(df)
  
  obs_total <- sum(df$count_x)
  exp_total <- sum(df$count_y)
  
  rel_diff <-
    abs(obs_total - exp_total) /
    mean(c(obs_total, exp_total))
  
  if (rel_diff > 0.05) {
    
    message(
      "Scaling expected values before calculating TAE"
    )
    
    df$count_y <-
      df$count_y /
      exp_total *
      obs_total
  }
  
  sum(abs(df$count_x - df$count_y))
}