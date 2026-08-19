add_percentages <- function(
    dt,
    dimensions
) {
  
  dt <- data.table::copy(dt)
  
  dt[
    ,
    pct := 100 * count / sum(count),
    by = dimensions
  ]
  
  dt
  
}

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