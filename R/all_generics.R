
#' Assign Household Identifiers to Agents
#'
#' Writes household identifiers from the household structures
#' stored within a \code{\link{ReplicaStructure}} object back into
#' the associated synthetic population.
#'
#' Each agent belonging to a generated household receives a
#' value in the \code{household_id} column corresponding to the
#' household to which they belong.
#'
#' This method is typically called after household generation
#' has completed and before household-level summary tables are
#' created using \code{\link{manufacture}}.
#'
#' @param object A \code{\link{ReplicaStructure}} object.
#'
#' @return An updated \code{\link{ReplicaStructure}} object
#' containing household identifiers in the synthetic population.
#'
#' @details
#' Household identifiers are obtained from the
#' \code{households} slot.
#'
#' For each household:
#'
#' \enumerate{
#'   \item Household members listed in
#'         \code{household$all} are identified.
#'   \item The corresponding household identifier is written to
#'         the synthetic population.
#' }
#'
#' After execution, household assignments can be accessed via:
#'
#' \preformatted{
#' object@df_synth_pop$household_id
#' }
#'
#' This method is used as part of the household-generation
#' workflow implemented by
#' \code{\link{enhance}} for
#' \code{\link{ReplicaGrouper}} objects.
#'
#' @examples
#' \dontrun{
#'
#' hh <- agentToHousehold(
#'   hh
#' )
#'
#' head(
#'   hh@df_synth_pop
#' )
#'
#' }
#'
#' @seealso
#' \code{\link{manufacture}},
#' \code{\link{create_household_with_id}},
#' \code{\link{enhance}},
#' \code{\link{ReplicaStructure}}
#'
#' @rdname agentToHousehold
#' @export
setGeneric(
  "agentToHousehold",
  function(object) {
    standardGeneric(
      "agentToHousehold"
    )
  }
)

setGeneric(
  "createFromMembers",
  
  function(
    object,
    mask,
    id_offset
  ) {
    standardGeneric("createFromMembers")
  }
)
setGeneric(
  "getAllAgents",
  function(object) {
    standardGeneric(
      "getAllAgents"
    )
  }
)
setGeneric(
  "getBaseAdultMask",
  function(
    object,
    strict = TRUE
  ) {
    standardGeneric(
      "getBaseAdultMask"
    )
  }
)
setGeneric(
  "getBaseChildMask",
  function(object) {
    standardGeneric(
      "getBaseChildMask"
    )
  }
)

setGeneric(
  "getPositionForName",
  function(
    object,
    position
  ) {
    standardGeneric(
      "getPositionForName"
    )
  }
)

setGeneric(
  "maskWithRemainingAgents",
  function(
    object,
    df,
    mask
  ) {
    standardGeneric(
      "maskWithRemainingAgents"
    )
  }
)
#' Update ReplicaStructure State
#'
#' Attaches a synthetic population and household-position
#' column to a \code{\link{ReplicaStructure}} object.
#'
#' This method is typically called prior to household
#' generation.
#'
#' @param object A \code{\link{ReplicaStructure}} object.
#'
#' @param df_synth_pop Synthetic population.
#'
#' @param household_position_column Character string
#' identifying the household-position column.
#'
#' @return An updated \code{\link{ReplicaStructure}} object.
#'
#' @examples
#' \dontrun{
#'
#' hh <- updateState(
#'   hh,
#'   pop,
#'   "household_position"
#' )
#'
#' }
#'
#' @seealso
#' \code{\link{ReplicaStructure}}
#'
#' @rdname updateState
#' @export
setGeneric(
  "updateState",
  
  function(
    object,
    df_synth_pop,
    household_position_column
  ) {
    standardGeneric("updateState")
  }
)
