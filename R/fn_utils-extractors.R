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
#' @export
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
#' @param df_synth_pop A synthetic population stored as
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
#' \code{\link{ConditionalAttributeAdder}}
#'
#' @export
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
#' @param df_synth_pop A synthetic population stored as
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
#' \code{\link{synthetic_population_to_contingency}},
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
#' \code{\link{synthetic_population_to_contingency}}
#'
#' @export
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
#' Convert Multiple Columns to Attribute Combinations
#'
#' Creates combined attribute values from multiple columns in a
#' synthetic population or contingency table.
#'
#' This function is useful when constructing composite grouping
#' variables from several demographic attributes.
#'
#' Examples include:
#'
#' \itemize{
#'   \item Age-group and gender combinations.
#'   \item Education and employment combinations.
#'   \item Geographic and demographic combinations.
#' }
#'
#' @param df Input data frame or data.table.
#'
#' @param attr_name Character string specifying the name of the
#' generated attribute.
#'
#' @param columns Character vector containing the columns to
#' convert.
#'
#' @return A character vector containing combined attribute
#' values.
#'
#' @details
#' Values from the supplied columns are combined into a single
#' string representation for each row.
#'
#' The resulting values can be used as:
#'
#' \itemize{
#'   \item Composite identifiers.
#'   \item Grouping variables.
#'   \item Keys for matching and aggregation.
#' }
#'
#' This function is used internally by several utilities in
#' replica but may also be useful for user-defined reporting and
#' validation workflows.
#'
#' @examples
#' df <- data.frame(
#'   Degree = c(50, 20),
#'   Diploma = c(30, 10),
#'   School = c(20, 70),
#'   gender = c(
#'     "Male",
#'     "Female"
#'   )
#' )
#'
#' multicolumn_to_attribute_values(
#'   df = df,
#'   attr_name = "education",
#'   columns = c(
#'     "Degree",
#'     "Diploma",
#'     "School"
#'   )
#' )
#'
#' @seealso
#' \code{\link{synthetic_population_to_contingency}},
#' \code{\link{get_margin_series_from_synthetic_population}}
#'
#' @export
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
#' Convert a Synthetic Population to a Contingency Table
#'
#' Converts an agent-level synthetic population into a
#' contingency table.
#'
#' The resulting table contains one row for each unique
#' combination of the supplied attributes together with a
#' \code{count} column indicating the number of synthetic
#' agents belonging to that group.
#'
#' This function is one of the core analytical utilities in
#' replica and is used for:
#'
#' \itemize{
#'   \item Validation of synthetic populations.
#'   \item Comparison with reference contingency tables.
#'   \item Goodness-of-fit assessment.
#'   \item Calculation of marginal distributions.
#'   \item Python-parity testing.
#' }
#'
#' @param df_synthetic_population A synthetic population stored
#' as a data.frame or \code{data.table}.
#'
#' @param columns Character vector identifying the variables to
#' include in the contingency table.
#'
#' If \code{NULL}, all available variables are used.
#'
#' @param full_crosstab Logical value indicating whether all
#' possible combinations of factor levels should be represented.
#'
#' If:
#'
#' \describe{
#'   \item{\code{FALSE}}{
#'     Only observed combinations are returned.
#'   }
#'
#'   \item{\code{TRUE}}{
#'     Missing combinations are included with
#'     \code{count = 0}.
#'   }
#' }
#'
#' @return A contingency table containing the supplied
#' grouping variables and a \code{count} column.
#'
#' @details
#' The function aggregates the synthetic population by the
#' supplied variables and counts the number of agents in each
#' resulting group.
#'
#' When \code{full_crosstab = TRUE}, a complete
#' cross-classification of all observed factor levels is
#' generated and any absent combinations receive a count of
#' zero.
#'
#' This behaviour is particularly useful when comparing
#' synthetic populations against reference distributions.
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
#' \code{\link{validate_synthetic_population_fit}},
#' \code{\link{calculate_z_squared_score}},
#' \code{\link{prepareContingencyTable}}
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
    data.table::CJ,
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
