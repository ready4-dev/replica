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