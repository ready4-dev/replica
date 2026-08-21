test_that(
  "agentToHousehold assigns household IDs",
  {
    
    hh <- ReplicaStructure(
      "CoupleOnly"
    )
    
    hh <- renew(
      hh,
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
    
    hh <- updateState(
      hh,
      pop,
      "household_position"
    )
    
    adult_position <-
      replica:::getPositionForName(
        hh,
        "adult"
      )
    
    hh <- create_household_with_id(
      hh,
      adult_position,
      1,
      c(
        "A001",
        "A002"
      )
    )
    
    hh <- create_household_with_id(
      hh,
      adult_position,
      2,
      c(
        "A003",
        "A004"
      )
    )
    
    hh <- agentToHousehold(
      hh
    )
    
    expect_false(
      
      any(
        is.na(
          hh@df_synth_pop$
            household_id
        )
      )
      
    )
    
    expect_equal(
      
      length(
        unique(
          hh@df_synth_pop$
            household_id
        )
      ),
      
      2
      
    )
    
  }
)
