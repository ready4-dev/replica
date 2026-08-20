library(testthat)
library(data.table)

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

hh <- ReplicaStructure(
  "Family"
)

hh <- renew(
  hh,
  household_position = "Child",
  position_identifier = "child",
  amount = 2,
  backup_position_identifiers = character()
)

hh <- updateState(
  hh,
  pop,
  "household_position"
)

hh@sampled_agents <- character()

child_position <- getPositionForName(
  hh,
  "child"
)
test_that(
  "group_children creates expected number of sibling groups",
  {
    
    set.seed(123)
    
    groups <- group_children(
      hh,
      rep(
        TRUE,
        nrow(pop)
      ),
      child_position
    )
    
    expect_equal(
      length(groups),
      2
    )
    
  }
)
test_that(
  "all children assigned",
  {
    
    set.seed(123)
    
    groups <- group_children(
      hh,
      rep(
        TRUE,
        nrow(pop)
      ),
      child_position
    )
    
    updated_hh <- attr(
      groups,
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
  "no duplicate child assignments",
  {
    
    set.seed(123)
    
    groups <- group_children(
      hh,
      rep(
        TRUE,
        nrow(pop)
      ),
      child_position
    )
    
    updated_hh <- attr(
      groups,
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
  "no children remain available",
  {
    
    set.seed(123)
    
    groups <- group_children(
      hh,
      rep(
        TRUE,
        nrow(pop)
      ),
      child_position
    )
    
    updated_hh <- attr(
      groups,
      "object"
    )
    
    remaining <- getRemainingAgentsInPosition(
      updated_hh,
      "Child"
    )
    
    expect_equal(
      nrow(remaining),
      0
    )
    
  }
)
test_that(
  "each sibling group has expected size",
  {
    
    set.seed(123)
    
    groups <- group_children(
      hh,
      rep(
        TRUE,
        nrow(pop)
      ),
      child_position
    )
    
    expect_true(
      
      all(
        
        sapply(
          groups,
          length
        ) == 2
        
      )
      
    )
    
  }
)
test_that(
  "all source children appear exactly once",
  {
    
    set.seed(123)
    
    groups <- group_children(
      hh,
      rep(
        TRUE,
        nrow(pop)
      ),
      child_position
    )
    
    assigned_children <- unlist(
      groups,
      use.names = FALSE
    )
    
    expect_equal(
      length(assigned_children),
      4
    )
    
    expect_equal(
      length(
        unique(
          assigned_children
        )
      ),
      4
    )
    
    expect_true(
      
      setequal(
        
        assigned_children,
        
        pop$agent_id
        
      )
      
    )
    
  }
)
test_that(
  "children grouped by similar ages",
  {
    
    set.seed(123)
    
    groups <- group_children(
      hh,
      rep(
        TRUE,
        nrow(pop)
      ),
      child_position
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
test_that(
  "all children assigned exactly once",
  {
    
    set.seed(123)
    
    groups <- group_children(
      hh,
      rep(
        TRUE,
        nrow(pop)
      ),
      child_position
    )
    
    updated_hh <- attr(
      groups,
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
      
      length(
        
        unique(
          updated_hh@sampled_agents
        )
        
      )
      
    )
    
  }
)
