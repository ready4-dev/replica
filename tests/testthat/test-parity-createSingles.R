test_that(
  "createSingles matches Python",
  {
    
    set.seed(123)
    
    py <- read.csv(
      system.file("reference_data","create_singles.csv", package = "replica")
    )
    
    pop <- data.table(
      
      agent_id = c(
        "A001",
        "A002",
        "A003"
      ),
      
      age = c(
        30,
        45,
        60
      ),
      
      gender = c(
        "Male",
        "Female",
        "Male"
      ),
      
      household_position = c(
        "SingleAdult",
        "SingleAdult",
        "SingleAdult"
      )
      
    )
    
    STRUCTURE <- ReplicaStructure(
      "SingleAdultHousehold"
    )
    
    STRUCTURE <- renew(
      STRUCTURE,
      what = "positions",
      household_position =
        "SingleAdult",
      position_identifier =
        "adult",
      amount = 1,
      backup_position_identifiers =
        character()
    )
    
    STRUCTURE <- renew(
      STRUCTURE,
      what = "state",
      population = pop,
      position_column = "household_position"
    )
    
    STRUCTURE@assigned_agents <- character()
    
    result <- createSingles(
      STRUCTURE,
      rep(
        TRUE,
        nrow(pop)
      )
    )
    
    updated_STRUCTURE <- attr(
      result,
      "object"
    )
    
    expect_same_assigned_agents(
      updated_STRUCTURE@assigned_agents,
      py$sampled_agents
    )
    
  }
)
