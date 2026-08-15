test_that(
  "z squared score calculated",
  {
    
    df <- data.frame(
      
      count_x = c(
        40,
        35,
        25
      ),
      
      count_y = c(
        45,
        30,
        25
      )
      
    )
    
    result <- calculate_z_squared_score(
      df
    )
    
    expect_true(
      is.list(result)
    )
    
    expect_true(
      result$z_square >= 0
    )
    
    expect_equal(
      result$degrees_of_freedom,
      3
    )
    
  }
)