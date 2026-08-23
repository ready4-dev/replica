test_that(
  "getBaseAdultMask strict mode errors if adult position missing",
  {
    
    STRUCTURE <- ReplicaStructure(
      "ChildOnly"
    )
    
    STRUCTURE@population <- data.table(
      agent_id = c("C001", "C002")
    )
    
    expect_error(
      getBaseAdultMask(
        STRUCTURE,
        strict = TRUE
      )
    )
    
  }
)
test_that(
  "getBaseAdultMask non-strict mode returns FALSE mask",
  {
    
    STRUCTURE <- ReplicaStructure(
      "ChildOnly"
    )
    
    STRUCTURE@population <- data.table(
      agent_id = c(
        "C001",
        "C002",
        "C003"
      )
    )
    
    mask <- getBaseAdultMask(
      STRUCTURE,
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
