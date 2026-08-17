# Calculate Sibling Age Suitability

Computes a suitability score for a candidate sibling based on the ages
of one or more existing siblings.

## Usage

``` r
score_sibling_age_suitability(age, reference_ages)
```

## Arguments

- age:

  Numeric age of the candidate sibling.

- reference_ages:

  Numeric vector containing the ages of siblings already assigned to the
  sibling group.

## Value

A numeric suitability score.

## Details

Lower scores indicate a closer age match and therefore a more suitable
sibling candidate.

This function is used internally by findSiblingFromPool during
sibling-group construction.

If the candidate age exactly matches one of the reference ages, a score
of `10` is returned.

Otherwise, the score is the minimum absolute age difference between the
candidate and any reference age.

Lower scores correspond to stronger sibling similarity.

## See also

[`group_children`](https://ready4-dev.github.io/replica/reference/group_children.md)

## Examples

``` r
if (FALSE) { # \dontrun{
score_sibling_age_suitability(
  age = 10,
  reference_ages = c(
    8,
    12
  )
)

score_sibling_age_suitability(
  age = 15,
  reference_ages = c(
    8,
    12
  )
)
} # }
```
