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
  
  testthat::expect_equal(
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

validate_fitted_distribution <- function(
    fitted_distribution,
    margins,
    margin_names,
    joint_distribution_name
) {
  
  if (is.character(margin_names)) {
    
    margin_names <- c(margin_names)
    
  }
  
  fitted <-
    fitted_distribution[
      ,
      .(count = sum(count)),
      by = margin_names
    ]
  
  combined <-
    merge(
      fitted,
      margins,
      by = margin_names
    )
  
  result <-
    calculate_z_squared_score(
      combined
    )
  
  if (result$p < 0.05) {
    
    warning(
      paste(
        "Fitted", joint_distribution_name,
        "does not fit supplied margins."
      )
    )
    
  } else {
    
    message(
      paste(
        joint_distribution_name,
        "fits margins."
      )
    )
  }
  
  invisible(result)
}
#' Validate the Fit of a Synthetic Population
#'
#' Compares a synthetic population against an expected
#' contingency table and evaluates goodness-of-fit.
#'
#' @param synthetic_population A synthetic population stored as
#' a data.frame or data.table.
#'
#' @param expected Reference contingency table containing the
#' expected distribution.
#'
#' @param dimensions Character vector identifying the variables
#' used to construct the comparison contingency table.
#'
#' @param name Character string used in validation messages and
#' warning output.
#'
#' @return A list object with multiple comparison results.
#'
#' @details
#' The function:
#'
#' \enumerate{
#'   \item Converts the synthetic population into a contingency
#'         table using
#'         \code{\link{synthetic_population_to_contingency}}.
#'
#'   \item Aligns the observed and expected distributions.
#'
#'   \item Calculates goodness-of-fit statistics using
#'         \code{\link{calculate_z_squared_score}}.
#'
#'   \item Emits a warning if the p-value is below 0.05.
#' }
#'
#' @examples
#' \dontrun{
#'
#' validate_synthetic_population_fit(
#'   synthetic_population,
#'   expected,
#'   dimensions = c(
#'     "gender",
#'     "education"
#'   ),
#'   name = "Education"
#' )
#'
#' }
#'
#' @seealso
#' \code{\link{calculate_z_squared_score}},
#' \code{\link{synthetic_population_to_contingency}}
#'
#' @export
validate_synthetic_population_fit <- function(
    synthetic_population,
    expected,
    dimensions,
    name
) {
  
  observed <-
    
    synthetic_population_to_contingency(
      synthetic_population,
      dimensions
    )
  
  observed <- data.table::as.data.table(
    observed
  )
  
  expected <- data.table::as.data.table(
    expected
  )
  
  combined <-
    
    merge(
      observed,
      expected,
      by = dimensions,
      suffixes = c(
        "_x",
        "_y"
      )
    )

  conditioning_dimensions <-
    
    setdiff(
      dimensions,
      name
    )
  
  combined[
    ,
    observed_pct :=
      100 *
      count_x /
      sum(count_x),
    by = conditioning_dimensions
  ]
  
  combined[
    ,
    expected_pct :=
      100 *
      count_y /
      sum(count_y),
    by = conditioning_dimensions
  ]
  
  combined[
    ,
    difference_pct :=
      observed_pct -
      expected_pct
  ]
  
  #
  # Reorder columns
  #
  
  comparison_columns <- c(
    "count_x",
    "count_y",
    "observed_pct",
    "expected_pct",
    "difference_pct"
  )
  
  combined <-
    
    combined[
      ,
      c(
        dimensions,
        comparison_columns
      ),
      with = FALSE
    ]
  
  z_result <-
    
    calculate_z_squared_score(
      combined
    )
  
  warning_required <-
    z_result$p_value < 0.05
  
  list(
    
    name = name,
    
    z_square =
      z_result$z_square,
    
    p_value =
      z_result$p_value,
    
    degrees_of_freedom =
      z_result$degrees_of_freedom,
    
    critical_value =
      z_result$critical_value,
    
    warning_required =
      warning_required,
    
    details =
      combined
    
  )
  
}