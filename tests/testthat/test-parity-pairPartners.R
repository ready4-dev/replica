library(data.table)

test_that(
  "pair_partners matches Python",
  {
    
    set.seed(123)
    
    py_agents <- read.csv(
      system.file("reference_data","pair_partners_sampled.csv", package = "replica")
    )
    
    py_age_gaps <- read.csv(
      system.file("reference_data","pair_partners_age_gaps.csv", package = "replica")
    )
    
    py_gender_pairs <- read.csv(
      system.file("reference_data","pair_partners_genders.csv", package = "replica")
    )
    
    #
    # Recreate test population
    #
    
    pop <- data.table(
      
      agent_id = c(
        "A001",
        "A002",
        "A003",
        "A004"
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
      )
      
    )
    
    #
    # Recreate household type
    #
    
    hh <- HouseholdType(
      "CoupleHousehold"
    )
    
    hh <- addMembers(
      hh,
      household_position = "Parent",
      position_identifier = "adult",
      amount = 2,
      backup_position_identifiers = character()
    )
    
    hh <- updateState(
      hh,
      pop,
      "household_position"
    )
    
    hh@couple_gender_distribution <- c(
      "Male|Female" = 1
    )
    
    hh@couple_age_distribution <- c(
      "-5-5" = 1
    )
    
    hh@sampled_agents <- character()
    
    #
    # Run R implementation
    #
    
    couples <- pair_partners(
      hh,
      rep(TRUE, nrow(pop))
    )
    
    updated_hh <- attr(
      couples,
      "object"
    )
    
    #
    # Compare sampled agents
    #
    
    expect_equal(
      
      sort(
        updated_hh@sampled_agents
      ),
      
      sort(
        py_agents$sampled_agents
      )
      
    )
    
    #
    # Compare number of couples
    #
    
    expect_equal(
      length(couples),
      nrow(py_age_gaps)
    )
    
    #
    # Compare age-gap distribution
    #
    
    expect_equal(
      
      sort(
        extract_age_gaps(
          couples
        )
      ),
      
      sort(
        py_age_gaps$age_gap
      )
      
    )
    
    #
    # Compare gender-pair distribution
    #
    
    expect_equal(
      
      sort(
        extract_gender_pairs(
          couples
        )
      ),
      
      sort(
        py_gender_pairs$pair
      )
      
    )
    
  }
)
