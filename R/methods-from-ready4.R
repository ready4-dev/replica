#' Enhance Replica Modules
#'
#' Enhances a replica module by updating or enriching the
#' data managed by that module.
#'
#' The behaviour of `enhance()` depends on the class of the
#' supplied object.
#'
#' Methods are currently available for:
#'
#' \itemize{
#'   \item \code{ReplicaAdder}
#' }
#'
#' @details
#'
#' In the current implementation, `enhance()` is used to
#' execute attribute-assignment workflows.
#'
#' For a \code{ReplicaAdder}, the method assigns values of a
#' target attribute to synthetic agents using information
#' supplied in contingency tables and optional marginal
#' distributions.
#'
#' The resulting enriched synthetic population is stored
#' within the module and can subsequently be validated using
#' \code{\link{ratify}}.
#'
#' Workflows that generate new output objects, such as
#' household generation, are implemented using
#' \code{\link{manufacture}}.
#'
#' @seealso
#' \code{\link{renew}},
#' \code{\link{ratify}},
#' \code{\link{manufacture}},
#' \code{\link{ReplicaAdder}}
#'
#' @name enhance
NULL

#' Manufacture Replica Outputs
#'
#' Creates new outputs from replica modules.
#'
#' The behaviour of `manufacture()` depends on the class of
#' the supplied object.
#'
#' Methods are currently available for:
#'
#' \itemize{
#'   \item \code{ReplicaGrouper}
#' }
#'
#' @name manufacture
NULL

#' Ratify Replica Modules
#'
#' Evaluates whether a replica module satisfies required
#' validity criteria.
#'
#' The behaviour of `ratify()` depends on the class of the
#' supplied object.
#'
#' Methods are currently available for:
#'
#' \itemize{
#'   \item \code{ReplicaAdder}
#'   \item \code{ReplicaStructure}
#' }
#'
#' @details
#'
#' `ratify()` performs class-specific validation checks and
#' returns either validation results or a validated module.
#'
#' For synthetic-population workflows, `ratify()` can be used
#' to assess:
#'
#' \itemize{
#'   \item attribute-assignment quality;
#'   \item household-assignment integrity; and
#'   \item internal consistency of replica modules.
#' }
#'
#' @section ReplicaAdder Method:
#'
#' For a \code{ReplicaAdder}, \code{ratify()} evaluates the
#' quality of attribute assignment and stores validation
#' diagnostics within the module.
#'
#' Validation results are stored in:
#'
#' \preformatted{
#' x@validation_results
#' }
#'
#' and include:
#'
#' \itemize{
#'   \item z-squared statistics;
#'   \item p-values;
#'   \item warning flags; and
#'   \item detailed comparisons of observed and expected
#'   distributions.
#' }
#'
#' @section ReplicaStructure Method:
#'
#' For a \code{ReplicaStructure}, \code{ratify()} evaluates
#' household-assignment integrity.
#'
#' Validation checks include:
#'
#' \itemize{
#'   \item duplicate household assignments; and
#'   \item eligible agents that have not been assigned to a
#'   household.
#' }
#'
#' Agents eligible for assignment are identified using the
#' household-position definitions stored in the structure.
#'
#' When duplicate assignments are detected, execution is
#' stopped and an error is generated.
#'
#' When eligible agents have not been assigned to a
#' household, a warning is issued.
#'
#' The method can return either:
#'
#' \itemize{
#'   \item a logical validation result; or
#'   \item the validated
#'   \code{ReplicaStructure} object.
#' }
#'
#' @param x A replica module.
#'
#' @param output Character string specifying the desired
#' return value for \code{ReplicaStructure} methods.
#'
#' Options are:
#'
#' \itemize{
#'   \item \code{"logical"} returns a logical validation
#'   result;
#'   \item \code{"self"} returns the validated
#'   \code{ReplicaStructure}.
#' }
#'
#' @return
#'
#' For a \code{ReplicaAdder}, an updated
#' \code{ReplicaAdder} containing validation results.
#'
#' For a \code{ReplicaStructure}:
#'
#' \itemize{
#'   \item \code{output = "logical"} returns a logical value;
#'   \item \code{output = "self"} returns a validated
#'   \code{ReplicaStructure}.
#' }
#'
#' @examples
#' \dontrun{
#'
#' ## Validate a ReplicaAdder
#'
#' adder <- enhance(adder)
#'
#' adder <- ratify(
#'   adder
#' )
#'
#' adder@validation_results
#'
#' ## Validate a ReplicaStructure
#'
#' ratify(
#'   structure,
#'   output = "logical"
#' )
#'
#' structure <- ratify(
#'   structure,
#'   output = "self"
#' )
#'
#' }
#'
#' @seealso
#' \code{\link{ReplicaAdder}},
#' \code{\link{ReplicaStructure}},
#' \code{\link{renew}},
#' \code{\link{enhance}},
#' \code{\link{manufacture}}
#'
#' @name ratify
NULL

#' Renew replica modules
#'
#' Updates the configuration of a replica module.
#'
#' The behaviour of \code{renew()} depends on the class of
#' the supplied object.
#'
#' Methods are currently available for:
#'
#' \itemize{
#'   \item \code{ReplicaAdder}
#'   \item \code{ReplicaStructure}
#' }
#'
#' @name renew
NULL

