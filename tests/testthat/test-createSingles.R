library(testthat)
library(data.table)

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

hh <- ReplicaStructure(
  "SingleAdultHousehold"
)

hh <- renew(
  hh,
  what = "positions",
  household_position = "SingleAdult",
  position_identifier = "adult",
  amount = 1,
  backup_position_identifiers = character()
)

hh <- updateState(
  hh,
  pop,
  "household_position"
)

hh@sampled_agents <- character()
test_that(
  "createSingles creates expected number of households",
  {
    
    result <- createSingles(
      hh,
      rep(
        TRUE,
        nrow(pop)
      )
    )
    
    expect_equal(
      length(result),
      3
    )
    
  }
)
test_that(
  "updated ReplicaStructure attached",
  {
    
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
    
    expect_s4_class(
      updated_hh,
      "ReplicaStructure"
    )
    
  }
)
test_that(
  "all adults assigned",
  {
    
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
    
    expect_true(
      
      setequal(
        
        updated_hh@sampled_agents,
        
        pop$agent_id
        
      )
      
    )
    
  }
)
test_that(
  "no duplicate assignments",
  {
    
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
    
    expect_equal(
      
      length(
        updated_hh@sampled_agents
      ),
      
      length(
        
        unique(
          updated_hh@sampled_agents
        )
        
      )
      
    )
    
  }
)
test_that(
  "no adults remain available",
  {
    
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
    
    remaining <- getRemainingAgentsInPosition(
      updated_hh,
      "SingleAdult"
    )
    
    expect_equal(
      nrow(remaining),
      0
    )
    
  }
)
test_that(
  "single households contain one adult",
  {
    
    result <- createSingles(
      hh,
      rep(
        TRUE,
        nrow(pop)
      )
    )
    
    household_sizes <- sapply(
      result,
      length
    )
    
    expect_true(
      all(
        household_sizes == 1
      )
    )
    
  }
)
test_that(
  "all source agents appear exactly once",
  {
    
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
    
    expect_true(
      
      setequal(
        
        updated_hh@sampled_agents,
        
        pop$agent_id
        
      )
      
    )
    
    expect_equal(
      
      length(
        updated_hh@sampled_agents
      ),
      
      3
      
    )
    
    expect_equal(
      
      length(
        unique(
          updated_hh@sampled_agents
        )
      ),
      
      3
      
    )
    
  }
)
