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
    50, 30, 20,
    50, 30, 20
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

test_that(
  "depict returns a distribution plot",
  {
    
    p <- depict(
      ADDER,
      type = "distribution"
    )
    
    expect_s3_class(
      p,
      "ggplot"
    )
    
  }
)
test_that(
  "depict returns a difference plot",
  {
    
    p <- depict(
      ADDER,
      type = "difference"
    )
    
    expect_s3_class(
      p,
      "ggplot"
    )
    
  }
)
test_that(
  "depict returns a heatmap plot",
  {
    
    p <- depict(
      ADDER,
      type = "heatmap"
    )
    
    expect_s3_class(
      p,
      "ggplot"
    )
    
  }
)
test_that(
  "depict requires validation results",
  {
    
    adder <- ADDER
    
    adder <- renew(
      adder,
      validation_results = list()
    )
    
    expect_error(
      depict(
        adder,
        type = "distribution"
      ),
      "No validation results available"
    )
    
  }
)
test_that(
  "depict validates type argument",
  {
    
    expect_error(
      depict(
        ADDER,
        type = "invalid"
      ),
      "arg"
    )
    
  }
)
test_that(
  "distribution plot has expected title",
  {
    
    p <- depict(
      ADDER,
      type = "distribution"
    )
    
    expect_equal(
      p$labels$title,
      "Observed and Expected Distributions"
    )
    
  }
)