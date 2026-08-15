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
    
    hh <- HouseholdType(
      "SingleAdultHousehold"
    )
    
    hh <- addMembers(
      hh,
      household_position =
        "SingleAdult",
      position_identifier =
        "adult",
      amount = 1,
      backup_position_identifiers =
        character()
    )
    
    hh <- updateState(
      hh,
      pop,
      "household_position"
    )
    
    hh@sampled_agents <- character()
    
    result <- createSingles(
      hh,
      rep(
        TRUE,
        nrow(pop)
      )
    )
    
    updated_hh <- attr(
      result,
      "object"
    )
    
    expect_same_sampled_agents(
      updated_hh@sampled_agents,
      py$sampled_agents
    )
    
  }
)