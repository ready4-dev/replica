library(testthat)
library(data.table)

test_that(
  "valid ReplicaStructure passes validation",
  {
    
    hh <- ReplicaStructure(
      "Family"
    )
    
    expect_true(
      validObject(
        hh,
        test = TRUE
      )
    )
    
  }
)
test_that(
  "ReplicaStructure requires single hh_type",
  {
    
    expect_error(
      
      new(
        
        "ReplicaStructure",
        
        hh_type = character(),
        
        positions = list(),
        
        position_identifiers = list(),
        
        households = list(),
        
        sampled_agents = character(),
        
        couple_gender_distribution =
          numeric(),
        
        couple_age_distribution =
          numeric(),
        
        parent_child_age_distribution =
          numeric(),
        
        df_synth_pop =
          data.table(),
        
        household_position_column =
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
        df_synth_pop = pop,
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
    
    hg <- ReplicaGrouper(
      df_synth_pop = pop,
      group_by = "neighb_code"
    )
    
    expect_true(
      validObject(
        hg,
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
    
    contingency <- data.table(
      
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
        synth_pop = population,
        contingency = contingency,
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
    
    contingency <- data.table(
      
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
        synth_pop = population,
        contingency = contingency,
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
    
    contingency <- data.table(
      
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
    
    adder <- ReplicaAdder(
      synth_pop = population,
      contingency = contingency,
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
        adder,
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
    
    hg <- ReplicaGrouper(
      df_synth_pop = pop,
      group_by = "neighb_code"
    )
    
    expect_error(
      enhance(hg)
    )
    
  }
)
