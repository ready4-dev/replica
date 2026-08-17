#' Register a HouseholdType with a HouseholdGrouper
#'
#' Adds a \code{\link{HouseholdType}} object to a
#' \code{\link{HouseholdGrouper}}.
#'
#' Registered household types define the household structures
#' that may be generated during household construction.
#'
#' Multiple household types can be added to the same
#' \code{\link{HouseholdGrouper}}, allowing the synthetic
#' population to contain a mixture of household structures.
#'
#' @param object A \code{\link{HouseholdGrouper}} object.
#'
#' @param household_type A \code{\link{HouseholdType}} object.
#'
#' @return An updated \code{\link{HouseholdGrouper}} object.
#'
#' @details
#' Household types are stored internally in the
#' \code{household_types} slot.
#'
#' During execution of:
#'
#' \preformatted{
#' run(hg)
#' }
#'
#' each registered household type is processed in turn.
#'
#' Typical workflow:
#'
#' \enumerate{
#'   \item Create a \code{\link{HouseholdGrouper}}.
#'   \item Create one or more
#'         \code{\link{HouseholdType}} objects.
#'   \item Register household types using
#'         \code{addHouseholdType()}.
#'   \item Execute household generation using
#'         \code{\link{run}}.
#' }
#'
#' Household types are applied in the order in which they are
#' registered.
#'
#' @examples
#' \dontrun{
#'
#' hg <- HouseholdGrouper(
#'   df_synth_pop = pop,
#'   group_by = "neighb_code"
#' )
#'
#' hh <- HouseholdType(
#'   "CoupleHousehold"
#' )
#'
#' hh <- addMembers(
#'   hh,
#'   household_position = "Parent",
#'   position_identifier = "adult",
#'   amount = 2,
#'   backup_position_identifiers = character()
#' )
#'
#' hg <- addHouseholdType(
#'   hg,
#'   hh
#' )
#'
#' result <- run(hg)
#'
#' }
#'
#' @seealso
#' \code{\link{HouseholdGrouper}},
#' \code{\link{HouseholdType}},
#' \code{\link{addMembers}},
#' \code{\link{run}}
#'
#' @rdname addHouseholdType
#' @export
setGeneric(
  "addHouseholdType",
  function(
    object,
    household_type
  ) {
    standardGeneric("addHouseholdType")
  }
)
#' Add Margin Constraints
#'
#' Adds one or more margin tables to a
#' \code{\link{ConditionalAttributeAdder}} object.
#'
#' Margin tables are used during iterative proportional fitting
#' (IPF) workflows to align contingency tables with known
#' marginal distributions.
#'
#' @param object A \code{\link{ConditionalAttributeAdder}}
#' object.
#'
#' @param margins List of margin tables.
#'
#' Each margin table should contain a \code{count} column and
#' one or more grouping variables.
#'
#' @param margins_names List describing the variables
#' represented in each margin table.
#'
#' @return An updated
#' \code{\link{ConditionalAttributeAdder}} object.
#'
#' @details
#' Margin tables are stored internally and may subsequently be
#' used to fit contingency distributions before attribute
#' assignment.
#'
#' Typical workflow:
#'
#' \preformatted{
#' adder <- ConditionalAttributeAdder(...)
#'
#' adder <- addMargins(
#'   adder,
#'   margins = margin_tables,
#'   margins_names = margin_names
#' )
#'
#' adder <- run(adder)
#' }
#'
#' @examples
#' \dontrun{
#'
#' gender_margin <- data.frame(
#'   gender = c(
#'     "Male",
#'     "Female"
#'   ),
#'   count = c(
#'     100,
#'     120
#'   )
#' )
#'
#' adder <- addMargins(
#'   adder,
#'   margins = list(
#'     gender_margin
#'   ),
#'   margins_names = list(
#'     "gender"
#'   )
#' )
#'
#' }
#'
#' @seealso
#' \code{\link{ConditionalAttributeAdder}},
#' \code{\link{run}},
#' \code{\link{verify}}
#'
#' @rdname addMargins
#' @export
setGeneric(
  "addMargins",
  function(
    object,
    margins,
    margins_names
  ) {
    standardGeneric(
      "addMargins"
    )
  }
)

#' Add Household Members to a HouseholdType
#'
#' Defines one component of a household structure used during
#' synthetic household generation.
#'
#' Household members are registered by:
#'
#' \itemize{
#'   \item Household-position category.
#'   \item Internal position identifier.
#'   \item Required number of agents.
#'   \item Optional backup positions.
#' }
#'
#' @param object A \code{\link{HouseholdType}} object.
#'
#' @param household_position Character vector identifying
#' household-position categories.
#'
#' @param position_identifier Internal role identifier.
#'
#' Typical values include:
#'
#' \itemize{
#'   \item \code{"adult"}
#'   \item \code{"child"}
#' }
#'
#' @param amount Number of agents required for the role.
#'
#' @param backup_position_identifiers Alternative household
#' positions that may be used if the primary position pool
#' becomes exhausted.
#'
#' @return An updated \code{\link{HouseholdType}} object.
#'
#' @examples
#' \dontrun{
#'
#' hh <- HouseholdType("Family")
#'
#' hh <- addMembers(
#'   hh,
#'   household_position = "Parent",
#'   position_identifier = "adult",
#'   amount = 2,
#'   backup_position_identifiers = character()
#' )
#'
#' }
#'
#' @seealso
#' \code{\link{HouseholdType}},
#' \code{\link{createFromMembers}}
#'
#' @rdname addMembers
#' @export
setGeneric(
  "addMembers",
  
  function(
    object,
    household_position,
    position_identifier,
    amount,
    backup_position_identifiers
  ) {
    standardGeneric("addMembers")
  }
)
#' Assign Household Identifiers to Agents
#'
#' Writes household identifiers from the household structures
#' stored within a \code{\link{HouseholdType}} object back into
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
#' @param object A \code{\link{HouseholdType}} object.
#'
#' @return An updated \code{\link{HouseholdType}} object
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
#' \code{\link{run}} for
#' \code{\link{HouseholdGrouper}} objects.
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
#' \code{\link{run}},
#' \code{\link{HouseholdType}}
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
  "checkIntegrity",
  
  function(object) {
    standardGeneric("checkIntegrity")
  }
)
#' Create Households from Household Members
#'
#' Executes the household-construction workflow for a
#' \code{\link{HouseholdType}}.
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
#' @param object A \code{\link{HouseholdType}} object.
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
#'     Updated \code{\link{HouseholdType}} object.
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
#' @export
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
#' \code{\link{HouseholdType}} object.
#'
#' Household positions are created using
#' \code{\link{addMembers}} and describe the composition of a
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
#' @param object A \code{\link{HouseholdType}} object.
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
#' hh <- HouseholdType(
#'   "Family"
#' )
#'
#' hh <- addMembers(
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
#' \code{\link{addMembers}},
#' \code{\link{HouseholdType}}
#'
#' @rdname getPositionForName
#' @export
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
#' records stored within a \code{\link{HouseholdType}} object.
#'
#' Each row in the returned data frame represents a single
#' synthetic household and contains summary information such as
#' household identifier, household type and household size.
#'
#' This method is typically called after household generation
#' and household assignment have been completed.
#'
#' @param object A \code{\link{HouseholdType}} object.
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
#' \code{\link{HouseholdType}}
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
#' Execute a replica Workflow
#'
#' Executes a workflow represented by a supported replica
#' object.
#'
#' The specific behaviour depends on the class of the supplied
#' object.
#'
#' Current implementations include:
#'
#' \itemize{
#'   \item \code{\link{ConditionalAttributeAdder}}
#'   \item \code{\link{HouseholdGrouper}}
#' }
#'
#' @param object A supported replica workflow object.
#'
#' @return Depends on the class of \code{object}.
#'
#' \describe{
#'   \item{\code{ConditionalAttributeAdder}}{
#'     Returns an updated
#'     \code{\link{ConditionalAttributeAdder}} object.
#'   }
#'
#'   \item{\code{HouseholdGrouper}}{
#'     Returns a list containing:
#'     \itemize{
#'       \item Synthetic population.
#'       \item Synthetic household table.
#'       \item Updated HouseholdGrouper object.
#'     }
#'   }
#' }
#'
#' @details
#' The \code{run()} generic provides a unified execution
#' interface for major replica workflows.
#'
#' Method dispatch determines the specific implementation used.
#'
#' @examples
#' \dontrun{
#'
#' # -----------------------------------
#' # ConditionalAttributeAdder workflow
#' # -----------------------------------
#'
#' adder <- ConditionalAttributeAdder(
#'   synth_pop = population,
#'   contingency = contingency,
#'   target_attribute = "education",
#'   group_by = c(
#'     "age_group",
#'     "gender"
#'   ),
#'   missing_group_strategy = "borrow"
#' )
#'
#' adder <- run(adder)
#'
#' result <- adder@synth_pop
#'
#' table(result$education)
#'
#'
#' # -----------------------------------
#' # HouseholdGrouper workflow
#' # -----------------------------------
#'
#' hg <- HouseholdGrouper(
#'   df_synth_pop = pop,
#'   group_by = "neighb_code"
#' )
#'
#' hh <- HouseholdType(
#'   "CoupleHousehold"
#' )
#'
#' hh <- addMembers(
#'   hh,
#'   household_position = "Parent",
#'   position_identifier = "adult",
#'   amount = 2,
#'   backup_position_identifiers = character()
#' )
#'
#' hh@couple_gender_distribution <- c(
#'   "Male|Female" = 1
#' )
#'
#' hh@couple_age_distribution <- c(
#'   "-5-5" = 1
#' )
#'
#' hg <- addHouseholdType(
#'   hg,
#'   hh
#' )
#'
#' result <- run(
#'   hg
#' )
#'
#' synthetic_population <-
#'   result$synthetic_population
#'
#' synthetic_households <-
#'   result$synthetic_households
#'
#' }
#'
#' @seealso
#' \code{\link{ConditionalAttributeAdder}},
#' \code{\link{HouseholdGrouper}}
#'
#' @rdname run
#' @export
setGeneric(
  "run",
  function(object)
    standardGeneric("run")
)
#' Update HouseholdType State
#'
#' Attaches a synthetic population and household-position
#' column to a \code{\link{HouseholdType}} object.
#'
#' This method is typically called prior to household
#' generation.
#'
#' @param object A \code{\link{HouseholdType}} object.
#'
#' @param df_synth_pop Synthetic population.
#'
#' @param household_position_column Character string
#' identifying the household-position column.
#'
#' @return An updated \code{\link{HouseholdType}} object.
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
#' \code{\link{createFromMembers}},
#' \code{\link{HouseholdType}}
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
#' Verify Synthetic Attribute Assignment
#'
#' Performs validation checks on the results of a conditional
#' attribute-assignment workflow.
#'
#' This method is typically executed automatically by
#' \code{\link{run}} and is responsible for identifying
#' potential issues in the generated synthetic population.
#'
#' Validation may include:
#'
#' \itemize{
#'   \item Checking for missing target-attribute values.
#'   \item Comparing the synthetic distribution against the
#'         source contingency table.
#'   \item Assessing goodness-of-fit statistics.
#'   \item Confirming population totals are preserved.
#' }
#'
#' @param object A \code{\link{ConditionalAttributeAdder}}
#' object.
#'
#' @return The supplied
#' \code{\link{ConditionalAttributeAdder}} object.
#'
#' @details
#' The verification process is intended to identify situations
#' where the generated synthetic population differs
#' substantially from the intended distribution.
#'
#' The method may generate warnings when:
#'
#' \itemize{
#'   \item Target-attribute assignments are missing.
#'   \item Contingency distributions differ substantially from
#'         the expected values.
#'   \item Population totals are inconsistent.
#' }
#'
#' Statistical validation utilities used by this workflow may
#' include:
#'
#' \itemize{
#'   \item \code{\link{synthetic_population_to_contingency}}
#'   \item \code{\link{validate_synthetic_population_fit}}
#'   \item \code{\link{calculate_z_squared_score}}
#' }
#'
#' @examples
#' \dontrun{
#'
#' adder <- ConditionalAttributeAdder(
#'   synth_pop = population,
#'   contingency = contingency,
#'   target_attribute = "education",
#'   group_by = c(
#'     "age_group",
#'     "gender"
#'   )
#' )
#'
#' adder <- run(adder)
#'
#' adder <- verify(adder)
#'
#' }
#'
#' @seealso
#' \code{\link{run}},
#' \code{\link{ConditionalAttributeAdder}},
#' \code{\link{synthetic_population_to_contingency}},
#' \code{\link{validate_synthetic_population_fit}},
#' \code{\link{calculate_z_squared_score}}
#'
#' @rdname verify
#' @export
setGeneric(
  "verify",
  function(object)
    standardGeneric("verify")
)
