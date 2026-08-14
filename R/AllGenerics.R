setGeneric(
  "addHouseholdType",
  function(
    object,
    household_type
  ) {
    standardGeneric("addHouseholdType")
  }
)
setGeneric(
  "addMargins",
  function(
    object,
    margins,
    margins_names
  )
    standardGeneric(
      "addMargins"
    )
)
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
setGeneric(
  "run",
  function(object)
    standardGeneric("run")
)
setGeneric(
  "runHouseholdGrouper",
  function(object) {
    standardGeneric("runHouseholdGrouper")
  }
)
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
setGeneric(
  "verify",
  function(object)
    standardGeneric("verify")
)