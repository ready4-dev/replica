library(testthat)
library(data.table)

test_that(
  "pair_partners creates expected number of couples",
  {
    pop <- make_household_population()
    STRUCTURE <- make_couple_household(pop)
    
    couples <- replica:::pair_partners(
      STRUCTURE,
      rep(TRUE, 4)
    )
    
    expect_equal(
      length(couples),
      2
    )
    
  }
)

test_that(
  "updated ReplicaStructure attached",
  {
    
    pop <- make_household_population()
    STRUCTURE <- make_couple_household(pop)
    
    couples <- replica:::pair_partners(
      STRUCTURE,
      rep(TRUE, 4)
    )
    
    expect_s4_class(
      attr(
        couples,
        "object"
      ),
      "ReplicaStructure"
    )
    
  }
)

test_that(
  "all adults assigned",
  {
    
    pop <- make_household_population()
    STRUCTURE <- make_couple_household(pop)
    
    couples <- replica:::pair_partners(
      STRUCTURE,
      rep(TRUE, 4)
    )
    
    updated_STRUCTURE <- attr(
      couples,
      "object"
    )
    
    expect_true(
      setequal(
        updated_STRUCTURE@assigned_agents,
        STRUCTURE@population$agent_id
      )
    )
    
  }
)

test_that(
  "no duplicate assignments",
  {
    
    pop <- make_household_population()
    STRUCTURE <- make_couple_household(pop)
    
    couples <- replica:::pair_partners(
      STRUCTURE,
      rep(TRUE, 4)
    )
    
    updated_STRUCTURE <- attr(
      couples,
      "object"
    )
    
    expect_equal(
      
      length(
        updated_STRUCTURE@assigned_agents
      ),
      
      length(
        unique(
          updated_STRUCTURE@assigned_agents
        )
      )
      
    )
    
  }
)


test_that(
  "gender distribution respected",
  {
    
    pop <- make_household_population()
    STRUCTURE <- make_couple_household(pop)
    
    couples <- replica:::pair_partners(
      STRUCTURE,
      rep(TRUE, 4)
    )
    
    gender_pairs <-
      extract_gender_pairs(
        couples
      )
    
    expect_true(
      all(
        gender_pairs ==
          "Male-Female"
      )
    )
    
  }
)

test_that(
  "age gap constraints respected",
  {
    
    pop <- make_household_population()
    STRUCTURE <- make_couple_household(pop)
    
    couples <- replica:::pair_partners(
      STRUCTURE,
      rep(TRUE, 4)
    )
    
    age_gaps <-
      extract_age_gaps(
        couples
      )
    
    expect_true(
      all(
        age_gaps >= -5 &
          age_gaps <= 5
      )
    )
    
  }
)

test_that(
  "no adults remain available",
  {
    
    pop <- make_household_population()
    STRUCTURE <- make_couple_household(pop)
    
    couples <- replica:::pair_partners(
      STRUCTURE,
      rep(TRUE, 4)
    )
    
    updated_STRUCTURE <- attr(
      couples,
      "object"
    )
    
    remaining <-
      getRemainingAgentsInPosition(
        updated_STRUCTURE,
        "Parent"
      )
    
    expect_equal(
      nrow(remaining),
      0
    )
    
  }
)

test_that(
  "each couple contains two adults",
  {
    
    pop <- make_household_population()
    STRUCTURE <- make_couple_household(pop)
    
    couples <- replica:::pair_partners(
      STRUCTURE,
      rep(TRUE, 4)
    )
    
    expect_true(
      all(
        sapply(
          couples,
          length
        ) == 2
      )
    )
    
  }
)

test_that(
  "all source agents appear exactly once",
  {
    
    pop <- make_household_population()
    STRUCTURE <- make_couple_household(pop)
    
    couples <- replica:::pair_partners(
      STRUCTURE,
      rep(TRUE, 4)
    )
    
    updated_STRUCTURE <- attr(
      couples,
      "object"
    )
    
    expect_equal(
      length(
        updated_STRUCTURE@assigned_agents
      ),
      4
    )
    
    expect_equal(
      length(
        unique(
          updated_STRUCTURE@assigned_agents
        )
      ),
      4
    )
    
    expect_true(
      setequal(
        updated_STRUCTURE@assigned_agents,
        STRUCTURE@population$agent_id
      )
    )
    
  }
)

test_that(
  "gender ordering does not affect matching",
  {
    
    pop <- make_household_population()

    STRUCTURE <- make_couple_household(
      pop,
      gender_distribution =
        c(
          "Female|Male" = 1
        )
    )
    
    GROUPER <- ReplicaGrouper(
      population = pop,
      group_by = "neighb_code"
    )
    
    GROUPER <- renew(
      GROUPER,
      STRUCTURE,
      what = "structure"
    )
    result <- manufacture(GROUPER)
    
    expect_false(
      any(
        is.na(
          result$synthetic_population$household_id
        )
      )
    )
    
    expect_true(
      ratify(result$x@structures[[1]], output = "logical")
    )
    
  }
)
test_that(
  "failed partner match does not consume primary partner",
  {
    
    pop <- data.table(
      
      agent_id = c(
        "F001",
        "F002"
      ),
      
      gender = c(
        "Female",
        "Female"
      ),
      
      age = c(
        30,
        35
      ),
      
      household_position = c(
        "Parent",
        "Parent"
      )
      
    )
    
    STRUCTURE <- ReplicaStructure(
      "CoupleHousehold"
    )
    
    STRUCTURE <- renew(
      STRUCTURE,
      what = "positions",
      household_position = "Parent",
      position_identifier = "adult",
      amount = 2,
      backup_position_identifiers = character()
    )
    
    STRUCTURE <- renew(
      STRUCTURE,
      what = "state",
      population = pop,
      position_column = "household_position"
    )
    
    STRUCTURE@couple_gender_distribution <- c(
      "Female|Male" = 1
    )
    
    STRUCTURE@couple_age_distribution <- c(
      "-5-5" = 1
    )
    
    couples <- replica:::pair_partners(
      STRUCTURE,
      rep(
        TRUE,
        nrow(pop)
      )
    )
    
    updated_STRUCTURE <- attr(
      couples,
      "object"
    )
    
    #
    # No compatible couple should have formed
    #
    
    expect_equal(
      length(couples),
      0
    )
    
    #
    # The failed attempt must not consume
    # either candidate
    #
    
    expect_equal(
      length(
        updated_STRUCTURE@assigned_agents
      ),
      0
    )
    
    expect_equal(
      updated_STRUCTURE@assigned_agents,
      character()
    )
    
  }
)
