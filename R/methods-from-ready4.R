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

#' Ratify Attribute Assignment Results
#'
#' Evaluates the quality of attribute assignment performed by a
#' \code{ReplicaAdder} and stores validation diagnostics within
#' the module.
#'
#' The \code{ratify()} method compares the observed
#' distributions in the synthetic population with the expected
#' distributions supplied via the reference contingency table.
#'
#' Validation results are stored in the
#' \code{validation_results} slot and include:
#'
#' \itemize{
#'   \item goodness-of-fit statistics;
#'   \item p-values;
#'   \item warning flags; and
#'   \item detailed comparisons of observed and expected
#'   distributions.
#' }
#'
#' These diagnostics can subsequently be explored using the
#' validation and visualisation tools bundled with
#' \code{replica}.
#'
#' @section ReplicaAdder:
#'
#' For a \code{ReplicaAdder}, \code{ratify()}:
#'
#' \enumerate{
#'   \item checks the assigned synthetic population;
#'   \item compares observed and expected distributions;
#'   \item calculates validation statistics;
#'   \item stores validation results; and
#'   \item returns the updated module.
#' }
#'
#' Validation results are stored in:
#'
#' \preformatted{
#' x@validation_results
#' }
#'
#' and may be inspected using:
#'
#' \preformatted{
#' names(x@validation_results)
#' }
#'
#' @param x A \code{ReplicaAdder} object.
#' @param ... Additional arguments passed to the generic
#' method.
#'
#' @return An updated \code{ReplicaAdder}.
#'
#' @examples
#' \dontrun{
#'
#' adder <- ReplicaAdder(
#'   synth_pop = population,
#'   contingency = contingency,
#'   target_attribute = "education",
#'   group_by = c(
#'     "age_group",
#'     "gender"
#'   )
#' )
#'
#' adder <- enhance(adder)
#'
#' adder <- ratify(adder)
#'
#' adder@validation_results
#' }
#'
#' @seealso
#' \code{\link{ReplicaAdder}},
#' \code{\link{validate_synthetic_population_fit}},
#' \code{\link{plot_validation_distributions}},
#' \code{\link{plot_validation_differences}},
#' \code{\link{plot_validation_heatmap}}
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

