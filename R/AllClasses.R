#' Conditional Attribute Adder
#'
#' Represents a conditional attribute assignment workflow for
#' synthetic population generation.
#'
#' A \code{ConditionalAttributeAdder} object adds a target
#' attribute to an existing synthetic population using one or
#' more contingency tables and, optionally, margin constraints.
#'
#' Attributes are assigned conditionally on one or more
#' previously-generated attributes specified by
#' \code{group_by}.
#'
#' Missing contingency groups can be handled using configurable
#' strategies:
#'
#' \describe{
#'   \item{borrow}{
#'     Borrow the nearest available conditional distribution.
#'   }
#'   \item{overall}{
#'     Use the overall target distribution.
#'   }
#'   \item{error}{
#'     Stop with an error.
#'   }
#' }
#'
#' @slot synth_pop A synthetic population stored as a
#' \code{data.table}.
#'
#' @slot contingency A contingency table containing the target
#' attribute distribution.
#'
#' @slot target_attribute Character string identifying the
#' attribute to be added.
#'
#' @slot group_by Character vector containing conditioning
#' variables.
#'
#' @slot margins List of margin tables used for IPF fitting.
#'
#' @slot margins_names Names corresponding to supplied margin
#' tables.
#'
#' @slot margins_group Grouping variables present in supplied
#' margins.
#'
#' @slot missing_group_strategy Strategy used when a
#' conditioning group is absent from the contingency table.
#'
#' @details
#' ConditionalAttributeAdder forms the core of the replica
#' attribute-generation workflow.
#'
#' The object:
#'
#' \enumerate{
#'   \item Validates contingency information.
#'   \item Resolves missing conditioning groups.
#'   \item Computes conditional fractions.
#'   \item Converts fractions to agent counts.
#'   \item Assigns target attribute values.
#'   \item Verifies the resulting distribution.
#' }
#'
#' @seealso
#' \code{\link{run}},
#' \code{\link{addMargins}},
#' \code{\link{verify}},
#' \code{\link{prepareContingencyTable}}
#'
#' @export
setClass(
  "ConditionalAttributeAdder",
  
  slots = c(
    
    synth_pop = "data.table",
    
    contingency = "data.table",
    
    target_attribute = "character",
    
    group_by = "character",
    
    margins = "list",
    
    margins_names = "list",
    
    margins_group = "character",
    
    missing_group_strategy = "character"
    
  )
)
#' Create a ConditionalAttributeAdder Object
#'
#' Creates a new \code{ConditionalAttributeAdder} used to add a
#' target attribute to an existing synthetic population from a
#' contingency table.
#'
#' The resulting object stores the synthetic population,
#' contingency table and assignment settings required for
#' conditional attribute generation.
#'
#' After construction, the object is typically executed using
#' \code{\link{run}}.
#'
#' @param synth_pop A synthetic population stored as a data.frame
#' or \code{data.table}. Each row represents a single synthetic
#' agent.
#'
#' @param contingency A contingency table containing the target
#' attribute and a \code{count} column.
#'
#' The contingency table defines the joint distribution of the
#' target attribute and the specified conditioning variables.
#'
#' @param target_attribute Character string identifying the
#' attribute to be added to the synthetic population.
#'
#' @param group_by Character vector containing the conditioning
#' variables used during attribute assignment.
#'
#' @param missing_group_strategy Character string specifying
#' how conditioning groups present in the synthetic population
#' but absent from the contingency table should be handled.
#'
#' One of:
#'
#' \itemize{
#'   \item \code{"borrow"} (default)
#'   \item \code{"overall"}
#'   \item \code{"error"}
#' }
#'
#' @return A \code{ConditionalAttributeAdder} object.
#'
#' @details
#' During execution, the object:
#'
#' \enumerate{
#'   \item Partitions the synthetic population using
#'         \code{group_by}.
#'   \item Obtains conditional distributions from the
#'         contingency table.
#'   \item Converts distributions into integer agent counts.
#'   \item Assigns target-attribute values.
#'   \item Validates the resulting synthetic population.
#' }
#'
#' Missing contingency groups may be handled as follows:
#'
#' \describe{
#'   \item{borrow}{
#'     Borrow the nearest available conditional distribution.
#'   }
#'   \item{overall}{
#'     Use the overall target-attribute distribution.
#'   }
#'   \item{error}{
#'     Stop with an error if a required group is missing.
#'   }
#' }
#'
#' Margin constraints can be added after construction using
#' \code{\link{addMargins}}.
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
#'   ),
#'   missing_group_strategy = "borrow"
#' )
#'
#' adder <- run(adder)
#'
#' result <- adder@synth_pop
#'
#' }
#'
#' @seealso
#' \code{\link{run}},
#' \code{\link{addMargins}},
#' \code{\link{verify}},
#' \code{\link{prepareContingencyTable}},
#' \code{\link{ConditionalAttributeAdder-class}}
#'
#' @export
ConditionalAttributeAdder <- function(
    synth_pop,
    contingency,
    target_attribute,
    group_by = character(),
    missing_group_strategy = "borrow"
) {
  
  new(
    
    "ConditionalAttributeAdder",
    
    synth_pop = as.data.table(
      synth_pop
    ),
    
    contingency = as.data.table(
      contingency
    ),
    
    target_attribute = target_attribute,
    
    group_by = group_by,
    
    margins = list(),
    
    margins_names = list(),
    
    margins_group = group_by,
    
    missing_group_strategy =
      missing_group_strategy
    
  )
  
}
setValidity(
  "ConditionalAttributeAdder",
  
  function(object) {
    
    #
    # Single target attribute
    #
    
    if (
      length(
        object@target_attribute
      ) != 1
    ) {
      
      return(
        "target_attribute must contain exactly one value"
      )
      
    }
    
    #
    # Count column exists
    #
    
    if (
      !"count" %in%
      names(
        object@contingency
      )
    ) {
      
      return(
        "contingency table must contain a count column"
      )
      
    }
    
    #
    # group_by provided
    #
    
    if (
      length(
        object@group_by
      ) == 0
    ) {
      
      return(
        "group_by must contain at least one variable"
      )
      
    }
    
    #
    # group_by variables exist
    # in synthetic population
    #
    
    missing_pop_groups <-
      
      setdiff(
        
        object@group_by,
        
        names(
          object@synth_pop
        )
        
      )
    
    if (
      length(
        missing_pop_groups
      ) > 0
    ) {
      
      return(
        
        paste(
          
          "Missing group_by variables in synth_pop:",
          
          paste(
            missing_pop_groups,
            collapse = ", "
          )
          
        )
        
      )
      
    }
    
    #
    # group_by variables exist
    # in contingency table
    #
    
    missing_cont_groups <-
      
      setdiff(
        
        object@group_by,
        
        names(
          object@contingency
        )
        
      )
    
    if (
      length(
        missing_cont_groups
      ) > 0
    ) {
      
      return(
        
        paste(
          
          "Missing group_by variables in contingency:",
          
          paste(
            missing_cont_groups,
            collapse = ", "
          )
          
        )
        
      )
      
    }
    
    #
    # Missing-group strategy
    #
    
    if (
      
      !object@missing_group_strategy %in%
      
      c(
        "borrow",
        "overall",
        "error"
      )
      
    ) {
      
      return(
        
        paste(
          
          "missing_group_strategy must be one of:",
          
          "borrow, overall, error"
          
        )
        
      )
      
    }
    
    TRUE
    
  }
  
)

#' HouseholdGrouper Class
#'
#' Coordinates the generation of synthetic households from a
#' synthetic population.
#'
#' A \code{HouseholdGrouper} object manages one or more
#' \code{\link{HouseholdType}} objects and applies household
#' generation algorithms across user-defined population groups.
#'
#' The class is responsible for:
#'
#' \itemize{
#'   \item Managing the synthetic population.
#'   \item Coordinating household generation workflows.
#'   \item Applying household-generation rules within geographic
#'         or demographic groups.
#'   \item Assigning household identifiers.
#'   \item Producing household-level summary tables.
#' }
#'
#' @slot df_synth_pop Synthetic population stored as a
#' \code{data.table}.
#'
#' @slot group_by Character vector specifying the variables used
#' to partition the synthetic population during household
#' generation.
#'
#' Typical examples include:
#'
#' \itemize{
#'   \item \code{"neighb_code"}
#'   \item \code{"sa2_code"}
#'   \item Geographic or administrative identifiers
#' }
#'
#' @slot target_column Character string identifying the column
#' containing household-position classifications such as
#' \code{"Parent"}, \code{"Child"} or \code{"SingleAdult"}.
#'
#' @slot household_types List of
#' \code{\link{HouseholdType}} objects used during household
#' generation.
#'
#' @details
#' Household generation typically proceeds as follows:
#'
#' \enumerate{
#'   \item Create a \code{HouseholdGrouper}.
#'   \item Create one or more
#'         \code{\link{HouseholdType}} objects.
#'   \item Register the household types using
#'         \code{\link{addHouseholdType}}.
#'   \item Execute household generation using
#'         \code{\link{run}}.
#' }
#'
#' During execution:
#'
#' \enumerate{
#'   \item The synthetic population is partitioned according to
#'         \code{group_by}.
#'   \item Households are generated independently within each
#'         group.
#'   \item Household identifiers are assigned.
#'   \item Household-level summary tables are generated.
#' }
#'
#' Results are returned as:
#'
#' \itemize{
#'   \item A synthetic population containing household IDs.
#'   \item A synthetic household table.
#' }
#'
#' @examples
#' \dontrun{
#'
#' hg <- HouseholdGrouper(
#'   df_synth_pop = pop,
#'   group_by = "neighb_code"
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
#' }
#'
#' @seealso
#' \code{\link{HouseholdGrouper}},
#' \code{\link{HouseholdType}},
#' \code{\link{addHouseholdType}},
#' \code{\link{run}}
#'
#' @export
setClass(
  "HouseholdGrouper",
  
  slots = c(
    
    df_synth_pop = "data.table",
    
    group_by = "character",
    
    target_column = "character",
    
    household_types = "list"
  )
)
setValidity(
  "HouseholdGrouper",
  
  function(object) {
    
    #
    # group_by variables exist
    #
    
    missing_cols <-
      
      setdiff(
        
        object@group_by,
        
        names(
          object@df_synth_pop
        )
        
      )
    
    if (
      length(
        missing_cols
      ) > 0
    ) {
      
      return(
        
        paste(
          
          "Missing grouping variables:",
          
          paste(
            missing_cols,
            collapse = ", "
          )
          
        )
        
      )
      
    }
    
    #
    # target column name
    #
    
    if (
      length(
        object@target_column
      ) != 1
    ) {
      
      return(
        "target_column must contain exactly one value"
      )
      
    }
    
    #
    # household_types must be a list
    #
    
    if (
      !is.list(
        object@household_types
      )
    ) {
      
      return(
        "household_types must be a list"
      )
      
    }
    
    TRUE
    
  }
  
)
#' Create a HouseholdGrouper Object
#'
#' Creates a new \code{HouseholdGrouper} used to generate
#' synthetic households from an existing synthetic population.
#'
#' The resulting object acts as the top-level coordinator of the
#' household-generation workflow and manages one or more
#' \code{\link{HouseholdType}} objects.
#'
#' @param df_synth_pop A synthetic population stored as a
#' data.frame or \code{data.table}.
#'
#' Each row should represent a single synthetic agent.
#'
#' @param group_by Character vector specifying the variables used
#' to partition the population during household generation.
#'
#' Typical examples include:
#'
#' \itemize{
#'   \item \code{"neighb_code"}
#'   \item \code{"sa2_code"}
#'   \item Other geographic identifiers
#' }
#'
#' Household generation is performed independently within each
#' grouping combination.
#'
#' @param target_column Character string identifying the column
#' containing household-position classifications.
#'
#' Typical values include:
#'
#' \itemize{
#'   \item \code{"Parent"}
#'   \item \code{"Child"}
#'   \item \code{"SingleAdult"}
#' }
#'
#' Defaults to:
#'
#' \preformatted{
#' "household_position"
#' }
#'
#' @return A new \code{HouseholdGrouper} object.
#'
#' @details
#' The constructor:
#'
#' \enumerate{
#'   \item Stores the synthetic population.
#'   \item Stores grouping information.
#'   \item Initializes the household-type list.
#'   \item Creates an empty \code{household_id} column if one
#'         does not already exist.
#' }
#'
#' Household types are subsequently registered using
#' \code{\link{addHouseholdType}}.
#'
#' The resulting object is typically executed using
#' \code{\link{run}}.
#'
#' @examples
#' \dontrun{
#'
#' library(data.table)
#'
#' pop <- data.table(
#'   agent_id = 1:100,
#'   neighb_code = sample(
#'     c("N1", "N2"),
#'     100,
#'     replace = TRUE
#'   )
#' )
#'
#' hg <- HouseholdGrouper(
#'   df_synth_pop = pop,
#'   group_by = "neighb_code"
#' )
#'
#' }
#'
#' @seealso
#' \code{\link{HouseholdGrouper-class}},
#' \code{\link{HouseholdType}},
#' \code{\link{addHouseholdType}},
#' \code{\link{run}}
#'
#' @export
HouseholdGrouper <- function(
    df_synth_pop,
    group_by,
    target_column = "household_position"
) {
  
  df_synth_pop <-
    data.table::as.data.table(
      df_synth_pop
    )
  
  if (!"household_id" %in%
      names(df_synth_pop)) {
    
    df_synth_pop[
      ,
      household_id := NA_character_
    ]
  }
  
  new(
    "HouseholdGrouper",
    
    df_synth_pop = df_synth_pop,
    
    group_by = group_by,
    
    target_column = target_column,
    
    household_types = list()
  )
}
#' HouseholdType Class
#'
#' Represents a household structure used during synthetic
#' household generation.
#'
#' A \code{HouseholdType} object stores:
#'
#' \itemize{
#'   \item Household composition requirements.
#'   \item Household-position definitions.
#'   \item Partner matching distributions.
#'   \item Parent-child matching distributions.
#'   \item Generated household records.
#'   \item Household assignment state.
#' }
#'
#' Household types are used by
#' \code{\link{HouseholdGrouper}} to create synthetic
#' households from an existing synthetic population.
#'
#' Typical examples include:
#'
#' \itemize{
#'   \item Couple household.
#'   \item Single-adult household.
#'   \item Family household.
#'   \item Single-parent household.
#' }
#'
#' @slot hh_type Character string identifying the household
#' type.
#'
#' @slot positions List of household-position definitions
#' created via \code{\link{addMembers}}.
#'
#' @slot position_identifiers Named list mapping position
#' identifiers such as \code{"adult"} and \code{"child"} to
#' entries in \code{positions}.
#'
#' @slot households List containing generated household
#' records.
#'
#' @slot sampled_agents Character vector containing agents
#' already assigned during household generation.
#'
#' @slot couple_gender_distribution Named numeric vector
#' controlling gender composition of generated couples.
#'
#' @slot couple_age_distribution Named numeric vector
#' controlling partner age-gap distributions.
#'
#' @slot parent_child_age_distribution Named numeric vector
#' controlling parent-child age-gap distributions.
#'
#' @slot df_synth_pop Synthetic population used during
#' household generation.
#'
#' @slot household_position_column Character string
#' identifying the household-position column in the synthetic
#' population.
#'
#' @details
#' Household generation typically proceeds as follows:
#'
#' \enumerate{
#'   \item Create a \code{HouseholdType}.
#'   \item Define household positions using
#'         \code{\link{addMembers}}.
#'   \item Configure distributions.
#'   \item Attach a synthetic population using
#'         \code{\link{updateState}}.
#'   \item Generate households using
#'         \code{\link{createFromMembers}}.
#' }
#'
#' Generated households are stored internally and can be
#' exported using:
#'
#' \itemize{
#'   \item \code{\link{agentToHousehold}}
#'   \item \code{\link{householdsToDataFrame}}
#' }
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
#' hh <- addMembers(
#'   hh,
#'   household_position = "Child",
#'   position_identifier = "child",
#'   amount = 2,
#'   backup_position_identifiers = character()
#' )
#'
#' }
#'
#' @seealso
#' \code{\link{HouseholdType}},
#' \code{\link{HouseholdGrouper}},
#' \code{\link{addMembers}},
#' \code{\link{createFromMembers}},
#' \code{\link{agentToHousehold}},
#' \code{\link{householdsToDataFrame}}
#'
#' @export
setClass(
  "HouseholdType",
  
  slots = c(
    
    hh_type = "character",
    
    positions = "list",
    
    position_identifiers = "list",
    
    households = "list",
    
    sampled_agents = "character",
    
    couple_gender_distribution = "numeric",
    
    couple_age_distribution = "numeric",
    
    parent_child_age_distribution = "numeric",
    
    df_synth_pop = "data.table",
    
    household_position_column = "character"
  )
)
setValidity(
  "HouseholdType",
  
  function(object) {
    
    #
    # Household type name
    #
    
    if (
      length(object@hh_type) != 1
    ) {
      
      return(
        "hh_type must contain exactly one value"
      )
      
    }
    
    #
    # Position column
    #
    
    if (
      !is.character(
        object@household_position_column
      )
    ) {
      
      return(
        "household_position_column must be character"
      )
      
    }
    
    if (
      length(
        object@household_position_column
      ) > 1
    ) {
      
      return(
        "household_position_column must contain a single value"
      )
      
    }
    
    #
    # Distribution slots
    #
    
    if (
      !is.numeric(
        object@couple_gender_distribution
      )
    ) {
      
      return(
        "couple_gender_distribution must be numeric"
      )
      
    }
    
    if (
      !is.numeric(
        object@couple_age_distribution
      )
    ) {
      
      return(
        "couple_age_distribution must be numeric"
      )
      
    }
    
    if (
      !is.numeric(
        object@parent_child_age_distribution
      )
    ) {
      
      return(
        "parent_child_age_distribution must be numeric"
      )
      
    }
    
    #
    # Position identifiers must
    # point to existing positions
    #
    
    if (
      length(
        object@position_identifiers
      ) > 0
    ) {
      
      max_index <- max(
        unlist(
          object@position_identifiers
        )
      )
      
      if (
        max_index >
        length(
          object@positions
        )
      ) {
        
        return(
          "position_identifiers reference undefined positions"
        )
        
      }
      
    }
    
    TRUE
    
  }
  
)
#' Create a HouseholdType Object
#'
#' Creates a new \code{HouseholdType} used during synthetic
#' household generation.
#'
#' A \code{HouseholdType} defines:
#'
#' \itemize{
#'   \item The type of household to be generated.
#'   \item The positions required within the household
#'         (for example adults and children).
#'   \item Couple gender distributions.
#'   \item Couple age-gap distributions.
#'   \item Parent-child age-gap distributions.
#' }
#'
#' Household structures are subsequently configured using
#' \code{\link{addMembers}}.
#'
#' @param household_type Character string identifying the
#' household type.
#'
#' Examples include:
#'
#' \itemize{
#'   \item \code{"CoupleHousehold"}
#'   \item \code{"Family"}
#'   \item \code{"SingleAdultHousehold"}
#'   \item \code{"SingleParent"}
#' }
#'
#' @param couple_gender_distribution Named numeric vector
#' controlling the gender composition of generated couples.
#'
#' For example:
#'
#' \preformatted{
#' c(
#'   "Male|Female" = 1
#' )
#' }
#'
#' generates only male-female couples.
#'
#' @param couple_age_distribution Named numeric vector
#' controlling partner age-gap distributions.
#'
#' For example:
#'
#' \preformatted{
#' c(
#'   "-5-5" = 1
#' )
#' }
#'
#' indicates that partners should typically be within five
#' years of one another.
#'
#' @param parent_child_age_distribution Named numeric vector
#' controlling parent-child age-gap distributions.
#'
#' For example:
#'
#' \preformatted{
#' c(
#'   "20-30" = 1
#' )
#' }
#'
#' indicates that parents should generally be between twenty
#' and thirty years older than their children.
#'
#' @return A new \code{HouseholdType} object.
#'
#' @details
#' After construction, household-position requirements should
#' be specified using \code{\link{addMembers}}.
#'
#' Example:
#'
#' \preformatted{
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
#' hh <- addMembers(
#'   hh,
#'   household_position = "Child",
#'   position_identifier = "child",
#'   amount = 2,
#'   backup_position_identifiers = character()
#' )
#' }
#'
#' The resulting object can then be supplied to a
#' \code{\link{HouseholdGrouper}} for household generation.
#'
#' @examples
#' \dontrun{
#'
#' hh <- HouseholdType(
#'   household_type = "Family",
#'   couple_gender_distribution = c(
#'     "Male|Female" = 1
#'   ),
#'   couple_age_distribution = c(
#'     "-5-5" = 1
#'   ),
#'   parent_child_age_distribution = c(
#'     "20-30" = 1
#'   )
#' )
#'
#' }
#'
#' @seealso
#' \code{\link{HouseholdType-class}},
#' \code{\link{HouseholdGrouper}},
#' \code{\link{addMembers}},
#' \code{\link{createFromMembers}}
#'
#' @export
HouseholdType <- function(
    household_type,
    couple_gender_distribution = numeric(),
    couple_age_distribution = numeric(),
    parent_child_age_distribution = numeric()
) {
  
  new(
    "HouseholdType",
    
    hh_type = household_type,
    
    positions = list(),
    
    position_identifiers = list(),
    
    households = list(),
    
    sampled_agents = character(),
    
    couple_gender_distribution =
      couple_gender_distribution,
    
    couple_age_distribution =
      couple_age_distribution,
    
    parent_child_age_distribution =
      parent_child_age_distribution,
    
    df_synth_pop =
      data.table::data.table(),
    
    household_position_column = ""
  )
}
