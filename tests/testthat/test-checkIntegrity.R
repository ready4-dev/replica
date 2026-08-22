library(testthat)
library(data.table)

test_that(
  "ratify returns TRUE for valid households",
  {
    
    hh <- ReplicaStructure(
      "CoupleOnly"
    )
    
    hh <- renew(
      hh,
      what = "positions",
      household_position = "Parent",
      position_identifier = "adult",
      amount = 2,
      backup_position_identifiers = character()
    )
    
    hh@population <- data.table(
      
      agent_id = c(
        "A001",
        "A002"
      ),
      
      household_position = c(
        "Parent",
        "Parent"
      )
      
    )
    
    hh@position_column <-
      "household_position"
    
    hh@households <- list(
      
      SSH000001 = list(
        all = c(
          "A001",
          "A002"
        )
      )
      
    )
    
    expect_true(
      ratify(hh, output = "logical")
    )
    
  }
)
test_that(
  "ratify detects duplicate agents",
  {
    
    hh <- ReplicaStructure(
      "CoupleOnly"
    )
    
    hh <- renew(
      hh,
      what = "positions",
      household_position = "Parent",
      position_identifier = "adult",
      amount = 2,
      backup_position_identifiers = character()
    )
    
    hh@population <- data.table(
      
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
    
    hh@position_column <-
      "household_position"
    
    hh@households <- list(
      
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
      ratify(hh, output = "logical")
    )
    
  }
)
test_that(
  "ratify detects missing agents",
  {
    
    hh <- ReplicaStructure(
      "CoupleOnly"
    )
    
    hh <- renew(
      hh,
      what = "positions",
      household_position = "Parent",
      position_identifier = "adult",
      amount = 2,
      backup_position_identifiers = character()
    )
    
    hh@population <- data.table(
      
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
    
    hh@position_column <-
      "household_position"
    
    hh@households <- list(
      
      SSH000001 = list(
        all = c(
          "A001",
          "A002"
        )
      )
      
    )
    
    expect_warning(
      result <- ratify(hh, output = "logical")
    )
    
    expect_false(result)
    
  }
)
test_that(
  "ratify handles empty household list",
  {
    
    hh <- ReplicaStructure(
      "CoupleOnly"
    )
    
    hh <- renew(
      hh,
      what = "positions",
      household_position = "Parent",
      position_identifier = "adult",
      amount = 2,
      backup_position_identifiers = character()
    )
    
    hh@population <- data.table(
      
      agent_id = c(
        "A001",
        "A002"
      ),
      
      household_position = c(
        "Parent",
        "Parent"
      )
      
    )
    
    hh@position_column <-
      "household_position"
    
    hh@households <- list()
    
    expect_warning(
      result <- ratify(hh, output = "logical")
    )
    
    expect_false(result)
    
  }
)
test_that(
  "all expected agents appear exactly once",
  {
    
    hh <- ReplicaStructure(
      "CoupleOnly"
    )
    
    hh <- renew(
      hh,
      what = "positions",
      household_position = "Parent",
      position_identifier = "adult",
      amount = 2,
      backup_position_identifiers = character()
    )
    
    hh@population <- data.table(
      
      agent_id = c(
        "A001",
        "A002"
      ),
      
      household_position = c(
        "Parent",
        "Parent"
      )
      
    )
    
    hh@position_column <-
      "household_position"
    
    #
    # Create a valid household
    #
    
    adult_position <- replica:::getPositionForName(
      hh,
      "adult"
    )
    
    hh <- create_household_with_id(
      hh,
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
      hh
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
      ratify(hh, output = "logical")
    )
    
  }
)
test_that(
  "valid household assignments pass integrity check",
  {
    
    hh <- ReplicaStructure(
      "CoupleOnly"
    )
    
    hh <- renew(
      hh,
      what = "positions",
      household_position = "Parent",
      position_identifier = "adult",
      amount = 2,
      backup_position_identifiers = character()
    )
    
    hh@population <- data.table(
      
      agent_id = c(
        "A001",
        "A002"
      ),
      
      household_position = c(
        "Parent",
        "Parent"
      )
      
    )
    
    hh@position_column <-
      "household_position"
    
    adult_position <- replica:::getPositionForName(
      hh,
      "adult"
    )
    
    hh <- create_household_with_id(
      hh,
      adult_position,
      1,
      c(
        "A001",
        "A002"
      )
    )
    
    all_agents <- getAllAgents(hh)
    
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
      ratify(hh, output = "logical")
    )
    
  }
)
