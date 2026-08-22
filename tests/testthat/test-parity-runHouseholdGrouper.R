library(testthat)
library(data.table)

test_that(
  "run-ReplicaGrouper matches Python",
  {
    
    set.seed(123)
    
    #
    # Load Python reference outputs
    #
    
    py_population <- read.csv(
      system.file("reference_data","household_grouper_population.csv", package = "replica"),
      stringsAsFactors = FALSE
    )
    
    py_households <- read.csv(
      system.file("reference_data","household_grouper_households.csv", package = "replica"),
      stringsAsFactors = FALSE
    )
    
    #
    # Recreate the test population
    #
    
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
      ),
      
      age = c(
        40,
        35,
        50,
        45
      ),
      
      gender = c(
        "Male",
        "Female",
        "Male",
        "Female"
      ),
      
      household_position = c(
        "Parent",
        "Parent",
        "Parent",
        "Parent"
      ),
      
      household_id = NA_character_
      
    )
    
    #
    # Create ReplicaStructure
    #
    
    hh <- ReplicaStructure(
      "CoupleHousehold"
    )
    
    hh <- renew(
      hh,
      what = "positions",
      household_position = "Parent",
      position_identifier = "adult",
      amount = 2,
      backup_position_identifiers = character()
    )
    
    hh@couple_gender_distribution <- c(
      "Male|Female" = 1
    )
    
    hh@couple_age_distribution <- c(
      "-5-5" = 1
    )
    
    #
    # Create ReplicaGrouper
    #
    
    hg <- ReplicaGrouper(
      population = pop,
      group_by = "neighb_code"
    )
    
    hg <- renew(
      hg,
      hh
    )
    
    #
    # Run R workflow
    #
    
    result <- manufacture(
      hg
    )
    
    r_population <- result$synthetic_population
    
    r_households <- result$synthetic_households
    expect_equal(
      nrow(r_population),
      nrow(py_population)
    )
    expect_equal(
      nrow(r_households),
      nrow(py_households)
    )
    expect_equal(
      
      unname(
        extract_household_size_distribution(
          r_households
        )
      ),
      
      unname(
        extract_household_size_distribution(
          py_households, column = "hh_size"
        )
      )
      
    )
    expect_equal(
      
      extract_household_type_distribution(
        r_households
      ),
      
      extract_household_type_distribution(
        py_households, column = "hh_type"
      )
      
    )
    expect_false(
      any(
        is.na(
          r_population$
            household_id
        )
      )
    )
    expect_false(
      any(
        is.na(
          py_population$
            household_id
        )
      )
    )
    expect_equal(
      
      unname(
        sort(
          table(
            r_population$
              household_id
          )
        )
      ),
      
      unname(
        sort(
          table(
            py_population$
              household_id
          )
        )
      )
      
    )
    # cat("R agent IDs:\n")
    # print(sort(r_population$agent_id))
    # 
    # cat("Python agent IDs:\n")
    # print(sort(py_population$agent_id))
    expect_true(
      
      setequal(
        
        r_population$
          agent_id,
        
        py_population$
          agent_id
        
      )
      
    )
    expect_true(
      
      setequal(
        
        r_households$
          household_id,
        
        unique(
          r_population$
            household_id
        )
        
      )
      
    )
    expect_equal(
      
      sum(
        r_households$
          household_size
      ),
      
      nrow(
        r_population
      )
      
    )
    expect_equal(
      
      sum(
        py_households$
          hh_size
      ),
      
      nrow(
        py_population
      )
      
    )
  }
)
