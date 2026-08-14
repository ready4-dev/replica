## Constants
calculate_goodness_of_fit <- function(df,
                                      CRITICAL_ALPHA = c(0.05)) {
  
  dof <- nrow(df)
  
  numerator <-
    (df$count_x - df$count_y)^2
  
  denominator <-
    ifelse(df$count_y == 0,
           1,
           df$count_y)
  
  x2 <- sum(numerator / denominator)
  
  p_value <-
    1 - stats::pchisq(
      x2,
      df = dof
    )
  
  critical_values <-
    stats::qchisq(
      1 - CRITICAL_ALPHA,
      df = dof
    )
  
  list(
    score = x2,
    p = p_value,
    dof = dof,
    critical_values = critical_values
  )
}

.calculate_one_z <- function(
    count_x,
    count_y,
    observed_total,
    expected_total
) {
  
  observed_proportion <-
    count_x / observed_total
  
  expected_proportion <-
    count_y / expected_total
  
  numerator <-
    observed_proportion -
    expected_proportion
  
  if (count_y != 0) {
    
    continuity_factor <-
      1 / (2 * expected_total)
    
    if (numerator >= 0) {
      
      numerator <-
        numerator -
        continuity_factor
      
    } else {
      
      numerator <-
        numerator +
        continuity_factor
    }
  }
  
  if (count_y == 0) {
    
    expected_proportion <-
      1 / expected_total
  }
  
  denominator <-
    sqrt(
      expected_proportion *
        (1 - expected_proportion) /
        expected_total
    )
  
  numerator / denominator
}

percentage_points_difference <- function(df) {
  
  df <- data.table::as.data.table(df)
  
  if ("neighb_code" %in% names(df)) {
    
    df[
      ,
      total_x := sum(count_x),
      by = neighb_code
    ]
    
    df[
      ,
      total_y := sum(count_y),
      by = neighb_code
    ]
    
    df[
      ,
      count_y := count_y / total_y * total_x
    ]
    
  } else {
    
    df[, total_x := sum(count_x)]
    df[, total_y := sum(count_y)]
  }
  
  df[
    ,
    frac_x := count_x / total_x
  ]
  
  df[
    ,
    frac_y := count_y / total_y
  ]
  
  sum(abs(df$frac_x - df$frac_y))
}
score_distribution <- function(df) {
  
  z_result <-
    calculate_z_squared_score(df)
  
  gof_result <-
    calculate_goodness_of_fit(df)
  
  data.frame(
    
    Metric = c(
      "Z-score",
      "Goodness of Fit"
    ),
    
    Statistic = c(
      z_result$z_square,
      gof_result$score
    ),
    
    DoF = c(
      z_result$dof,
      gof_result$dof
    ),
    
    PValue = c(
      z_result$p,
      gof_result$p
    )
  )
}

standardised_absolute_error <- function(df) {
  
  total_absolute_error(df) /
    sum(df$count_y)
  
}

total_absolute_error <- function(df) {
  
  df <- as.data.frame(df)
  
  obs_total <- sum(df$count_x)
  exp_total <- sum(df$count_y)
  
  rel_diff <-
    abs(obs_total - exp_total) /
    mean(c(obs_total, exp_total))
  
  if (rel_diff > 0.05) {
    
    message(
      "Scaling expected values before calculating TAE"
    )
    
    df$count_y <-
      df$count_y /
      exp_total *
      obs_total
  }
  
  sum(abs(df$count_x - df$count_y))
}