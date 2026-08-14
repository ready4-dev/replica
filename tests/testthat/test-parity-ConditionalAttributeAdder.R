test_that(
  "ConditionalAttributeAdder matches Python",
  {
    
    set.seed(123)
    
    python_result <- read.csv(
      "Export/GenSynthPopR/parity/reference_data/conditional_attribute_adder.csv"
    )
    
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
        50,30,20,
        50,30,20
      )
      
    )
    
    adder <- ConditionalAttributeAdder(
      synth_pop = population,
      contingency = contingency,
      target_attribute = "education",
      group_by = c(
        "age_group",
        "gender"
      )
    )
    
    adder <- run(adder)
    
    r_result <- adder@synth_pop
    
    expect_same_contingency(
      
      r_result,
      python_result,
      
      c(
        "age_group",
        "gender",
        "education"
      )
      
    )
    
  }
)