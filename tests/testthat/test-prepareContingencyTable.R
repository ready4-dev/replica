library(testthat)
library(data.table)

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

contingency_table <- data.frame(
  
  age_group = c(
    "18-64","18-64","18-64",
    "65+","65+","65+"
  ),
  
  gender = c(
    "Male","Male","Male",
    "Male","Male","Male"
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
    10,20,70
  )
  
)
test_that(
  "error strategy fails when groups are missing",
  {
    
    expect_error(
      
      update_contingency_table(
        contingency_table,
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
test_that(
  "overall strategy fills missing groups",
  {
    
    expanded <- update_contingency_table(
      contingency_table,
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
      nrow(female_rows),
      3
    )
    
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
  "borrow strategy uses nearest distribution",
  {
    
    expanded <- update_contingency_table(
      contingency_table,
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
      nrow(female_rows),
      3
    )
    
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
  "overall and borrow strategies differ",
  {
    
    overall <- update_contingency_table(
      contingency_table,
      population,
      c(
        "age_group",
        "gender"
      ),
      "education",
      strategy = "overall"
    )
    
    borrow <- update_contingency_table(
      contingency_table,
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
    
    expect_equal(
      overall_female,
      c(
        60,
        50,
        90
      )
    )
    
    expect_equal(
      borrow_female,
      c(
        50,
        30,
        20
      )
    )
    
    expect_false(
      identical(
        overall_female,
        borrow_female
      )
    )
    
  }
)
test_that(
  "result returned as data.table",
  {
    
    expanded <- update_contingency_table(
      contingency_table,
      population,
      c(
        "age_group",
        "gender"
      ),
      "education",
      strategy = "borrow"
    )
    
    expect_true(
      data.table::is.data.table(
        expanded
      )
    )
    
  }
)
test_that(
  "all required groups represented",
  {
    
    expanded <- update_contingency_table(
      contingency_table,
      population,
      c(
        "age_group",
        "gender"
      ),
      "education",
      strategy = "borrow"
    )
    
    expect_true(
      any(
        expanded$gender ==
          "Female"
      )
    )
    
  }
)
test_that(
  "existing contingency rows preserved",
  {
    
    expanded <- update_contingency_table(
      contingency_table,
      population,
      c(
        "age_group",
        "gender"
      ),
      "education",
      strategy = "borrow"
    )
    
    male_rows <- expanded[
      expanded$gender == "Male" &
        expanded$age_group == "18-64",
    ][["count"]]
    
    expect_equal(
      male_rows,
      c(
        50,
        30,
        20
      )
    )
    
  }
)
