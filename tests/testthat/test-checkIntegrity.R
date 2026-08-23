library(testthat)
library(data.table)

test_that(
  "ratify returns TRUE for valid households",
  {
    
    STRUCTURE <- ReplicaStructure(
      "CoupleOnly"
    )
    
    STRUCTURE <- renew(
      STRUCTURE,
      what = "positions",
      household_position = "Parent",
      position_identifier = "adult",
      amount = 2,
      backup_position_identifiers = character()
    )
    
    STRUCTURE@population <- data.table(
      
      agent_id = c(
        "A001",
        "A002"
      ),
      
      household_position = c(
        "Parent",
        "Parent"
      )
      
    )
    
    STRUCTURE@position_column <-
      "household_position"
    
    STRUCTURE@households <- list(
      
      SSH000001 = list(
        all = c(
          "A001",
          "A002"
        )
      )
      
    )
    
    expect_true(
      ratify(STRUCTURE, output = "logical")
    )
    
  }
)
test_that(
  "ratify detects duplicate agents",
  {
    
    STRUCTURE <- ReplicaStructure(
      "CoupleOnly"
    )
    
    STRUCTURE <- renew(
      STRUCTURE,
      what = "positions",
      household_position = "Parent",
      position_identifier = "adult",
      amount = 2,
      backup_position_identifiers = character()
    )
    
    STRUCTURE@population <- data.table(
      
      agent_id = c(
        "A001",
        "A002",
        "A003"
      ),
      
      household_position = c(
        "Parent",
        "Parent",
        "Parent"
      )
      
    )
    
    STRUCTURE@position_column <-
      "household_position"
    
    STRUCTURE@households <- list(
      
      SSH000001 = list(
        all = c(
          "A001",
          "A002"
        )
      ),
      
      SSH000002 = list(
        all = c(
          "A002",
          "A003"
        )
      )
      
    )
    
    expect_error(
      ratify(STRUCTURE, output = "logical")
    )
    
  }
)
test_that(
  "ratify detects missing agents",
  {
    
    STRUCTURE <- ReplicaStructure(
      "CoupleOnly"
    )
    
    STRUCTURE <- renew(
      STRUCTURE,
      what = "positions",
      household_position = "Parent",
      position_identifier = "adult",
      amount = 2,
      backup_position_identifiers = character()
    )
    
    STRUCTURE@population <- data.table(
      
      agent_id = c(
        "A001",
        "A002",
        "A003"
      ),
      
      household_position = c(
        "Parent",
        "Parent",
        "Parent"
      )
      
    )
    
    STRUCTURE@position_column <-
      "household_position"
    
    STRUCTURE@households <- list(
      
      SSH000001 = list(
        all = c(
          "A001",
          "A002"
        )
      )
      
    )
    
    expect_warning(
      result <- ratify(STRUCTURE, output = "logical")
    )
    
    expect_false(result)
    
  }
)
test_that(
  "ratify handles empty household list",
  {
    
    STRUCTURE <- ReplicaStructure(
      "CoupleOnly"
    )
    
    STRUCTURE <- renew(
      STRUCTURE,
      what = "positions",
      household_position = "Parent",
      position_identifier = "adult",
      amount = 2,
      backup_position_identifiers = character()
    )
    
    STRUCTURE@population <- data.table(
      
      agent_id = c(
        "A001",
        "A002"
      ),
      
      household_position = c(
        "Parent",
        "Parent"
      )
      
    )
    
    STRUCTURE@position_column <-
      "household_position"
    
    STRUCTURE@households <- list()
    
    expect_warning(
      result <- ratify(STRUCTURE, output = "logical")
    )
    
    expect_false(result)
    
  }
)
test_that(
  "all expected agents appear exactly once",
  {
    
    STRUCTURE <- ReplicaStructure(
      "CoupleOnly"
    )
    
    STRUCTURE <- renew(
      STRUCTURE,
      what = "positions",
      household_position = "Parent",
      position_identifier = "adult",
      amount = 2,
      backup_position_identifiers = character()
    )
    
    STRUCTURE@population <- data.table(
      
      agent_id = c(
        "A001",
        "A002"
      ),
      
      household_position = c(
        "Parent",
        "Parent"
      )
      
    )
    
    STRUCTURE@position_column <-
      "household_position"
    
    #
    # Create a valid household
    #
    
    adult_position <- replica:::getPositionForName(
      STRUCTURE,
      "adult"
    )
    
    STRUCTURE <- create_household_with_id(
      STRUCTURE,
      adult_position,
      1,
      c(
        "A001",
        "A002"
      )
    )
    
    #
    # Verify household contents
    #
    
    all_agents <- getAllAgents(
      STRUCTURE
    )
    
    expect_equal(
      length(all_agents),
      2
    )
    
    expect_equal(
      length(
        unique(all_agents)
      ),
      2
    )
    
    expect_true(
      setequal(
        all_agents,
        c(
          "A001",
          "A002"
        )
      )
    )
    
    #
    # Integrity check should pass
    #
    
    expect_true(
      ratify(STRUCTURE, output = "logical")
    )
    
  }
)
test_that(
  "valid household assignments pass integrity check",
  {
    
    STRUCTURE <- ReplicaStructure(
      "CoupleOnly"
    )
    
    STRUCTURE <- renew(
      STRUCTURE,
      what = "positions",
      household_position = "Parent",
      position_identifier = "adult",
      amount = 2,
      backup_position_identifiers = character()
    )
    
    STRUCTURE@population <- data.table(
      
      agent_id = c(
        "A001",
        "A002"
      ),
      
      household_position = c(
        "Parent",
        "Parent"
      )
      
    )
    
    STRUCTURE@position_column <-
      "household_position"
    
    adult_position <- replica:::getPositionForName(
      STRUCTURE,
      "adult"
    )
    
    STRUCTURE <- create_household_with_id(
      STRUCTURE,
      adult_position,
      1,
      c(
        "A001",
        "A002"
      )
    )
    
    all_agents <- getAllAgents(STRUCTURE)
    
    expect_equal(
      length(all_agents),
      2
    )
    
    expect_equal(
      length(unique(all_agents)),
      2
    )
    
    expect_true(
      setequal(
        all_agents,
        c(
          "A001",
          "A002"
        )
      )
    )
    
    expect_true(
      ratify(STRUCTURE, output = "logical")
    )
    
  }
)
