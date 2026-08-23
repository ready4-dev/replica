library(testthat)
library(data.table)

test_that(
  "group_children matches Python",
  {
    
    set.seed(123)
    
    py_sizes <- read.csv(
      system.file("reference_data","group_children_sizes.csv", package = "replica")
         )
    
    py_agents <- read.csv(
      system.file("reference_data","group_children_agents.csv", package = "replica")
    )
    
    pop <- data.table(
      
      agent_id = c(
        "C001",
        "C002",
        "C003",
        "C004"
      ),
      
      age = c(
        10,
        11,
        17,
        18
      ),
      
      gender = c(
        "Male",
        "Female",
        "Male",
        "Female"
      ),
      
      household_position = c(
        "Child",
        "Child",
        "Child",
        "Child"
      )
      
    )
    
    STRUCTURE <- ReplicaStructure(
      "Family"
    )
    
    STRUCTURE <- renew(
      STRUCTURE,
      what = "positions",
      household_position = "Child",
      position_identifier = "child",
      amount = 2,
      backup_position_identifiers =
        character()
    )
    
    STRUCTURE <- renew(
      STRUCTURE,
      what = "state",
      population = pop,
      position_column = "household_position"
    )
    
    STRUCTURE@assigned_agents <- character()
    
    child_position <- replica:::getPositionForName(
      STRUCTURE,
      "child"
    )
    groups <- group_children(
      STRUCTURE,
      rep(
        TRUE,
        nrow(pop)
      ),
      child_position
    )
    
    updated_STRUCTURE <- attr(
      groups,
      "object"
    )
    expect_equal(
      
      sort(
        extract_group_sizes(
          groups
        )
      ),
      
      sort(
        py_sizes$
          group_size
      )
      
    )
    expect_equal(
      
      sort(
        updated_STRUCTURE@
          assigned_agents
      ),
      
      sort(
        py_agents$
          agent_id
      )
      
    )
    expect_true(
      
      setequal(
        
        updated_STRUCTURE@
          assigned_agents,
        
        pop$
          agent_id
        
      )
      
    )
    expect_equal(
      
      length(
        updated_STRUCTURE@
          assigned_agents
      ),
      
      length(
        
        unique(
          
          updated_STRUCTURE@
            assigned_agents
          
        )
        
      )
      
    )
    expect_equal(
      
      nrow(
        
        getRemainingAgentsInPosition(
          updated_STRUCTURE,
          "Child"
        )
        
      ),
      
      0
      
    )
    expect_true(
      
      all(
        
        sapply(
          groups,
          length
        ) == 2
        
      )
      
    )
    age_spreads <- sapply(
      
      groups,
      
      function(ids) {
        
        ages <- pop[
          agent_id %in% ids,
          age
        ]
        
        max(ages) -
          min(ages)
        
      }
      
    )
    
    expect_true(
      all(
        age_spreads <= 1
      )
    )
    
  }
)
    
