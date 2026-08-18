add_validation_group_labels <- function(
    details,
    conditioning_variables
) {
  
  details <- data.table::copy(
    details
  )
  
  if (
    length(
      conditioning_variables
    ) == 0
  ) {
    
    details[
      ,
      group_label := "All"
    ]
    
  } else {
    
    details[
      ,
      group_label :=
        do.call(
          paste,
          c(
            .SD,
            sep = " | "
          )
        ),
      .SDcols =
        conditioning_variables
    ]
    
  }
  
  details
  
}

get_validation_structure <- function(
    validation_result
) {
  
  details <- validation_result$details
  
  metric_columns <- c(
    "count_x",
    "count_y",
    "observed_pct",
    "expected_pct",
    "difference_pct"
  )
  
  dimensions <- setdiff(
    names(details),
    metric_columns
  )
  
  outcome_variable <- tail(
    dimensions,
    1
  )
  
  conditioning_variables <- head(
    dimensions,
    -1
  )
  
  list(
    details = details,
    dimensions = dimensions,
    outcome_variable = outcome_variable,
    conditioning_variables =
      conditioning_variables
  )
  
}

#' Plot Observed and Expected Distributions
#'
#' Visualises observed and expected percentages from a
#' validation result.
#'
#' @param validation_result Output from
#' \code{\link{validate_synthetic_population_fit}} or
#' \code{validation_results} stored in a
#' \code{\link{ConditionalAttributeAdder}} object.
#'
#' @return A ggplot object.
#'
#' @export
plot_validation_distributions <- function(
    validation_result
) {
  
  info <-
    get_validation_structure(
      validation_result
    )
  
  details <-
    
    add_validation_group_labels(
      info$details,
      info$conditioning_variables
    )
  
  plot_dt <- data.table::melt(
    
    details,
    
    id.vars = c(
      "group_label",
      info$outcome_variable
    ),
    
    measure.vars = c(
      "observed_pct",
      "expected_pct"
    ),
    
    variable.name =
      "distribution",
    
    value.name =
      "percentage"
    
  )
  
  ggplot2::ggplot(
    
    plot_dt,
    
    ggplot2::aes(
      
      x =
        .data[[
          info$outcome_variable
        ]],
      
      y = percentage,
      
      fill = distribution
      
    )
    
  ) +
    
    ggplot2::geom_col(
      position = "dodge"
    ) +
    
    ggplot2::facet_wrap(
      ~ group_label
    ) +
    
    ggplot2::labs(
      title =
        "Observed and Expected Distributions",
      x = NULL,
      y = "Percentage"
    )
  
}

#' Plot Percentage-Point Differences
#'
#' Visualises the difference between observed and expected
#' percentages.
#'
#' @param validation_result Output from
#' \code{\link{validate_synthetic_population_fit}}.
#'
#' @return A ggplot object.
#'
#' @export
plot_validation_differences <- function(
    validation_result
) {
  
  info <-
    get_validation_structure(
      validation_result
    )
  
  details <-
    
    add_validation_group_labels(
      info$details,
      info$conditioning_variables
    )
  
  ggplot2::ggplot(
    
    details,
    
    ggplot2::aes(
      
      x =
        .data[[
          info$outcome_variable
        ]],
      
      y =
        difference_pct,
      
      colour =
        .data[[
          info$outcome_variable
        ]]
      
    )
    
  ) +
    
    ggplot2::geom_hline(
      yintercept = 0,
      linetype = 2
    ) +
    
    ggplot2::geom_segment(
      
      ggplot2::aes(
        
        xend =
          .data[[
            info$outcome_variable
          ]],
        
        y = 0,
        
        yend =
          difference_pct
        
      )
      
    ) +
    
    ggplot2::geom_point(
      size = 3
    ) +
    
    ggplot2::facet_wrap(
      ~ group_label
    ) +
    
    ggplot2::labs(
      title =
        "Percentage-Point Differences",
      x = NULL,
      y =
        "Observed - Expected (%)"
    )
  
}
#' Plot Validation Heatmap
#'
#' Visualises percentage-point differences as a heat map.
#'
#' @param validation_result Output from
#' \code{\link{validate_synthetic_population_fit}}.
#'
#' @return A ggplot object.
#'
#' @export
plot_validation_heatmap <- function(
    validation_result
) {
  
  info <-
    get_validation_structure(
      validation_result
    )
  
  details <-
    
    add_validation_group_labels(
      info$details,
      info$conditioning_variables
    )
  
  ggplot2::ggplot(
    
    details,
    
    ggplot2::aes(
      
      x =
        .data[[
          info$outcome_variable
        ]],
      
      y =
        group_label,
      
      fill =
        difference_pct
      
    )
    
  ) +
    
    ggplot2::geom_tile() +
    
    ggplot2::scale_fill_gradient2(
      
      low = "steelblue",
      
      mid = "white",
      
      high = "firebrick",
      
      midpoint = 0
      
    ) +
    
    ggplot2::labs(
      
      title =
        "Validation Heatmap",
      
      x = NULL,
      
      y =
        "Conditioning Group",
      
      fill =
        "Difference (%)"
      
    )
  
}

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
#' Validate the Fit of a Synthetic Population
#'
#' Compares a synthetic population against an expected
#' contingency table and evaluates goodness-of-fit.
#'
#' @param synthetic_population A synthetic population stored as
#' a data.frame or data.table.
#'
#' @param expected Reference contingency table containing the
#' expected distribution.
#'
#' @param dimensions Character vector identifying the variables
#' used to construct the comparison contingency table.
#'
#' @param name Character string used in validation messages and
#' warning output.
#'
#' @return A list object with multiple comparison results.
#'
#' @details
#' The function:
#'
#' \enumerate{
#'   \item Converts the synthetic population into a contingency
#'         table using
#'         \code{\link{synthetic_population_to_contingency}}.
#'
#'   \item Aligns the observed and expected distributions.
#'
#'   \item Calculates goodness-of-fit statistics using
#'         \code{\link{calculate_z_squared_score}}.
#'
#'   \item Emits a warning if the p-value is below 0.05.
#' }
#'
#' @examples
#' \dontrun{
#'
#' validate_synthetic_population_fit(
#'   synthetic_population,
#'   expected,
#'   dimensions = c(
#'     "gender",
#'     "education"
#'   ),
#'   name = "Education"
#' )
#'
#' }
#'
#' @seealso
#' \code{\link{calculate_z_squared_score}},
#' \code{\link{synthetic_population_to_contingency}}
#'
#' @export
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
  
  #
  # Calculate percentages within the
  # conditioning dimensions only.
  #
  # Example:
  #
  # dimensions =
  #   c(
  #     "age_group",
  #     "gender",
  #     "education"
  #   )
  #
  # name =
  #   "education"
  #
  # conditioning_dimensions =
  #   c(
  #     "age_group",
  #     "gender"
  #   )
  #
  
  conditioning_dimensions <-
    
    setdiff(
      dimensions,
      name
    )
  
  combined[
    ,
    observed_pct :=
      100 *
      count_x /
      sum(count_x),
    by = conditioning_dimensions
  ]
  
  combined[
    ,
    expected_pct :=
      100 *
      count_y /
      sum(count_y),
    by = conditioning_dimensions
  ]
  
  combined[
    ,
    difference_pct :=
      observed_pct -
      expected_pct
  ]
  
  #
  # Reorder columns
  #
  
  comparison_columns <- c(
    "count_x",
    "count_y",
    "observed_pct",
    "expected_pct",
    "difference_pct"
  )
  
  combined <-
    
    combined[
      ,
      c(
        dimensions,
        comparison_columns
      ),
      with = FALSE
    ]
  
  z_result <-
    
    calculate_z_squared_score(
      combined
    )
  
  warning_required <-
    z_result$p_value < 0.05
  
  list(
    
    name = name,
    
    z_square =
      z_result$z_square,
    
    p_value =
      z_result$p_value,
    
    degrees_of_freedom =
      z_result$degrees_of_freedom,
    
    critical_value =
      z_result$critical_value,
    
    warning_required =
      warning_required,
    
    details =
      combined
    
  )
  
}