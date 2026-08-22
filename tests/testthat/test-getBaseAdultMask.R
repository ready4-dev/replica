test_that(
  "getBaseAdultMask strict mode errors if adult position missing",
  {
    
    hh <- ReplicaStructure(
      "ChildOnly"
    )
    
    hh@population <- data.table(
      agent_id = c("C001", "C002")
    )
    
    expect_error(
      getBaseAdultMask(
        hh,
        strict = TRUE
      )
    )
    
  }
)
test_that(
  "getBaseAdultMask non-strict mode returns FALSE mask",
  {
    
    hh <- ReplicaStructure(
      "ChildOnly"
    )
    
    hh@population <- data.table(
      agent_id = c(
        "C001",
        "C002",
        "C003"
      )
    )
    
    mask <- getBaseAdultMask(
      hh,
      strict = FALSE
    )
    
    expect_equal(
      length(mask),
      3
    )
    
    expect_true(
      all(mask == FALSE)
    )
    
  }
)
