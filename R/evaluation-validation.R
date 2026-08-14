validate_fitted_distribution <- function(
    fitted_distribution,
    margins,
    margin_names,
    joint_distribution_name
) {
  
  if (is.character(margin_names)) {
    
    margin_names <- c(margin_names)
    
  }
  
  fitted <-
    fitted_distribution[
      ,
      .(count = sum(count)),
      by = margin_names
    ]
  
  combined <-
    merge(
      fitted,
      margins,
      by = margin_names
    )
  
  result <-
    calculate_z_squared_score(
      combined
    )
  
  if (result$p < 0.05) {
    
    warning(
      paste(
        "Fitted", joint_distribution_name,
        "does not fit supplied margins."
      )
    )
    
  } else {
    
    message(
      paste(
        joint_distribution_name,
        "fits margins."
      )
    )
  }
  
  invisible(result)
}

validate_synthetic_population_fit <- function(
    synthetic_population,
    expected,
    dimensions,
    name
) {
  
  observed <-
    synthetic_population_to_contingency(
      synthetic_population,
      dimensions
    )
  
  observed <- data.table::as.data.table(
    observed
  )
  
  expected <- data.table::as.data.table(
    expected
  )
  
  combined <-
    merge(
      observed,
      expected,
      by = dimensions,
      suffixes = c(
        "_x",
        "_y"
      )
    )
  
  result <-
    calculate_z_squared_score(
      combined
    )
  
  if (result$p < 0.05) {
    
    warning(
      sprintf(
        "%s distribution differs from expected",
        name
      )
    )
  }
  
  invisible(result)
}