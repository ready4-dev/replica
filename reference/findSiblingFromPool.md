# Find the Most Suitable Sibling Candidate

Selects the most suitable sibling from a candidate pool based on age
similarity to one or more already-selected siblings.

## Usage

``` r
findSiblingFromPool(pool, mask, sibling_ages)
```

## Arguments

- pool:

  Data frame or data.table containing candidate children.

- mask:

  Logical vector identifying which children in the pool remain available
  for selection.

- sibling_ages:

  Numeric vector containing the ages of children already selected for
  the sibling group.

## Value

A single-row data frame or data.table representing the selected sibling
candidate.

## Details

The suitability of a candidate is evaluated using
[`score_sibling_age_suitability`](https://ready4-dev.github.io/replica/reference/score_sibling_age_suitability.md).

Candidates with ages closest to the existing sibling ages receive the
highest priority.

This function is used internally by
[`groupChildren`](https://ready4-dev.github.io/replica/reference/groupChildren.md)
during sibling-group creation.

The function:

1.  Restricts the candidate pool using `mask`.

2.  Computes a suitability score for each remaining candidate.

3.  Sorts candidates by suitability.

4.  Returns the highest-ranked candidate.

Lower suitability scores indicate better sibling matches.

## See also

[`groupChildren`](https://ready4-dev.github.io/replica/reference/groupChildren.md),
[`score_sibling_age_suitability`](https://ready4-dev.github.io/replica/reference/score_sibling_age_suitability.md)

## Examples

``` r
pool <- data.frame(
  age = c(
    4,
    7,
    10,
    15
  )
)

findSiblingFromPool(
  pool,
  rep(TRUE, 4),
  c(8, 9)
)
#> Error in findSiblingFromPool(pool, rep(TRUE, 4), c(8, 9)): could not find function "findSiblingFromPool"
```
