
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
#' created using \code{\link{householdsToDataFrame}}.
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
#' \code{\link{householdsToDataFrame}},
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
# setGeneric(
#   "checkIntegrity",
#   
#   function(object) {
#     standardGeneric("checkIntegrity")
#   }
# )
#' Create Households from Household Members
#'
#' Executes the household-construction workflow for a
#' \code{\link{ReplicaStructure}}.
#'
#' Depending on the household definition, this method may:
#'
#' \itemize{
#'   \item Create single-adult households.
#'   \item Create couples.
#'   \item Group children.
#'   \item Match adults and children.
#'   \item Create household records.
#' }
#'
#' @param object A \code{\link{ReplicaStructure}} object.
#'
#' @param mask Logical vector identifying agents eligible for
#' household generation.
#'
#' @param id_offset Integer household-ID offset.
#'
#' @return A list containing:
#'
#' \describe{
#'   \item{object}{
#'     Updated \code{\link{ReplicaStructure}} object.
#'   }
#'   \item{id_offset}{
#'     Updated household identifier offset.
#'   }
#' }
#'
#' @details
#' Adult households are generated first.
#'
#' If children are present, sibling groups are created and
#' matched to the adult groups.
#'
#' The resulting households are stored in the
#' \code{households} slot.
#'
#' @examples
#' \dontrun{
#'
#' result <- createFromMembers(
#'   hh,
#'   mask = rep(TRUE, nrow(pop)),
#'   id_offset = 1
#' )
#'
#' hh <- result$object
#'
#' }
#'
#' @seealso
#' \code{\link{pair_partners}},
#' \code{\link{group_children}},
#' \code{\link{matchAdultsWithChildren}}
#'
#' @rdname createFromMembers
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
#' Retrieve a Household Position Definition
#'
#' Returns a household-position definition stored within a
#' \code{\link{ReplicaStructure}} object.
#'
#' Household positions are created using
#' \code{\link{renew}} and describe the composition of a
#' household type.
#'
#' Typical position identifiers include:
#'
#' \itemize{
#'   \item \code{"adult"}
#'   \item \code{"child"}
#' }
#'
#' The returned object contains:
#'
#' \describe{
#'   \item{position_identifier}{
#'     Internal role identifier.
#'   }
#'
#'   \item{position}{
#'     Household-position value(s) used in the synthetic
#'     population.
#'   }
#'
#'   \item{amount}{
#'     Number of agents required for the role.
#'   }
#'
#'   \item{backup_position_identifiers}{
#'     Alternative household-position categories that may be
#'     used if suitable agents cannot be found in the primary
#'     candidate pool.
#'   }
#' }
#'
#' @param object A \code{\link{ReplicaStructure}} object.
#'
#' @param position Character string identifying the required
#' household role.
#'
#' Typical values include:
#'
#' \itemize{
#'   \item \code{"adult"}
#'   \item \code{"child"}
#' }
#'
#' @return A list describing the requested household-position
#' definition.
#'
#' @details
#' Household-position definitions are stored internally and are
#' referenced extensively throughout the household-generation
#' workflow.
#'
#' This method is used by:
#'
#' \itemize{
#'   \item \code{\link{pair_partners}}
#'   \item \code{\link{group_children}}
#'   \item \code{\link{matchAdultsWithChildren}}
#' }
#'
#' An error is raised if the requested position identifier does
#' not exist.
#'
#' @examples
#' \dontrun{
#'
#' hh <- ReplicaStructure(
#'   "Family"
#' )
#'
#' hh <- renew(
#'   hh,
#'   household_position = "Parent",
#'   position_identifier = "adult",
#'   amount = 2,
#'   backup_position_identifiers = character()
#' )
#'
#' adult_position <- getPositionForName(
#'   hh,
#'   "adult"
#' )
#' 
#' adult_position$amount
#' 
#' }
#'
#' @seealso
#' \code{\link{renew}},
#' \code{\link{ReplicaStructure}}
#'
#' @rdname getPositionForName
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
#' Convert Synthetic Households to a Data Frame
#'
#' Creates a household-level summary table from the household
#' records stored within a \code{\link{ReplicaStructure}} object.
#'
#' Each row in the returned data frame represents a single
#' synthetic household and contains summary information such as
#' household identifier, household type and household size.
#'
#' This method is typically called after household generation
#' and household assignment have been completed.
#'
#' @param object A \code{\link{ReplicaStructure}} object.
#'
#' @return A data frame containing one row per household.
#'
#' The returned table contains:
#'
#' \describe{
#'   \item{household_id}{
#'     Unique household identifier.
#'   }
#'
#'   \item{neighb_code}{
#'     Neighbourhood identifier associated with the household.
#'   }
#'
#'   \item{hh_type}{
#'     Household type.
#'   }
#'
#'   \item{hh_size}{
#'     Number of agents assigned to the household.
#'   }
#' }
#'
#' @details
#' Household size is calculated as:
#'
#' \preformatted{
#' length(household$all)
#' }
#'
#' where \code{household$all} contains the identifiers of all
#' household members.
#'
#' The neighbourhood code is obtained from the first household
#' member and is assumed to be common to all members of the
#' household.
#'
#' If no households have been generated, an empty data frame
#' with the expected columns is returned.
#'
#' This method is typically used after:
#'
#' \enumerate{
#'   \item Household generation.
#'   \item \code{\link{agentToHousehold}}.
#'   \item Household validation.
#' }
#'
#' @examples
#' \dontrun{
#'
#' households <- householdsToDataFrame(
#'   hh
#' )
#'
#' head(households)
#'
#' }
#'
#' @seealso
#' \code{\link{agentToHousehold}},
#' \code{\link{create_household_with_id}},
#' \code{\link{ReplicaStructure}}
#'
#' @rdname householdsToDataFrame
#' @export
setGeneric(
  "householdsToDataFrame",
  function(object) {
    standardGeneric(
      "householdsToDataFrame"
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
