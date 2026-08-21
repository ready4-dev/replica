library(testthat)
library(data.table)

pop <- data.table(
  
  agent_id = c(
    "A001","A002",
    "A003","A004",
    "C001","C002",
    "C003","C004"
  ),
  
  age = c(
    40,38,
    52,50,
    12,10,
    17,15
  ),
  
  gender = c(
    "Male","Female",
    "Male","Female",
    "Male","Female",
    "Male","Female"
  ),
  
  household_position = c(
    "Parent","Parent",
    "Parent","Parent",
    "Child","Child",
    "Child","Child"
  )
  
)

hh <- ReplicaStructure(
  "Family"
)

hh <- renew(
  hh,
  what = "positions",
  household_position = "Parent",
  position_identifier = "adult",
  amount = 2,
  backup_position_identifiers = character()
)

hh <- renew(
  hh,
  what = "positions",
  household_position = "Child",
  position_identifier = "child",
  amount = 2,
  backup_position_identifiers = character()
)

hh <- renew(
  hh,
  what = "state",
  df_synth_pop = pop,
  household_position_column = "household_position"
)

hh@parent_child_age_distribution <- c(
  "20-30" = 1
)

parents <- list(
  
  list(
    c("A001","40","Male"),
    c("A002","38","Female")
  ),
  
  list(
    c("A003","52","Male"),
    c("A004","50","Female")
  )
  
)

children <- list(
  
  c(
    "C001",
    "C002"
  ),
  
  c(
    "C003",
    "C004"
  )
  
)

test_that(
  "matchAdultsWithChildren creates valid family households",
  {
    
    result <- matchAdultsWithChildren(
      hh,
      parents,
      children,
      id_offset = 1
    )
    
    expect_equal(
      length(
        result$object@households
      ),
      2
    )
    
    expect_equal(
      result$id_offset,
      3
    )
    
  }
)
test_that(
  "all children assigned exactly once",
  {
    
    result <- matchAdultsWithChildren(
      hh,
      parents,
      children,
      id_offset = 1
    )
    
    assigned_children <- unlist(
      
      lapply(
        
        result$object@households,
        
        function(household) {
          
          household$all[
            grepl(
              "^C",
              household$all
            )
          ]
          
        }
        
      ),
      
      use.names = FALSE
      
    )
    
    expect_equal(
      length(assigned_children),
      4
    )
    
    expect_equal(
      length(unique(assigned_children)),
      4
    )
    
    expect_true(
      
      setequal(
        
        assigned_children,
        
        c(
          "C001",
          "C002",
          "C003",
          "C004"
        )
        
      )
      
    )
    
  }
)
test_that(
  "all parents assigned exactly once",
  {
    
    result <- matchAdultsWithChildren(
      hh,
      parents,
      children,
      id_offset = 1
    )
    
    assigned_parents <- unlist(
      
      lapply(
        
        result$object@households,
        
        function(household) {
          
          household$all[
            grepl(
              "^A",
              household$all
            )
          ]
          
        }
        
      ),
      
      use.names = FALSE
      
    )
    
    expect_equal(
      length(assigned_parents),
      4
    )
    
    expect_equal(
      length(unique(assigned_parents)),
      4
    )
    
  }
)
test_that(
  "family households contain four members",
  {
    
    result <- matchAdultsWithChildren(
      hh,
      parents,
      children,
      id_offset = 1
    )
    
    household_sizes <- sapply(
      
      result$object@households,
      
      function(x)
        length(x$all)
      
    )
    
    expect_true(
      all(
        household_sizes == 4
      )
    )
    
  }
)
test_that(
  "all source agents appear exactly once",
  {
    
    result <- matchAdultsWithChildren(
      hh,
      parents,
      children,
      id_offset = 1
    )
    
    all_agents <- getAllAgents(
      result$object
    )
    
    expect_true(
      setequal(
        all_agents,
        pop$agent_id
      )
    )
    
    expect_equal(
      length(all_agents),
      8
    )
    
    expect_equal(
      length(unique(all_agents)),
      8
    )
    
  }
)
test_that(
  "each household contains two parents and two children",
  {
    
    result <- matchAdultsWithChildren(
      hh,
      parents,
      children,
      id_offset = 1
    )
    
    for (household in result$object@households) {
      
      parents_n <- sum(
        grepl("^A", household$all)
      )
      
      children_n <- sum(
        grepl("^C", household$all)
      )
      
      expect_equal(
        parents_n,
        2
      )
      
      expect_equal(
        children_n,
        2
      )
      
    }
    
  }
)
test_that(
  "family household stores adults and children separately",
  {
    
    result <- matchAdultsWithChildren(
      hh,
      parents,
      children,
      id_offset = 1
    )
    
    household <-
      result$object@households[[1]]
    
    expect_equal(
      length(household$adult),
      2
    )
    
    expect_equal(
      length(household$child),
      2
    )
    
    expect_equal(
      length(household$all),
      4
    )
    
  }
)
