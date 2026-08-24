
#' Plot observed and expected distributions
#'
#' Creates a faceted comparison of observed and expected
#' percentages from a validation result.
#'
#' @param validation_result A validation object returned by
#' \code{\link{validate_synthetic_population_fit}} or stored in
#' the \code{validation_results} slot of a
#' \code{\link{ReplicaAdder}}.
#'
#' @return A ggplot object.
#'
#' @examples
#' \dontrun{
#' plot_validation_distributions(
#'   procure(ADDER, "validation_results")
#' )
#' }
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

#' Plot percentage-point differences
#'
#' Creates a visualisation of percentage-point differences
#' between observed and expected distributions.
#'
#' @param validation_result A validation object returned by
#' \code{\link{validate_synthetic_population_fit}}.
#'
#' @return A ggplot object.
#'
#' @examples
#' \dontrun{
#' plot_validation_differences(
#'   procure(ADDER, "validation_results")
#' )
#' }
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
#' Plot validation heatmap
#'
#' Creates a heatmap showing percentage-point differences
#' between observed and expected distributions across
#' conditioning groups.
#'
#' @param validation_result A validation object returned by
#' \code{\link{validate_synthetic_population_fit}}.
#'
#' @return A ggplot object.
#'
#' @examples
#' \dontrun{
#' plot_validation_heatmap(
#'   procure(ADDER, "validation_results")
#' )
#' }
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
