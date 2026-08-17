library(testthat)
library(data.table)

test_that(
  "pair_partners creates expected number of couples",
  {
    
    hh <- make_couple_household()
    
    couples <- pair_partners(
      hh,
      rep(TRUE, 4)
    )
    
    expect_equal(
      length(couples),
      2
    )
    
  }
)

test_that(
  "updated HouseholdType attached",
  {
    
    hh <- make_couple_household()
    
    couples <- pair_partners(
      hh,
      rep(TRUE, 4)
    )
    
    expect_s4_class(
      attr(
        couples,
        "object"
      ),
      "HouseholdType"
    )
    
  }
)

test_that(
  "all adults assigned",
  {
    
    hh <- make_couple_household()
    
    couples <- pair_partners(
      hh,
      rep(TRUE, 4)
    )
    
    updated_hh <- attr(
      couples,
      "object"
    )
    
    expect_true(
      setequal(
        updated_hh@sampled_agents,
        hh@df_synth_pop$agent_id
      )
    )
    
  }
)

test_that(
  "no duplicate assignments",
  {
    
    hh <- make_couple_household()
    
    couples <- pair_partners(
      hh,
      rep(TRUE, 4)
    )
    
    updated_hh <- attr(
      couples,
      "object"
    )
    
    expect_equal(
      
      length(
        updated_hh@sampled_agents
      ),
      
      length(
        unique(
          updated_hh@sampled_agents
        )
      )
      
    )
    
  }
)


test_that(
  "gender distribution respected",
  {
    
    hh <- make_couple_household()
    
    couples <- pair_partners(
      hh,
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
    
    hh <- make_couple_household()
    
    couples <- pair_partners(
      hh,
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
    
    hh <- make_couple_household()
    
    couples <- pair_partners(
      hh,
      rep(TRUE, 4)
    )
    
    updated_hh <- attr(
      couples,
      "object"
    )
    
    remaining <-
      getRemainingAgentsInPosition(
        updated_hh,
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
    
    hh <- make_couple_household()
    
    couples <- pair_partners(
      hh,
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
    
    hh <- make_couple_household()
    
    couples <- pair_partners(
      hh,
      rep(TRUE, 4)
    )
    
    updated_hh <- attr(
      couples,
      "object"
    )
    
    expect_equal(
      length(
        updated_hh@sampled_agents
      ),
      4
    )
    
    expect_equal(
      length(
        unique(
          updated_hh@sampled_agents
        )
      ),
      4
    )
    
    expect_true(
      setequal(
        updated_hh@sampled_agents,
        hh@df_synth_pop$agent_id
      )
    )
    
  }
)

test_that(
  "gender ordering does not affect matching",
  {
    
    pop <- data.table(
      
      agent_id = c(
        "A001",
        "A002",
        "A003",
        "A004"
      ),
      
      neighb_code = rep(
        "N1",
        4
      ),
      
      age = c(
        40,
        35,
        50,
        45
      ),
      
      gender = c(
        "Male",
        "Female",
        "Male",
        "Female"
      ),
      
      household_position = "Parent"
      
    )
    
    hh <- make_couple_household(
      gender_distribution =
        c(
          "Female|Male" = 1
        )
    )
    
    hg <- HouseholdGrouper(
      df_synth_pop = pop,
      group_by = "neighb_code"
    )
    
    hg <- addHouseholdType(
      hg,
      hh
    )
    
    result <- run(hg)
    
    expect_false(
      any(
        is.na(
          result$synthetic_population$household_id
        )
      )
    )
    
    expect_true(
      checkIntegrity(
        result$object@household_types[[1]]
      )
    )
    
  }
)
test_that(
  "failed partner match does not consume primary partner",
  {
    
    pop <- data.table(
      
      agent_id = c(
        "M001",
        "M002"
      ),
      
      gender = c(
        "Male",
        "Male"
      ),
      
      age = c(
        30,
        80
      ),
      
      household_position = c(
        "Parent",
        "Parent"
      )
      
    )
    
    hh <- HouseholdType(
      "CoupleHousehold"
    )
    
    hh <- addMembers(
      hh,
      household_position = "Parent",
      position_identifier = "adult",
      amount = 2,
      backup_position_identifiers = character()
    )
    
    hh@df_synth_pop <- pop
    
    hh@household_position_column <-
      "household_position"
    
    hh@couple_gender_distribution <- c(
      "Male|Male" = 1
    )
    
    hh@couple_age_distribution <- c(
      "-5-5" = 1
    )
    
    couples <- pair_partners(
      hh,
      rep(
        TRUE,
        nrow(pop)
      )
    )
    
    updated_hh <- attr(
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
        updated_hh@sampled_agents
      ),
      0
    )
    
    expect_equal(
      updated_hh@sampled_agents,
      character()
    )
    
  }
)
