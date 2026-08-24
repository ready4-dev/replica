test_that(
  "ReplicaAdder matches Python",
  {
    
    set.seed(123)
    
    python_result <- read.csv(
      system.file("reference_data","conditional_attribute_adder.csv", package = "replica")
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
    
    contingency_table <- data.table(
      
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
    
    ADDER <- ReplicaAdder(
      population = population,
      contingency_table = contingency_table,
      target_attribute = "education",
      group_by = c(
        "age_group",
        "gender"
      )
    )
    
    ADDER <- enhance(ADDER)
    
    r_result <- procure(ADDER, "population")
    
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
