#' Prepare a Contingency Table for Attribute Assignment
#'
#' Ensures that all conditioning-group combinations present in a
#' synthetic population are represented in a contingency table.
#'
#' Missing contingency groups can be handled using one of three
#' configurable strategies:
#'
#' \describe{
#'   \item{borrow}{
#'     Borrow the nearest available conditional distribution.
#'   }
#'   \item{overall}{
#'     Use the overall target-attribute distribution.
#'   }
#'   \item{error}{
#'     Stop with an error if required groups are missing.
#'   }
#' }
#'
#' This function is typically invoked automatically by
#' \code{\link{enhance}} before conditional attribute assignment
#' begins.
#'
#' @param contingency A contingency table containing the target
#' attribute and a \code{count} column.
#'
#' @param synth_pop A synthetic population used to determine
#' which conditioning-group combinations must be represented.
#'
#' @param group_by Character vector containing the conditioning
#' variables used during attribute assignment.
#'
#' @param target_attribute Character string identifying the
#' target attribute.
#'
#' @param strategy Character string specifying how missing
#' contingency groups should be handled.
#'
#' One of:
#'
#' \itemize{
#'   \item \code{"borrow"}
#'   \item \code{"overall"}
#'   \item \code{"error"}
#' }
#'
#' @return A completed contingency table returned as a
#' \code{data.table}.
#'
#' @details
#' The function compares all unique combinations of
#' \code{group_by} variables found in the synthetic population
#' against those present in the contingency table.
#'
#' Any missing combinations are handled according to the
#' specified strategy.
#'
#' For \code{"borrow"}, the function attempts to construct a
#' distribution using a less-specific grouping level before
#' falling back to the overall distribution.
#'
#' For \code{"overall"}, the function uses the overall
#' target-attribute distribution computed from the contingency
#' table.
#'
#' For \code{"error"}, an exception is raised whenever one or
#' more required conditioning groups are missing.
#'
#' This function prevents failures during attribute assignment
#' caused by incomplete contingency tables and provides a
#' configurable mechanism for handling sparse input data.
#'
#' @examples
#' \dontrun{
#'
#' population <- data.frame(
#'   age_group = c(
#'     "18-64",
#'     "18-64"
#'   ),
#'   gender = c(
#'     "Male",
#'     "Female"
#'   )
#' )
#'
#' contingency <- data.frame(
#'   age_group = c(
#'     "18-64",
#'     "18-64",
#'     "18-64"
#'   ),
#'   gender = c(
#'     "Male",
#'     "Male",
#'     "Male"
#'   ),
#'   education = c(
#'     "Degree",
#'     "Diploma",
#'     "School"
#'   ),
#'   count = c(
#'     50,
#'     30,
#'     20
#'   )
#' )
#'
#' expanded <- make_contingency_table(
#'   contingency = contingency,
#'   synth_pop = population,
#'   group_by = c(
#'     "age_group",
#'     "gender"
#'   ),
#'   target_attribute = "education",
#'   strategy = "borrow"
#' )
#'
#' }
#'
#' @seealso
#' \code{\link{ReplicaAdder}},
#' \code{\link{enhance}},
#' \code{\link{calculate_fractions}},
#' \code{\link{transform_to_contingency}}
#'
#' @export
make_contingency_table <- function(
    contingency,
    synth_pop,
    group_by,
    target_attribute,
    strategy = "borrow"
) {
  
  contingency <- as.data.frame(contingency)
  
  synth_pop <- as.data.frame(synth_pop)
  
  target_values <- unique(
    contingency[[target_attribute]]
  )
  
  additions <- list()
  
  #
  # Groups present in contingency
  #
  
  contingency_groups <- unique(
    contingency[
      ,
      group_by,
      drop = FALSE
    ]
  )
  
  #
  # Groups present in synthetic population
  #
  
  population_groups <- unique(
    synth_pop[
      ,
      group_by,
      drop = FALSE
    ]
  )
  
  #
  # Determine missing groups
  #
  
  missing_groups <- population_groups[
    
    !apply(
      
      population_groups,
      
      1,
      
      function(row) {
        
        any(
          apply(
            contingency_groups,
            1,
            function(x)
              all(x == row)
          )
        )
        
      }
      
    ),
    
    ,
    drop = FALSE
    
  ]
  
  #
  # Strategy: error
  #
  
  if (
    strategy == "error" &&
    nrow(missing_groups) > 0
  ) {
    
    stop(
      
      paste(
        
        "Missing contingency groups:",
        
        paste(
          
          apply(
            missing_groups,
            1,
            function(x)
              paste(
                x,
                collapse = ", "
              )
          ),
          
          collapse = "; "
          
        )
        
      )
      
    )
    
  }
  
  #
  # Nothing to do
  #
  
  if (nrow(missing_groups) == 0) {
    
    return(
      data.table::as.data.table(
        contingency
      )
    )
    
  }
  
  #
  # Build missing groups
  #
  
  for (i in seq_len(nrow(missing_groups))) {
    
    group_row <- missing_groups[
      i,
      ,
      drop = FALSE
    ]
    
    #
    # Strategy: overall
    #
    
    if (strategy == "overall") {
      
      overall_distribution <- aggregate(
        
        count ~ .,
        
        contingency[
          ,
          c(
            target_attribute,
            "count"
          ),
          drop = FALSE
        ],
        
        sum
        
      )
      
      new_rows <- group_row[
        rep(
          1,
          nrow(overall_distribution)
        ),
        ,
        drop = FALSE
      ]
      
      new_rows[[target_attribute]] <-  overall_distribution[[target_attribute]]
      
      new_rows$count <-
        overall_distribution$count
      
    }
    
    #
    # Strategy: borrow
    #
    
    else if (strategy == "borrow") {
      
      borrowed <- contingency
      
      #
      # Borrow from a less-specific group
      #
      
      if (length(group_by) > 1) {
        
        for (g in group_by[-length(group_by)]) {
          
          borrowed <- borrowed[
            borrowed[[g]] ==
              group_row[[g]],
            ,
            drop = FALSE
          ]
          
        }
        
      }
      
      #
      # If no suitable distribution exists,
      # fall back to overall distribution
      #
      
      if (nrow(borrowed) == 0) {
        
        borrowed <- aggregate(
          
          count ~ .,
          
          contingency[
            ,
            c(
              target_attribute,
              "count"
            ),
            drop = FALSE
          ],
          
          sum
          
        )
        
        new_rows <- group_row[
          rep(
            1,
            nrow(borrowed)
          ),
          ,
          drop = FALSE
        ]
        
        new_rows[[target_attribute]] <- borrowed[[target_attribute]]
        
        new_rows$count <-
          borrowed$count
        
      } else {
        
        new_rows <- borrowed
        
        for (g in group_by) {
          
          new_rows[[g]] <-
            group_row[[g]]
          
        }
        
      }
      
    }
    
    #
    # Ensure column order matches
    #
    
    new_rows <- new_rows[
      ,
      names(contingency),
      drop = FALSE
    ]
    
    additions[[length(additions) + 1]] <- new_rows
    
  }
  
  #
  # Append additions
  #
  
  additions_df <- do.call(
    rbind,
    additions
  )
  
  contingency <- rbind(
    contingency,
    additions_df
  )
  
  rownames(contingency) <- NULL
  
  data.table::as.data.table(
    contingency
  )
  
}

#' Exchange Household Positions Between Agents
#'
#' Swaps household-position classifications between two agents
#' in a synthetic population.
#'
#' This function supports fallback partner-matching logic in
#' replica when suitable candidates are unavailable within the
#' preferred household-position pool.
#'
#' @param object A \code{\link{ReplicaStructure}} object.
#'
#' @param agent_1 Identifier of the first agent.
#'
#' @param agent_2 Identifier of the second agent.
#'
#' @return An updated \code{\link{ReplicaStructure}} object.
#'
#' @details
#' The function:
#'
#' \enumerate{
#'   \item Retrieves both agents.
#'   \item Exchanges their household-position values.
#'   \item Updates the stored synthetic population.
#' }
#'
#' Both agents must belong to the same neighbourhood.
#'
#' @examples
#' \dontrun{
#' hh <- switchHouseholdPositions(
#'   hh,
#'   "A001",
#'   "A002"
#' )
#' }
#'
#' @seealso
#' \code{\link{findOppositeGenderReplacementForCandidate}}
#'
#' @keywords internal
switchHouseholdPositions <- function(
    object,
    agent_1,
    agent_2
) {
  
  dt <- data.table::copy(
    object@df_synth_pop
  )
  
  a1 <- dt[
    agent_id == agent_1,
  ]
  
  a2 <- dt[
    agent_id == agent_2,
  ]
  
  if (nrow(a1) == 0) {
    
    stop(
      paste(
        "Agent not found:",
        agent_1
      )
    )
    
  }
  
  if (nrow(a2) == 0) {
    
    stop(
      paste(
        "Agent not found:",
        agent_2
      )
    )
    
  }
  
  # Match Python behaviour:
  # both agents must belong to same neighbourhood
  
  if (
    a1$neighb_code !=
    a2$neighb_code
  ) {
    
    stop(
      "Agents belong to different neighbourhoods"
    )
    
  }
  
  pos1 <- a1[[object@household_position_column]]
  
  pos2 <- a2[[object@household_position_column]]
  
  dt[agent_id == agent_1, (object@household_position_column) := pos2]
  
  dt[
    agent_id == agent_2,
    (object@household_position_column) := pos1
  ]
  
  object@df_synth_pop <- dt
  
  object
  
}
