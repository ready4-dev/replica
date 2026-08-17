library(testthat)
library(data.table)

test_that(
  "householdsToDataFrame produces correct output",
  {
    
    hh <- HouseholdType(
      "CoupleOnly"
    )
    
    hh <- addMembers(
      hh,
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
    
    hh <- updateState(
      hh,
      pop,
      "household_position"
    )
    
    adult_position <- getPositionForName(
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
    
    hh <- create_household_with_id(
      hh,
      adult_position,
      2,
      c(
        "A003",
        "A004"
      )
    )
    
    households <- householdsToDataFrame(
      hh
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
        households$hh_type ==
          "CoupleOnly"
      )
      
    )
    
    expect_true(
      
      all(
        households$hh_size == 2
      )
      
    )
    
  }
)
test_that(
  "household sizes reflect membership counts",
  {
    
    hh <- HouseholdType(
      "MixedHouseholds"
    )
    
    hh@households <- list(
      
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
    
    hh@df_synth_pop <- data.table(
      
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
    
    households <- householdsToDataFrame(
      hh
    )
    
    expected_sizes <- sapply(
      hh@households,
      function(x)
        length(x$all)
    )
    
    expect_equal(
      households$hh_size,
      as.integer(expected_sizes)
    )
    
    expect_equal(
      nrow(households),
      length(hh@households)
    )
    
    expect_true(
      all(households$hh_size > 0)
    )
    
  }
)
test_that(
  "empty household list handled correctly",
  {
    
    hh <- HouseholdType(
      "CoupleOnly"
    )
    
    hh@households <- list()
    
    households <- householdsToDataFrame(
      hh
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
        "hh_type",
        "hh_size"
      )
      
    )
    
  }
)
test_that(
  "hh_size matches stored household membership",
  {
    hh <- HouseholdType(
      "CoupleOnly"
    )
    
    households <- householdsToDataFrame(
      hh
    )
    
    expected_sizes <- sapply(
      hh@households,
      function(x)
        length(x$all)
    )
    
    expect_equal(
      households$hh_size,
      as.integer(expected_sizes)
    )
    
  }
)
