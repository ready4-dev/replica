library(data.table)
population <- data.table(
  
  agent_id = 1:20,
  
  gender = c(
    rep("Male", 10),
    rep("Female", 10)
  ),
  
  age_group = rep(
    "18-64",
    20
  )
  
)

contingency <- data.table(
  
  age_group = c(
    rep("18-64", 6)
  ),
  
  gender = c(
    rep("Male", 3),
    rep("Female", 3)
  ),
  
  education = c(
    "Degree",
    "Diploma",
    "School",
    "Degree",
    "Diploma",
    "School"
  ),
  
  count = c(
    50, 30, 20,
    50, 30, 20
  )
  
)
test_that(
  "target attribute added",
  {
    
    adder <- ReplicaAdder(
      synth_pop = population,
      contingency = contingency,
      target_attribute = "education",
      group_by = c(
        "age_group",
        "gender"
      )
    )
    
    adder <- enhance(adder)
    
    result <- adder@synth_pop
    
    expect_true(
      "education" %in% names(result)
    )
    
  }
)
test_that(
  "all agents receive target attribute",
  {
    
    adder <- ReplicaAdder(
      synth_pop = population,
      contingency = contingency,
      target_attribute = "education",
      group_by = c(
        "age_group",
        "gender"
      )
    )
    
    adder <- enhance(adder)
    
    result <- adder@synth_pop
    
    expect_false(
      any(
        is.na(
          result$education
        )
      )
    )
    
  }
)
test_that(
  "population size preserved",
  {
    
    adder <- ReplicaAdder(
      synth_pop = population,
      contingency = contingency,
      target_attribute = "education",
      group_by = c(
        "age_group",
        "gender"
      )
    )
    
    adder <- enhance(adder)
    
    expect_equal(
      nrow(adder@synth_pop),
      nrow(population)
    )
    
  }
)
test_that(
  "assigned values account for every agent",
  {
    
    adder <- ReplicaAdder(
      synth_pop = population,
      contingency = contingency,
      target_attribute = "education",
      group_by = c(
        "age_group",
        "gender"
      )
    )
    
    adder <- enhance(adder)
    
    result <- adder@synth_pop
    
    expect_equal(
      
      sum(
        table(
          result$education
        )
      ),
      
      nrow(result)
      
    )
    
  }
)
test_that(
  "error strategy fails on missing groups",
  {
    
    population <- data.frame(
      
      age_group = c(
        "18-64",
        "18-64"
      ),
      
      gender = c(
        "Male",
        "Female"
      )
      
    )
    
    contingency <- data.frame(
      
      age_group = c(
        "18-64",
        "18-64",
        "18-64"
      ),
      
      gender = c(
        "Male",
        "Male",
        "Male"
      ),
      
      education = c(
        "Degree",
        "Diploma",
        "School"
      ),
      
      count = c(
        50,
        30,
        20
      )
      
    )
    
    expect_error(
      
      prepare_contingency_table(
        contingency,
        population,
        c(
          "age_group",
          "gender"
        ),
        "education",
        strategy = "error"
      )
      
    )
    
  }
)
#
population <- data.frame(
  
  age_group = c(
    "18-64",
    "18-64"
  ),
  
  gender = c(
    "Male",
    "Female"
  )
  
)

contingency <- data.frame(
  
  age_group = c(
    "18-64","18-64","18-64",
    "65+","65+","65+"
  ),
  
  gender = c(
    "Male","Male","Male",
    "Male","Male","Male"
  ),
  
  education = c(
    "Degree","Diploma","School",
    "Degree","Diploma","School"
  ),
  
  count = c(
    50,30,20,
    10,20,70
  )
  
)

test_that(
  "overall strategy uses overall distribution",
  {
    
    expanded <- prepare_contingency_table(
      contingency,
      population,
      c(
        "age_group",
        "gender"
      ),
      "education",
      strategy = "overall"
    )
    
    female_rows <- expanded[
      expanded$gender == "Female" &
        expanded$age_group == "18-64",
    ]
    
    expect_equal(
      female_rows$count,
      c(
        60,
        50,
        90
      )
    )
    
  }
)
test_that(
  "borrow strategy uses nearest available distribution",
  {
    
    expanded <- prepare_contingency_table(
      contingency,
      population,
      c(
        "age_group",
        "gender"
      ),
      "education",
      strategy = "borrow"
    )
    
    female_rows <- expanded[
      expanded$gender == "Female" &
        expanded$age_group == "18-64",
    ]
    
    expect_equal(
      female_rows$count,
      c(
        50,
        30,
        20
      )
    )
    
  }
)
test_that(
  "zero count groups do not create NaN fractions",
  {
    
    dt <- data.table(
      
      gender = c(
        "Female",
        "Female",
        "Female"
      ),
      
      education = c(
        "Degree",
        "Diploma",
        "School"
      ),
      
      count = c(
        0,
        0,
        0
      )
      
    )
    
    result <- calculate_fractions(
      dt,
      group_by = "gender",
      target_attribute = "education"
    )
    
    expect_false(
      any(
        is.nan(
          result$fraction
        )
      )
    )
    
    expect_true(
      all(
        result$fraction == 0
      )
    )
    
  }
)
test_that(
  "invalid strategy rejected",
  {
    
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
  "ReplicaAdder runs end to end",
  {
    
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
    
    expect_silent(
      adder <- enhance(adder)
    )
    
    result <- adder@synth_pop
    
    expect_equal(
      nrow(result),
      nrow(population)
    )
    
    expect_false(
      any(
        is.na(
          result$education
        )
      )
    )
    
    expect_equal(
      
      sum(
        table(
          result$education
        )
      ),
      
      nrow(result)
      
    )
    
  }
)
test_that(
  "borrow strategy assigns values to missing groups",
  {
    
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
    
    adder <- enhance(adder)
    
    result <- adder@synth_pop
    
    female_agents <- result[
      gender == "Female"
    ]
    
    expect_true(
      all(
        !is.na(
          female_agents$education
        )
      )
    )
    
  }
)
population <- data.frame(
  
  age_group = c(
    "18-64",
    "18-64"
  ),
  
  gender = c(
    "Male",
    "Female"
  )
  
)

contingency <- data.frame(
  
  age_group = c(
    "18-64","18-64","18-64",
    "65+","65+","65+"
  ),
  
  gender = c(
    "Male","Male","Male",
    "Male","Male","Male"
  ),
  
  education = c(
    "Degree","Diploma","School",
    "Degree","Diploma","School"
  ),
  
  count = c(
    50,30,20,
    10,20,70
  )
  
)
test_that(
  "overall and borrow strategies use different distributions",
  {
    
    overall <- prepare_contingency_table(
      contingency,
      population,
      c(
        "age_group",
        "gender"
      ),
      "education",
      strategy = "overall"
    )
    
    borrow <- prepare_contingency_table(
      contingency,
      population,
      c(
        "age_group",
        "gender"
      ),
      "education",
      strategy = "borrow"
    )
    
    overall_female <- overall[
      overall$gender == "Female" &
        overall$age_group == "18-64",
    ][["count"]]
    
    borrow_female <- borrow[
      borrow$gender == "Female" &
        borrow$age_group == "18-64",
    ][["count"]]
    
    #
    # Overall distribution:
    #
    # Degree  = 50 + 10 = 60
    # Diploma = 30 + 20 = 50
    # School  = 20 + 70 = 90
    #
    
    expect_equal(
      overall_female,
      c(
        60,
        50,
        90
      )
    )
    
    #
    # Borrowed distribution:
    #
    # Copied from 18-64 Male
    #
    
    expect_equal(
      borrow_female,
      c(
        50,
        30,
        20
      )
    )
    
    #
    # Confirm results differ
    #
    
    expect_false(
      identical(
        overall_female,
        borrow_female
      )
    )
    
  }
)
