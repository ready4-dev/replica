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
#'   \item \code{ReplicaStructure}
#'   \item \code{ReplicaGrouper}
#' }
#'
#' @details
#'
#' `manufacture()` is used when a replica module generates
#' a new output object rather than updating itself.
#'
#' Depending on the module supplied, the method may:
#'
#' \itemize{
#'   \item create household-level summary tables; or
#'   \item generate complete synthetic household outputs.
#' }
#'
#' @seealso
#' \code{\link{ReplicaStructure}},
#' \code{\link{ReplicaGrouper}},
#' \code{\link{renew}},
#' \code{\link{ratify}}
#'
#' @name manufacture
NULL

#' Procure Components of Replica Modules
#'
#' Retrieves information stored within a replica module.
#'
#' The behaviour of `procure()` depends on the class of the
#' supplied object.
#'
#' Methods are currently available for:
#'
#' \itemize{
#'   \item \code{ReplicaAdder}
#'   \item \code{ReplicaStructure}
#'   \item \code{ReplicaGrouper}
#' }
#'
#' @details
#'
#' `procure()` is the primary method used to retrieve
#' information from replica modules.
#'
#' Components are retrieved by supplying the name of a
#' module slot.
#'
#' It provides a consistent alternative to direct slot
#' access and supports a ready4-style workflow for working
#' with replica modules.
#'
#' Together with \code{\link{renew}}, `procure()` forms the
#' primary interface for accessing and updating
#' replica-module contents.
#'
#' @section ReplicaAdder Method:
#'
#' For a \code{ReplicaAdder}, \code{procure()} can be used
#' to retrieve stored components such as:
#'
#' \itemize{
#'   \item synthetic populations;
#'   \item contingency tables;
#'   \item marginal distributions; and
#'   \item validation results.
#' }
#'
#' @section ReplicaStructure Method:
#'
#' For a \code{ReplicaStructure}, \code{procure()} can be
#' used to retrieve stored information on:
#'
#' \itemize{
#'   \item household definitions;
#'   \item household positions;
#'   \item household assignments; and
#'   \item household-generation state.
#' }
#'
#' @section ReplicaGrouper Method:
#'
#' For a \code{ReplicaGrouper}, \code{procure()} can be used
#' to retrieve:
#'
#' \itemize{
#'   \item synthetic populations;
#'   \item grouping definitions;
#'   \item registered structures; and
#'   \item household-generation settings.
#' }
#'
#' @param x A replica module.
#'
#' @param slot Character string specifying the slot to
#' retrieve.
#'
#' @param ... Additional arguments passed to the method.
#'
#' @return The contents of the requested slot.
#'
#' @examples
#' \dontrun{
#'
#' procure(
#'   ADDER,
#'   slot = "validation_results"
#' )
#'
#' procure(
#'   STRUCTURE,
#'   slot = "households"
#' )
#'
#' procure(
#'   GROUPER,
#'   slot = "population"
#' )
#'
#' }
#'
#' @seealso
#' \code{\link{renew}},
#' \code{\link{enhance}},
#' \code{\link{ratify}},
#' \code{\link{manufacture}}
#'
#' @name procure
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
#' procure(ADDER, "validation_results")
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
#' ADDER <- enhance(ADDER)
#'
#' ADDER <- ratify(
#'   ADDER
#' )
#'
#' procure(ADDER, "validation_results")
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

#' Renew Replica Modules
#'
#' Updates the configuration, contents or state of a replica
#' module.
#'
#' The behaviour of `renew()` depends on the class of the
#' supplied object.
#'
#' Methods are currently available for:
#'
#' \itemize{
#'   \item \code{ReplicaAdder}
#'   \item \code{ReplicaStructure}
#'   \item \code{ReplicaGrouper}
#' }
#'
#' @details
#'
#' `renew()` is the primary method used to modify replica
#' modules while preserving their underlying class and
#' structure.
#'
#' Depending on the supplied module and arguments,
#' `renew()` can be used to:
#'
#' \itemize{
#'   \item update one or more module slots;
#'   \item add marginal distributions to a
#'   \code{ReplicaAdder};
#'   \item define household-member requirements in a
#'   \code{ReplicaStructure};
#'   \item update household-generation state;
#'   \item transfer household assignments to synthetic
#'   populations; and
#'   \item register \code{ReplicaStructure} objects with a
#'   \code{ReplicaGrouper}.
#' }
#'
#' Slot updates are performed by supplying named arguments
#' corresponding to valid module slots.
#'
#' For example:
#'
#' \preformatted{
#' x <- renew(
#'   x,
#'   population = population
#' )
#' }
#'
#' Additional class-specific operations are available via
#' the \code{what} argument.
#'
#' Together with \code{\link{procure}}, `renew()` forms the
#' primary interface for reading and updating replica-module
#' contents.
#'
#' @seealso
#' \code{\link{procure}},
#' \code{\link{enhance}},
#' \code{\link{ratify}},
#' \code{\link{manufacture}}
#'
#' @name renew
NULL
