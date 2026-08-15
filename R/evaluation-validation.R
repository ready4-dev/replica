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
#' @return The result returned by
#' \code{\link{calculate_z_squared_score}}.
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
  
  result <-
    calculate_z_squared_score(
      combined
    )
  
  if (result$p < 0.05) {
    
    warning(
      sprintf(
        "%s distribution differs from expected",
        name
      )
    )
  }
  
  invisible(result)
}