# R/globals.R

# Global variables used by data.table NSE

utils::globalVariables(
  
  c(
    
    ":=",
    ".",
    ".N",
    ".SD",
    
    "agent_id",
    "household_id",
    
    "age",
    
    "count",
    "count_x",
    "count_y",
    
    "fraction",
    
    "frac_x",
    "frac_y",
    
    "total_x",
    "total_y",
    
    "neighb_code",
    
    #
    # Validation framework
    #
    
    "observed_pct",
    "expected_pct",
    "difference_pct",
    
    #
    # Plotting functions
    #
    
    "group_label",
    "distribution",
    "percentage",
    
    #
    # Legacy helper
    #
    
    "pct",
    
    # Make agents
    
    "..attribute_cols"
    
  )
  
)
