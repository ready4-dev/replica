#' Convert an Integer Age to an Age Group
#'
#' Maps an individual age to a categorical age-group label.
#'
#' Age groups are specified using either:
#'
#' \itemize{
#'   \item Closed-open intervals of the form
#'         \code{"lower-upper"}.
#'   \item Open-ended intervals of the form
#'         \code{"lower+"}.
#' }
#'
#' Examples:
#'
#' \preformatted{
#' "0-15"
#' "15-25"
#' "25-45"
#' "45-65"
#' "65+"
#' }
#'
#' This function is useful when converting continuous age
#' information into the categorical age-group formats commonly
#' used in contingency tables and marginal distributions.
#'
#' @param age Numeric age to be converted.
#'
#' @param age_groups Character vector containing age-group
#' definitions.
#'
#' Age groups should:
#'
#' \itemize{
#'   \item Cover the expected age range.
#'   \item Not overlap.
#'   \item Contain at most one open-ended category.
#' }
#'
#' @return A character string containing the matching age-group
#' label.
#'
#' Returns \code{NA} if no matching age group can be found.
#'
#' @details
#' Age groups are interpreted as:
#'
#' \describe{
#'   \item{\code{"a-b"}}{
#'     Ages greater than or equal to \code{a}
#'     and strictly less than \code{b}.
#'   }
#'
#'   \item{\code{"a+"}}{
#'     Ages greater than or equal to \code{a}.
#'   }
#' }
#'
#' For example:
#'
#' \preformatted{
#' age_to_age_group(
#'   20,
#'   c(
#'     "0-15",
#'     "15-25",
#'     "25-45"
#'   )
#' )
#' }
#'
#' returns:
#'
#' \preformatted{
#' "15-25"
#' }
#'
#' @examples
#' age_to_age_group(
#'   age = 12,
#'   age_groups = c(
#'     "0-15",
#'     "15-25",
#'     "25-45"
#'   )
#' )
#'
#' age_to_age_group(
#'   age = 20,
#'   age_groups = c(
#'     "0-15",
#'     "15-25",
#'     "25-45"
#'   )
#' )
#'
#' age_to_age_group(
#'   age = 70,
#'   age_groups = c(
#'     "0-15",
#'     "15-25",
#'     "25-45",
#'     "45-65",
#'     "65+"
#'   )
#' )
#'
#' @seealso
#' \code{\link{synthetic_population_to_contingency}},
#' \code{\link{multicolumn_to_attribute_values}}
#'
#' @export
age_to_age_group <- function(
    age,
    age_groups
) {
  
  age_groups <- sort(age_groups)
  
  for (age_group in age_groups) {
    
    if (grepl("\\+$", age_group)) {
      
      lower_bound <-
        as.numeric(
          sub("\\+$", "", age_group)
        )
      
      upper_bound <- Inf
      
    } else {
      
      bounds <-
        as.numeric(
          strsplit(
            age_group,
            "-"
          )[[1]]
        )
      
      lower_bound <- bounds[1]
      upper_bound <- bounds[2]
    }
    
    if (
      age >= lower_bound &&
      age < upper_bound
    ) {
      
      return(age_group)
      
    }
  }
  
  warning(
    sprintf(
      "No age group found for age %s",
      age
    )
  )
  
  NA_character_
}
#' Calculate an Age Range from an Age-Gap Specification
#'
#' Converts an age-gap specification into a valid age range for
#' candidate selection.
#'
#' Given a reference age and lower/upper age-gap bounds, the
#' function calculates the corresponding acceptable age range.
#'
#' This function is used by the household-generation subsystem
#' when searching for compatible partners.
#'
#' @param age Numeric reference age.
#'
#' @param gap_start Numeric lower age-gap bound.
#'
#' @param gap_end Numeric upper age-gap bound.
#'
#' @return A named list containing:
#'
#' \describe{
#'   \item{age_start}{
#'     Lower age bound.
#'   }
#'   \item{age_end}{
#'     Upper age bound.
#'   }
#' }
#'
#' @details
#' Age bounds are calculated by adding the supplied age-gap
#' values to the reference age.
#'
#' For example:
#'
#' \preformatted{
#' age = 40
#' gap_start = -5
#' gap_end = 5
#' }
#'
#' produces:
#'
#' \preformatted{
#' age_start = 35
#' age_end = 45
#' }
#'
#' If the calculated lower bound is greater than the upper
#' bound, the two values are automatically swapped so that the
#' returned interval is always valid.
#'
#' This behaviour mirrors the original GenSynthPop
#' implementation.
#'
#' @examples
#' calculate_age_range_from_gap(
#'   age = 40,
#'   gap_start = -5,
#'   gap_end = 5
#' )
#'
#' @examples
#' calculate_age_range_from_gap(
#'   age = 40,
#'   gap_start = 5,
#'   gap_end = 15
#' )
#'
#' @examples
#' calculate_age_range_from_gap(
#'   age = 40,
#'   gap_start = -10,
#'   gap_end = -5
#' )
#'
#' @seealso
#' \code{\link{parseAgeGap}},
#' \code{\link{score_suitability_by_age_disparity}},
#' \code{\link{findCoupleCandidates}},
#' \code{\link{pairPartners}}
#'
#' @keywords internal
calculate_age_range_from_gap <- function(
    age,
    gap_start,
    gap_end
) {
  
  age_start <- age + gap_start
  age_end <- age + gap_end
  
  if (age_start > age_end) {
    
    tmp <- age_start
    age_start <- age_end
    age_end <- tmp
    
  }
  
  list(
    age_start = age_start,
    age_end = age_end
  )
  
}
get_margin_frames_from_synthetic_population <- function(
    df_synth_pop,
    margins
) {
  
  setNames(
    lapply(
      margins,
      function(names_vec) {
        
        synthetic_population_to_contingency(
          df_synth_pop,
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
get_margin_series_from_synthetic_population <- function(
    df_synth_pop,
    margins
) {
  
  results <- list()
  
  for (names_vec in margins) {
    
    key <- paste(names_vec,
                 collapse = "|")
    
    contingency <-
      synthetic_population_to_contingency(
        df_synth_pop,
        names_vec,
        full_crosstab =
          length(names_vec) > 1
      )
    
    results[[key]] <-
      contingency$count
  }
  
  results
}
multicolumn_to_attribute_values <- function(
    df,
    attr_name,
    columns
) {
  
  data.table::melt(
    data.table::as.data.table(df),
    
    id.vars =
      setdiff(
        names(df),
        columns
      ),
    
    measure.vars = columns,
    
    variable.name = attr_name,
    
    value.name = "count"
  )
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
#' parseAgeGap("20-30")
#'
#' parseAgeGap("-5-5")
#'
#' parseAgeGap("-10--5")
#'
#' parseAgeGap("-10-5")
#'
#' @seealso
#' \code{\link{pairPartners}},
#' \code{\link{matchAdultsWithChildren}},
#' \code{\link{calculate_age_range_from_gap}}
#'
#' @export
parse_age_gap <- function(x) {
  
  nums <-
    as.numeric(
      regmatches(
        x,
        gregexpr(
          "-?\\d+",
          x
        )[[1]]
      )
    )
  
  if (length(nums) != 2) {
    stop(
      sprintf(
        "Unable to parse age-gap string '%s'",
        x
      )
    )
  }
  
  list(
    lower = nums[1],
    upper = nums[2]
  )
}
#' Convert a Synthetic Population to a Contingency Table
#'
#' Converts an agent-level synthetic population into a
#' contingency table.
#'
#' The resulting contingency table contains one row for each
#' unique combination of the specified attributes together with
#' a \code{count} column indicating the number of agents in
#' that group.
#'
#' This function is used extensively throughout GenSynthPopR
#' for:
#'
#' \itemize{
#'   \item Constructing validation tables.
#'   \item Computing marginal distributions.
#'   \item Comparing synthetic populations against target
#'         contingency tables.
#'   \item Statistical goodness-of-fit testing.
#' }
#'
#' @param df_synthetic_population A synthetic population stored
#' as a data.frame or \code{data.table}.
#'
#' Each row should correspond to a single agent.
#'
#' @param columns Character vector containing the attributes to
#' include in the contingency table.
#'
#' If \code{NULL}, all columns are used.
#'
#' @param full_crosstab Logical value indicating whether missing
#' combinations should be explicitly included.
#'
#' If:
#'
#' \describe{
#'   \item{FALSE}{
#'     Only observed combinations are returned.
#'   }
#'   \item{TRUE}{
#'     Missing combinations are included with a count of zero.
#'   }
#' }
#'
#' @return A contingency table containing:
#'
#' \itemize{
#'   \item The requested grouping variables.
#'   \item A \code{count} column.
#' }
#'
#' @details
#' For each unique combination of the selected attributes, the
#' function counts the number of agents in the synthetic
#' population belonging to that combination.
#'
#' When \code{full_crosstab = TRUE}, the function generates a
#' complete cross-classification of all observed levels and
#' assigns zero counts to combinations that do not occur in the
#' population.
#'
#' This behaviour is particularly useful when preparing data
#' for iterative proportional fitting (IPF) or statistical
#' validation procedures.
#'
#' @examples
#' population <- data.frame(
#'   gender = c(
#'     "Male",
#'     "Male",
#'     "Female"
#'   ),
#'   education = c(
#'     "Degree",
#'     "Degree",
#'     "School"
#'   )
#' )
#'
#' synthetic_population_to_contingency(
#'   population,
#'   c(
#'     "gender",
#'     "education"
#'   )
#' )
#'
#' @examples
#' synthetic_population_to_contingency(
#'   population,
#'   c(
#'     "gender",
#'     "education"
#'   ),
#'   full_crosstab = TRUE
#' )
#'
#' @seealso
#' \code{\link{get_margin_series_from_synthetic_population}},
#' \code{\link{get_margin_frames_from_synthetic_population}},
#' \code{\link{validate_synthetic_population_fit}},
#' \code{\link{calculate_z_squared_score}}
#'
#' @export
synthetic_population_to_contingency <- function(
    df_synthetic_population,
    columns = NULL,
    full_crosstab = FALSE
) {
  
  if (is.null(columns)) {
    columns <- names(df_synthetic_population)
  }
  
  dt <- data.table::as.data.table(
    df_synthetic_population
  )
  
  contingency <-
    dt[
      ,
      .(count = .N),
      by = columns
    ]
  
  if (!full_crosstab) {
    return(
      as.data.frame(contingency)
    )
  }
  
  all_levels <- lapply(
    columns,
    function(col) {
      sort(unique(dt[[col]]))
    }
  )
  
  names(all_levels) <- columns
  
  full_grid <- do.call(
    CJ,
    c(all_levels, sorted = FALSE)
  )
  
  contingency <- merge(
    full_grid,
    contingency,
    by = columns,
    all.x = TRUE
  )
  
  contingency[
    is.na(count),
    count := 0
  ]
  
  as.data.frame(contingency)
}