library(testthat)
library(data.table)

test_that(
  "make_agents creates expected number of agents",
  {
    
    counts <- data.frame(
      
      age_group = c(
        "0-17",
        "18-64"
      ),
      
      count = c(
        2,
        3
      )
      
    )
    
    result <- make_agents(
      counts
    )
    
    expect_equal(
      nrow(result),
      5
    )
    
  }
)
test_that(
  "make_agents creates agent identifiers",
  {
    
    counts <- data.frame(
      
      group = "A",
      
      count = 3
      
    )
    
    result <- make_agents(
      counts
    )
    
    expect_true(
      "agent_id" %in%
        names(result)
    )
    
    expect_equal(
      length(
        unique(
          result$agent_id
        )
      ),
      3
    )
    
  }
)
test_that(
  "make_agents preserves attributes",
  {
    
    counts <- data.frame(
      
      age_group = c(
        "0-17",
        "18-64"
      ),
      
      gender = c(
        "Male",
        "Female"
      ),
      
      count = c(
        2,
        3
      )
      
    )
    
    result <- make_agents(
      counts
    )
    
    expect_true(
      
      all(
        
        c(
          "age_group",
          "gender"
        ) %in%
          
          names(result)
        
      )
      
    )
    
  }
)
test_that(
  "make_agents preserves contingency structure",
  {
    
    counts <- data.frame(
      
      age_group = c(
        "0-17",
        "18-64"
      ),
      
      gender = c(
        "Male",
        "Female"
      ),
      
      count = c(
        2,
        3
      )
      
    )
    
    population <- make_agents(
      counts
    )
    
    reconstructed <-
      
      synthetic_population_to_contingency(
        
        population,
        
        c(
          "age_group",
          "gender"
        )
        
      )
    
    data.table::setorder(
      reconstructed,
      age_group,
      gender
    )
    
    expect_equal(
      reconstructed$count,
      counts$count
    )
    
  }
)
test_that(
  "make_agents generates sortable identifiers",
  {
    
    counts <- data.frame(
      
      group = "A",
      
      count = 1000
      
    )
    
    result <- make_agents(
      counts
    )
    
    expect_equal(
      nrow(result),
      1000
    )
    
    expect_equal(
      length(
        unique(
          result$agent_id
        )
      ),
      1000
    )
    
  }
)
test_that(
  "make_agents rejects negative counts",
  {
    
    counts <- data.frame(
      
      group = "A",
      
      count = -1
      
    )
    
    expect_error(
      make_agents(
        counts
      )
    )
    
  }
)
test_that(
  "make_agents rejects missing counts",
  {
    
    counts <- data.frame(
      
      group = "A",
      
      count = NA
      
    )
    
    expect_error(
      make_agents(
        counts
      )
    )
    
  }
)
test_that(
  "make_agents rejects non integer counts",
  {
    
    counts <- data.frame(
      
      group = "A",
      
      count = 1.5
      
    )
    
    expect_error(
      make_agents(
        counts
      )
    )
    
  }
)
test_that(
  "make_agents supports custom count columns",
  {
    
    counts <- data.frame(
      
      age_group = c(
        "0-17",
        "18-64"
      ),
      
      residents = c(
        2,
        3
      )
      
    )
    
    result <- make_agents(
      counts,
      count_col = "residents"
    )
    
    expect_equal(
      nrow(result),
      5
    )
    
  }
)
