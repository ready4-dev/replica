library(testthat)
library(data.table)

test_that(
  "valid ReplicaStructure passes validation",
  {
    
    STRUCTURE <- ReplicaStructure(
      "Family"
    )
    
    expect_true(
      validObject(
        STRUCTURE,
        test = TRUE
      )
    )
    
  }
)
test_that(
  "ReplicaStructure requires single household_type",
  {
    
    expect_error(
      
      new(
        
        "ReplicaStructure",
        
        household_type = character(),
        
        positions = list(),
        
        position_identifiers = list(),
        
        households = list(),
        
        assigned_agents = character(),
        
        couple_gender_distribution =
          numeric(),
        
        couple_age_distribution =
          numeric(),
        
        parent_child_age_distribution =
          numeric(),
        
        population =
          data.table(),
        
        position_column =
          ""
        
      )
      
    )
    
  }
)

test_that(
  "ReplicaGrouper rejects missing group variables",
  {
    
    pop <- data.table(
      agent_id = 1:5
    )
    
    expect_error(
      
      ReplicaGrouper(
        population = pop,
        group_by = "neighb_code"
      )
      
    )
    
  }
)
test_that(
  "valid ReplicaGrouper passes validation",
  {
    
    pop <- data.table(
      
      agent_id = 1:5,
      
      neighb_code = c(
        "N1",
        "N1",
        "N2",
        "N2",
        "N2"
      )
      
    )
    
    GROUPER <- ReplicaGrouper(
      population = pop,
      group_by = "neighb_code"
    )
    
    expect_true(
      validObject(
        GROUPER,
        test = TRUE
      )
    )
    
  }
)

test_that(
  "ReplicaAdder requires count column",
  {
    
    population <- data.table(
      
      gender = c(
        "Male",
        "Female"
      ),
      
      age_group = c(
        "18-64",
        "18-64"
      )
      
    )
    
    contingency_table <- data.table(
      
      age_group = c(
        "18-64"
      ),
      
      gender = c(
        "Male"
      ),
      
      education = c(
        "Degree"
      )
      
    )
    
    expect_error(
      
      ReplicaAdder(
        population = population,
        contingency_table = contingency_table,
        target_attribute = "education",
        group_by = c(
          "age_group",
          "gender"
        )
      )
      
    )
    
  }
)
test_that(
  "invalid missing_group_strategy rejected",
  {
    
    population <- data.table(
      
      gender = c(
        "Male",
        "Female"
      ),
      
      age_group = c(
        "18-64",
        "18-64"
      )
      
    )
    
    contingency_table <- data.table(
      
      age_group = c(
        "18-64"
      ),
      
      gender = c(
        "Male"
      ),
      
      education = c(
        "Degree"
      ),
      
      count = 1
      
    )
    
    expect_error(
      
      ReplicaAdder(
        population = population,
        contingency_table = contingency_table,
        target_attribute = "education",
        group_by = c(
          "age_group",
          "gender"
        ),
        missing_group_strategy =
          "banana"
      )
      
    )
    
  }
)
test_that(
  "valid ReplicaAdder passes validation",
  {
    
    population <- data.table(
      
      gender = c(
        "Male",
        "Female"
      ),
      
      age_group = c(
        "18-64",
        "18-64"
      )
      
    )
    
    contingency_table <- data.table(
      
      age_group = c(
        "18-64"
      ),
      
      gender = c(
        "Male"
      ),
      
      education = c(
        "Degree"
      ),
      
      count = 1
      
    )
    
    ADDER <- ReplicaAdder(
      population = population,
      contingency_table = contingency_table,
      target_attribute = "education",
      group_by = c(
        "age_group",
        "gender"
      ),
      missing_group_strategy =
        "borrow"
    )
    
    expect_true(
      validObject(
        ADDER,
        test = TRUE
      )
    )
    
  }
)
test_that(
  "run-ReplicaGrouper requires household types",
  {
    
    pop <- data.table(
      
      agent_id = 1:5,
      
      neighb_code = c(
        "N1",
        "N1",
        "N2",
        "N2",
        "N2"
      )
      
    )
    
    GROUPER <- ReplicaGrouper(
      population = pop,
      group_by = "neighb_code"
    )
    
    expect_error(
      manufacture(GROUPER)
    )
    
  }
)
