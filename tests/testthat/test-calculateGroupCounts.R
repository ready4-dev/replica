library(testthat)

test_that(
  "group counts sum correctly",
  {
    
    fractions <- c(
      A = 0.33,
      B = 0.33,
      C = 0.34
    )
    
    counts <- calculateGroupCounts(
      fractions,
      100
    )
    
    expect_equal(
      sum(counts),
      100
    )
    
    expect_equal(
      length(counts),
      3
    )
    
    expect_true(
      all(counts >= 0)
    )
    
    expect_equal(
      unname(
        counts["A"]
      ),
      33
    )
    
    expect_equal(
      unname(
        counts["B"]
      ),
      33
    )
    
    expect_equal(
      unname(
        counts["C"]
      ),
      34
    )
    
  }
)

test_that(
  "rounding correction works",
  {
    
    fractions <- c(
      A = 0.45,
      B = 0.25,
      C = 0.30
    )
    
    counts <- calculateGroupCounts(
      fractions,
      10
    )
    
    expect_equal(
      sum(counts),
      10
    )
    
    expect_equal(
      unname(
        counts["A"]
      ),
      5
    )
    
    expect_equal(
      unname(
        counts["B"]
      ),
      2
    )
    
    expect_equal(
      unname(
        counts["C"]
      ),
      3
    )
    
  }
)

test_that(
  "single category receives all agents",
  {
    
    fractions <- c(
      A = 1
    )
    
    counts <- calculateGroupCounts(
      fractions,
      25
    )
    
    expect_equal(
      unname(
        counts["A"]
      ),
      25
    )
    
    expect_equal(
      sum(counts),
      25
    )
    
  }
)

test_that(
  "result contains no NA values",
  {
    
    fractions <- c(
      A = 0.45,
      B = 0.25,
      C = 0.30
    )
    
    counts <- calculateGroupCounts(
      fractions,
      10
    )
    
    expect_false(
      any(
        is.na(counts)
      )
    )
    
    expect_false(
      any(
        is.nan(counts)
      )
    )
    
  }
)
test_that(
  "NA fractions rejected",
  {
    
    expect_error(
      
      calculateGroupCounts(
        c(
          A = NA,
          B = 0.5
        ),
        10
      )
      
    )
    
  }
)

test_that(
  "NaN fractions rejected",
  {
    
    expect_error(
      
      calculateGroupCounts(
        c(
          A = NaN,
          B = 0.5
        ),
        10
      )
      
    )
    
  }
)
test_that(
  "zero agents handled correctly",
  {
    
    counts <- calculateGroupCounts(
      c(
        A = 0.5,
        B = 0.5
      ),
      0
    )
    
    expect_equal(
      sum(counts),
      0
    )
    
  }
)