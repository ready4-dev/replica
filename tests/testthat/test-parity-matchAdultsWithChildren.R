library(testthat)
library(data.table)

test_that(
  "matchAdultsWithChildren matches Python",
  {
    
    #
    # Load Python reference outputs
    #
    
    py_households <- read.csv(
      "Export/GenSynthPopR/parity/reference_data/match_adults_with_children_households.csv",
      stringsAsFactors = FALSE
    )
    
    py_agents <- read.csv(
      "Export/GenSynthPopR/parity/reference_data/match_adults_with_children_agents.csv",
      stringsAsFactors = FALSE
    )
    
    #
    # Recreate test population
    #
    
    pop <- data.table(
      
      agent_id = c(
        "A001","A002",
        "A003","A004",
        "C001","C002",
        "C003","C004"
      ),
      
      age = c(
        40,38,
        52,50,
        12,10,
        17,15
      ),
      
      gender = c(
        "Male","Female",
        "Male","Female",
        "Male","Female",
        "Male","Female"
      ),
      
      household_position = c(
        "Parent","Parent",
        "Parent","Parent",
        "Child","Child",
        "Child","Child"
      )
      
    )
    
    hh <- HouseholdType(
      "Family"
    )
    
    hh <- addMembers(
      hh,
      household_position = "Parent",
      position_identifier = "adult",
      amount = 2,
      backup_position_identifiers = character()
    )
    
    hh <- addMembers(
      hh,
      household_position = "Child",
      position_identifier = "child",
      amount = 2,
      backup_position_identifiers = character()
    )
    
    hh <- updateState(
      hh,
      pop,
      "household_position"
    )
    
    hh@parent_child_age_distribution <- c(
      "20-30" = 1
    )
    
    parents <- list(
      
      list(
        c("A001","40","Male"),
        c("A002","38","Female")
      ),
      
      list(
        c("A003","52","Male"),
        c("A004","50","Female")
      )
      
    )
    
    children <- list(
      
      c(
        "C001",
        "C002"
      ),
      
      c(
        "C003",
        "C004"
      )
      
    )
    
    #
    # Run R implementation
    #
    
    result <- matchAdultsWithChildren(
      hh,
      parents,
      children,
      id_offset = 1
    )
    
    r_households <- result$object@households
    expect_equal(
      length(r_households),
      nrow(py_households)
    )
    expect_identical(
      unname(
        sort(
          extract_household_sizes(
            r_households
          )
        )
      ),
      unname(
        sort(
          py_households$household_size
        )
      )
    )
    all_agents <- getAllAgents(
      result$object
    )
    
    expect_equal(
      length(all_agents),
      nrow(py_agents)
    )
    expect_equal(
      
      sort(
        all_agents
      ),
      
      sort(
        py_agents$
          agent_id
      )
      
    )
    expect_equal(
      
      length(all_agents),
      
      length(
        unique(
          all_agents
        )
      )
      
    )
    for (household in r_households) {
      
      n_parents <- sum(
        grepl(
          "^A",
          household$all
        )
      )
      
      n_children <- sum(
        grepl(
          "^C",
          household$all
        )
      )
      
      expect_equal(
        n_parents,
        2
      )
      
      expect_equal(
        n_children,
        2
      )
      
    }
    r_members <- sapply(
      
      result$object@households,
      
      function(hh) {
        
        paste(
          sort(hh$all),
          collapse = "|"
        )
        
      }
      
    )
    
    expect_equal(
      unname(
        sort(r_members)
      ),
      unname(
        sort(py_households$members)
      )
    )
  }
)