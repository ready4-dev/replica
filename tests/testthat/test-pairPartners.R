library(testthat)
library(data.table)

pop <- data.table(
  
  agent_id = c(
    "A001",
    "A002",
    "A003",
    "A004"
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
  
  household_position = c(
    "Parent",
    "Parent",
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

hh <- updateState(
  hh,
  pop,
  "household_position"
)

hh@couple_gender_distribution <- c(
  "Male|Female" = 1
)

hh@couple_age_distribution <- c(
  "-5-5" = 1
)

hh@sampled_agents <- character()
test_that(
  "pairPartners creates expected number of couples",
  {
    
    couples <- pairPartners(
      hh,
      rep(
        TRUE,
        nrow(pop)
      )
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
    
    couples <- pairPartners(
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
    
    expect_s4_class(
      updated_hh,
      "HouseholdType"
    )
    
  }
)
test_that(
  "all adults assigned",
  {
    
    couples <- pairPartners(
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
    
    expect_true(
      
      setequal(
        
        updated_hh@sampled_agents,
        
        pop$agent_id
        
      )
      
    )
    
  }
)
test_that(
  "no duplicate assignments",
  {
    
    couples <- pairPartners(
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
    
    couples <- pairPartners(
      hh,
      rep(
        TRUE,
        nrow(pop)
      )
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
    
    couples <- pairPartners(
      hh,
      rep(
        TRUE,
        nrow(pop)
      )
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
    
    couples <- pairPartners(
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
    
    remaining <- getRemainingAgentsInPosition(
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
    
    couples <- pairPartners(
      hh,
      rep(
        TRUE,
        nrow(pop)
      )
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
    
    couples <- pairPartners(
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
    
    expect_true(
      
      setequal(
        
        updated_hh@sampled_agents,
        
        pop$agent_id
        
      )
      
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
    
  }
)