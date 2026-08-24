test_that(
  "renew assigns household IDs",
  {
    
    STRUCTURE <- ReplicaStructure(
      "CoupleOnly"
    )
    
    STRUCTURE <- renew(
      STRUCTURE,
      what = "positions",
      household_position = "Parent",
      position_identifier = "adult",
      amount = 2,
      backup_position_identifiers =
        character()
    )
    
    pop <- data.table(
      
      agent_id = c(
        "A001",
        "A002",
        "A003",
        "A004"
      ),
      
      neighb_code = c(
        "N1",
        "N1",
        "N2",
        "N2"
      ),
      
      household_id = NA_character_
      
    )
    
    STRUCTURE <- renew(
      STRUCTURE,
      what = "state",
      population = pop,
      position_column = "household_position"
    )
    
    adult_position <-
      replica:::getPositionForName(
        STRUCTURE,
        "adult"
      )
    
    STRUCTURE <- create_household_with_id(
      STRUCTURE,
      adult_position,
      1,
      c(
        "A001",
        "A002"
      )
    )
    
    STRUCTURE <- create_household_with_id(
      STRUCTURE,
      adult_position,
      2,
      c(
        "A003",
        "A004"
      )
    )
    
    STRUCTURE <- renew(
      STRUCTURE,
      what = "households"
    )
    
    expect_false(
      
      any(
        is.na(
          procure(STRUCTURE, "population")$
            household_id
        )
      )
      
    )
    
    expect_equal(
      
      length(
        unique(
          procure(STRUCTURE, "population")$
            household_id
        )
      ),
      
      2
      
    )
    
  }
)
