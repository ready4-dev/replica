transform_long_to_array <- function(
    contingency_table,
    dimensions
) {
  
  xtabs(
    count ~ .,
    data =
      contingency_table[
        ,
        c(
          dimensions,
          "count"
        ),
        with = FALSE
      ]
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
#' transform_to_age_gap("20-30")
#'
#' transform_to_age_gap("-5-5")
#'
#' transform_to_age_gap("-10--5")
#'
#' transform_to_age_gap("-10-5")
#'
#' @seealso
#' \code{\link{calculate_age_range_from_gap}}
#'
#' @export
transform_to_age_gap <- function(
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
#' transform_to_age_group(
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
#' transform_to_age_group(
#'   age = 12,
#'   age_groups = c(
#'     "0-15",
#'     "15-25",
#'     "25-45"
#'   )
#' )
#'
#' transform_to_age_group(
#'   age = 20,
#'   age_groups = c(
#'     "0-15",
#'     "15-25",
#'     "25-45"
#'   )
#' )
#'
#' transform_to_age_group(
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
#' \code{\link{transform_to_contingency}},
#' \code{\link{transform_to_combinations}}
#'
#' @export
transform_to_age_group <- function(
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
#' transform_to_combinations(
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
#' \code{\link{transform_to_contingency}},
#' \code{\link{get_margin_series_from_synthetic_population}}
#'
#' @export
transform_to_combinations <- function(
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
#' transform_to_contingency(
#'   population,
#'   c(
#'     "gender",
#'     "education"
#'   )
#' )
#'
#' @examples
#' transform_to_contingency(
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
#' \code{\link{update_contingency_table}}
#'
#' @export
transform_to_contingency <- function(
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
