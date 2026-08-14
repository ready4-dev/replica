create_table_row <- function(
    combined_data,
    target_attribute,
    jointed_over
) {
  
  zres <-
    calculate_z_squared_score(
      combined_data
    )
  
  gof <-
    calculate_goodness_of_fit(
      combined_data
    )
  
  data.frame(
    TargetAttribute =
      target_attribute,
    
    JointDistribution =
      jointed_over,
    
    DoF = zres$dof,
    
    ZSquare =
      zres$z_square,
    
    ZPValue =
      zres$p,
    
    XSquare =
      gof$score,
    
    XPValue =
      gof$p,
    
    TAE =
      total_absolute_error(
        combined_data
      ),
    
    SAE =
      standardised_absolute_error(
        combined_data
      )
  )
}