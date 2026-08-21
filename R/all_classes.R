#' Replica Attribute Assignment Module
#'
#' An S4 class for assigning attributes to synthetic agents
#' using contingency tables and marginal distributions.
#'
#' `ReplicaAdder` extends `Ready4Module` and implements the
#' attribute-assignment stage of the `replica` workflow.
#'
#' The module assigns a target attribute to a synthetic
#' population while attempting to preserve relationships
#' described in a reference contingency table.
#'
#' Optional marginal distributions may also be supplied when
#' known population totals are available.
#'
#' Validation diagnostics can be generated using
#' `ratify()` and are stored in the
#' `validation_results` slot.
#'
#' @slot synth_pop A data.table containing the synthetic
#' population.
#' @slot contingency A data.frame or data.table containing
#' reference contingency data.
#' @slot target_attribute Character string identifying the
#' attribute to be assigned.
#' @slot group_by Character vector specifying conditioning
#' variables used during assignment.
#' @slot margins Optional list of marginal distributions.
#' @slot margins_names Names corresponding to supplied
#' margins.
#' @slot margins_group Character vector specifying margins
#' group.
#' @slot missing_group_strategy Strategy used to handle
#' groups not present in the contingency table.
#' @slot warning_threshold Significance threshold used when
#' generating validation warnings.
#' @slot validation_results Validation diagnostics generated
#' by `ratify()`.
#'
#' @section Workflow:
#'
#' A typical workflow is:
#'
#' \preformatted{
#' adder <- ReplicaAdder(...)
#'
#' adder <- renew(
#'   adder,
#'   margins = ...
#' )
#'
#' adder <- enhance(adder)
#'
#' adder <- ratify(adder)
#' }
#'
#' @section Inheritance:
#'
#' `ReplicaAdder` inherits from `Ready4Module`.
#'
#' @seealso
#' \code{\link{ReplicaGrouper}},
#' \code{\link{ReplicaStructure}},
#' \code{\link{renew}},
#' \code{\link{enhance}},
#' \code{\link{ratify}}
#'
#' @exportClass ReplicaAdder
setClass(
  "ReplicaAdder",
  contains = "Ready4Module",
  slots = c(
    
    synth_pop = "data.table",
    
    contingency = "data.table",
    
    target_attribute = "character",
    
    group_by = "character",
    
    margins = "list",
    
    margins_names = "list",
    
    margins_group = "character",
    
    missing_group_strategy = "character",
    
    validation_results = "list",
    
    warning_threshold = "numeric"
    
  )
)
#' Create a ReplicaAdder Module
#'
#' Creates a `ReplicaAdder` object for assigning attributes
#' to a synthetic population using contingency tables.
#'
#' The resulting module can subsequently be configured using
#' `renew()`, executed using `enhance()` and validated using
#' `ratify()`.
#'
#' @param synth_pop A synthetic population represented as a
#' data.frame or data.table.
#' @param contingency A contingency table describing the
#' expected relationship between conditioning variables and
#' the target attribute.
#' @param target_attribute Character string identifying the
#' attribute to be assigned.
#' @param group_by Character vector specifying conditioning
#' variables used during assignment.
#' @param missing_group_strategy Character string specifying
#' how groups missing from the contingency table should be
#' handled. Options include `"borrow"`, `"overall"` and
#' `"error"`.
#' @param warning_threshold Numeric significance threshold
#' used when generating validation warnings.
#'
#' @return A `ReplicaAdder` object.
#'
#' @examples
#' age_gender <- data.frame(
#'   age_group = c("18-64", "65+"),
#'   count = c(10, 10)
#' )
#' 
#' population <- make_agents(
#'   age_gender
#' )
#' 
#' contingency <- data.frame(
#'   age_group = c("18-64", "65+"),
#'   education = c("Degree", "School"),
#'   count = c(60, 40)
#' )
#' 
#' adder <- ReplicaAdder(
#'   synth_pop = population,
#'   contingency = contingency,
#'   target_attribute = "education",
#'   group_by = "age_group"
#' )
#'
#' @seealso
#' \code{\link{ReplicaAdder}},
#' \code{\link{renew}},
#' \code{\link{enhance}},
#' \code{\link{ratify}}
#'
#' @export
ReplicaAdder <- function(
    synth_pop,
    contingency,
    target_attribute,
    group_by = character(),
    missing_group_strategy = "borrow",
    warning_threshold = 0.05
) {
  
  new(
    
    "ReplicaAdder",
    
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
    
    missing_group_strategy = missing_group_strategy,
    
    validation_results = list(),
    
    warning_threshold = warning_threshold
    
  )
  
}
setValidity(
  "ReplicaAdder",
  
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

#' ReplicaGrouper Class
#'
#' Coordinates the generation of synthetic households from a
#' synthetic population.
#'
#' A \code{ReplicaGrouper} object manages one or more
#' \code{\link{ReplicaStructure}} objects and applies household
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
#' \code{\link{ReplicaStructure}} objects used during household
#' generation.
#'
#' @details
#' Household generation typically proceeds as follows:
#'
#' \enumerate{
#'   \item Create a \code{ReplicaGrouper}.
#'   \item Create one or more
#'         \code{\link{ReplicaStructure}} objects.
#'   \item Register the household types using
#'         \code{\link{renew}}.
#'   \item Execute household generation using
#'         \code{\link{enhance}}.
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
#' hg <- ReplicaGrouper(
#'   df_synth_pop = pop,
#'   group_by = "neighb_code"
#' )
#'
#' hg <- renew(
#'   hg,
#'   hh
#' )
#'
#' result <- manufacture(
#'   hg
#' )
#'
#' }
#'
#' @seealso
#' \code{\link{ReplicaGrouper}},
#' \code{\link{ReplicaStructure}},
#' \code{\link{manufacture}},
#' \code{\link{renew}}
#'
#' @export
setClass(
  "ReplicaGrouper",
  contains = "Ready4Module",
  slots = c(
    
    df_synth_pop = "data.table",
    
    group_by = "character",
    
    target_column = "character",
    
    household_types = "list"
  )
)
setValidity(
  "ReplicaGrouper",
  
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
#' Create a ReplicaGrouper Object
#'
#' Creates a new \code{ReplicaGrouper} used to generate
#' synthetic households from an existing synthetic population.
#'
#' The resulting object acts as the top-level coordinator of the
#' household-generation workflow and manages one or more
#' \code{\link{ReplicaStructure}} objects.
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
#' @return A new \code{ReplicaGrouper} object.
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
#' \code{\link{renew}}.
#'
#' The resulting object is typically executed using
#' \code{\link{enhance}}.
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
#' hg <- ReplicaGrouper(
#'   df_synth_pop = pop,
#'   group_by = "neighb_code"
#' )
#'
#' }
#'
#' @seealso
#' \code{\link{ReplicaGrouper-class}},
#' \code{\link{ReplicaStructure}},
#' \code{\link{renew}},
#' \code{\link{enhance}}
#'
#' @export
ReplicaGrouper <- function(
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
    "ReplicaGrouper",
    
    df_synth_pop = df_synth_pop,
    
    group_by = group_by,
    
    target_column = target_column,
    
    household_types = list()
  )
}
#' ReplicaStructure Class
#'
#' Represents a household structure used during synthetic
#' household generation.
#'
#' A \code{ReplicaStructure} object stores:
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
#' \code{\link{ReplicaGrouper}} to create synthetic
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
#' created via \code{\link{renew}}.
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
#'   \item Create a \code{ReplicaStructure}.
#'   \item Define household positions using
#'         \code{\link{renew}}.
#'   \item Configure distributions.
#'   \item Attach a synthetic population using
#'         \code{\link{renew}}.
#'   \item Generate households using
#'         \code{createFromMembers}.
#' }
#'
#' Generated households are stored internally and can be
#' exported using:
#'
#' \itemize{
#'   \item \code{\link{renew}}
#'   \item \code{\link{manufacture}}
#' }
#'
#'#' @section Workflow:
#'
#' A typical workflow is:
#'
#' \preformatted{
#' structure <- ReplicaStructure(
#'   "CoupleHousehold"
#' )
#'
#' structure <- renew(
#'   structure,
#'   what = "positions",
#'   ...
#' )
#'
#' structure <- ratify(
#'   structure,
#'   output = "self"
#' )
#'
#' household_summary <- manufacture(
#'   structure
#' )
#' }
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
#'   what = "positions",
#'   household_position = "Parent",
#'   position_identifier = "adult",
#'   amount = 2,
#'   backup_position_identifiers = character()
#' )
#'
#' hh <- renew(
#'   hh,
#'   what = "positions",
#'   household_position = "Child",
#'   position_identifier = "child",
#'   amount = 2,
#'   backup_position_identifiers = character()
#' )
#'
#' }
#'
#' @seealso
#' \code{\link{ReplicaStructure}},
#' \code{\link{ReplicaGrouper}},
#' \code{\link{renew}},
#' \code{\link{manufacture}}
#'
#' @export
setClass(
  "ReplicaStructure",
  contains = "Ready4Module",
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
  "ReplicaStructure",
  
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
#' Create a ReplicaStructure Object
#'
#' Creates a new \code{ReplicaStructure} used during synthetic
#' household generation.
#'
#' A \code{ReplicaStructure} defines:
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
#' \code{\link{renew}}.
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
#' @return A new \code{ReplicaStructure} object.
#'
#' @details
#' After construction, household-position requirements should
#' be specified using \code{\link{renew}}.
#'
#' Example:
#'
#' \preformatted{
#' hh <- ReplicaStructure(
#'   "Family"
#' )
#'
#' hh <- renew(
#'   what = "positions",
#'   hh,
#'   household_position = "Parent",
#'   position_identifier = "adult",
#'   amount = 2,
#'   backup_position_identifiers = character()
#' )
#'
#' hh <- renew(
#'   hh,
#'   what = "positions",
#'   household_position = "Child",
#'   position_identifier = "child",
#'   amount = 2,
#'   backup_position_identifiers = character()
#' )
#' }
#'
#' The resulting object can then be supplied to a
#' \code{\link{ReplicaGrouper}} for household generation.
#'
#' @examples
#' \dontrun{
#'
#' hh <- ReplicaStructure(
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
#' \code{\link{ReplicaStructure-class}},
#' \code{\link{ReplicaGrouper}},
#' \code{\link{renew}}
#'
#' @export
ReplicaStructure <- function(
    household_type,
    couple_gender_distribution = numeric(),
    couple_age_distribution = numeric(),
    parent_child_age_distribution = numeric()
) {
  
  new(
    "ReplicaStructure",
    
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
