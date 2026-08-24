library(testthat)
library(data.table)

test_that(
  "manufacture produces correct output",
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
      backup_position_identifiers =
        character()
    )
    
    pop <- data.table(
      
      agent_id = c(
        "A001",
        "A002",
        "A003",
        "A004"
      ),
      
      neighb_code = c(
        "N1",
        "N1",
        "N2",
        "N2"
      )
      
    )
    
    STRUCTURE <- renew(
      STRUCTURE,
      what = "state",
      population = pop,
      position_column = "household_position"
    )
    
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
    
    STRUCTURE <- create_household_with_id(
      STRUCTURE,
      adult_position,
      2,
      c(
        "A003",
        "A004"
      )
    )
    
    households <- manufacture(
      STRUCTURE
    )
    
    expect_equal(
      nrow(households),
      2
    )
    
    expect_true(
      
      setequal(
        
        households$household_id,
        
        c(
          "SSH000001",
          "SSH000002"
        )
        
      )
      
    )
    
    expect_true(
      
      setequal(
        
        households$neighb_code,
        
        c(
          "N1",
          "N2"
        )
        
      )
      
    )
    
    expect_true(
      
      all(
        households$household_type ==
          "CoupleOnly"
      )
      
    )
    
    expect_true(
      
      all(
        households$household_size == 2
      )
      
    )
    
  }
)
test_that(
  "household sizes reflect membership counts",
  {
    
    STRUCTURE <- ReplicaStructure(
      "MixedHouseholds"
    )
    
    STRUCTURE@households <- list(
      
      SSH000001 = list(
        all = c(
          "A001"
        )
      ),
      
      SSH000002 = list(
        all = c(
          "A002",
          "A003"
        )
      ),
      
      SSH000003 = list(
        all = c(
          "A004",
          "A005",
          "A006",
          "A007"
        )
      )
      
    )
    
    STRUCTURE@population <- data.table(
      
      agent_id = c(
        "A001",
        "A002",
        "A003",
        "A004",
        "A005",
        "A006",
        "A007"
      ),
      
      neighb_code = c(
        "N1",
        "N1",
        "N1",
        "N2",
        "N2",
        "N2",
        "N2"
      )
      
    )
    
    households <- manufacture(
      STRUCTURE
    )
    
    expected_sizes <- sapply(
      STRUCTURE@households,
      function(x)
        length(x$all)
    )
    
    expect_equal(
      households$household_size,
      as.integer(expected_sizes)
    )
    
    expect_equal(
      nrow(households),
      length(STRUCTURE@households)
    )
    
    expect_true(
      all(households$household_size > 0)
    )
    
  }
)
test_that(
  "empty household list handled correctly",
  {
    
    STRUCTURE <- ReplicaStructure(
      "CoupleOnly"
    )
    
    STRUCTURE@households <- list()
    
    households <- manufacture(
      STRUCTURE
    )
    
    expect_equal(
      nrow(households),
      0
    )
    
    expect_equal(
      
      names(households),
      
      c(
        "household_id",
        "neighb_code",
        "household_type",
        "household_size"
      )
      
    )
    
  }
)
test_that(
  "household_size matches stored household membership",
  {
    STRUCTURE <- ReplicaStructure(
      "CoupleOnly"
    )
    
    households <- manufacture(
      STRUCTURE
    )
    
    expected_sizes <- sapply(
      STRUCTURE@households,
      function(x)
        length(x$all)
    )
    
    expect_equal(
      households$household_size,
      as.integer(expected_sizes)
    )
    
  }
)
