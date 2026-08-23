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
    
    STRUCTURE <- ReplicaStructure(
      "CoupleHousehold"
    )
    
    STRUCTURE <- renew(
      STRUCTURE,
      what = "positions",
      household_position = "Parent",
      position_identifier = "adult",
      amount = 2,
      backup_position_identifiers = character()
    )
    
    STRUCTURE <- renew(
      STRUCTURE,
      what = "state",
      population = pop,
      position_column = "household_position"
    )
    
    STRUCTURE@couple_gender_distribution <- c(
      "Male|Female" = 1
    )
    
    STRUCTURE@couple_age_distribution <- c(
      "-5-5" = 1
    )
    
    STRUCTURE@assigned_agents <- character()
    
    #
    # Run R implementation
    #
    
    couples <- replica:::pair_partners(
      STRUCTURE,
      rep(TRUE, nrow(pop))
    )
    
    updated_STRUCTURE <- attr(
      couples,
      "object"
    )
    
    #
    # Compare sampled agents
    #
    
    expect_equal(
      
      sort(
        updated_STRUCTURE@assigned_agents
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
