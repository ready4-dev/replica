library(testthat)
library(data.table)
#
# Create population
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
# Create household type
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

#
# Configure distributions
#

hh@couple_gender_distribution <- c(
  "Male|Female" = 1
)

hh@couple_age_distribution <- c(
  "-5-5" = 1
)
test_that(
  "run-ReplicaGrouper assigns all agents to households",
  {
    
    #
    # Create grouper
    #
    
    hg <- ReplicaGrouper(
      df_synth_pop = pop,
      group_by = "neighb_code"
    )
    
    hg <- renew(
      hg,
      hh
    )
    
    #
    # Execute workflow
    #
    
    result <- manufacture(
      hg
    )
    
    #
    # Every agent assigned
    #
    
    expect_true(
      
      all(
        !is.na(
          result$
            synthetic_population$
            household_id
        )
      )
      
    )
    
    #
    # Population size preserved
    #
    
    expect_equal(
      nrow(
        result$
          synthetic_population
      ),
      4
    )
    
    #
    # Two households created
    #
    
    expect_equal(
      nrow(
        result$
          synthetic_households
      ),
      2
    )
    
    #
    # Household IDs match
    #
    
    expect_true(
      
      setequal(
        
        result$
          synthetic_households$
          household_id,
        
        unique(
          result$
            synthetic_population$
            household_id
        )
        
      )
      
    )
    
    #
    # Household sizes correct
    #
    
    expect_true(
      
      all(
        
        result$
          synthetic_households$
          hh_size == 2
        
      )
      
    )
    
    #
    # Two household IDs exist
    #
    
    expect_equal(
      
      length(
        
        unique(
          
          result$
            synthetic_population$
            household_id
          
        )
        
      ),
      
      2
      
    )
    
    #
    # Each household contains two people
    #
    
    household_counts <- table(
      
      result$
        synthetic_population$
        household_id
      
    )
    
    expect_true(
      all(
        household_counts == 2
      )
    )
    
  }
)
population <- data.table(
  
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
  )
  
)
test_that(
  "run-ReplicaGrouper preserves all agents exactly once",
  {
    
    hg <- ReplicaGrouper(
      df_synth_pop = population,
      group_by = "neighb_code"
    )
    
    hg <- renew(
      hg,
      hh
    )

    result <- manufacture(
      hg
    )
    
    expect_true(
      
      setequal(
        
        result$synthetic_population$agent_id,
        
        population$agent_id
        
      )
      
    )
    
  }
)
test_that(
  "synthetic household table internally consistent",
  {
    hg <- ReplicaGrouper(
      df_synth_pop = population,
      group_by = "neighb_code"
    )
    
    hg <- renew(
      hg,
      hh
    )
    
    result <- manufacture(
      hg
    )
    
    pop_households <-
      
      unique(
        
        result$
          synthetic_population$
          household_id
        
      )
    
    hh_table_households <-
      
      result$
      synthetic_households$
      household_id
    
    expect_true(
      
      setequal(
        pop_households,
        hh_table_households
      )
      
    )
    
  }
)
