# Score Candidate Suitability by Age Disparity

Calculates a suitability score based on how closely a candidate's age
matches a desired age range.

## Usage

``` r
score_suitability_by_age_disparity(
  partner_age,
  age_start,
  age_end,
  strict_lower_bound = NULL
)
```

## Arguments

- partner_age:

  Numeric age of the candidate being evaluated.

- age_start:

  Numeric lower bound of the preferred age range.

- age_end:

  Numeric upper bound of the preferred age range.

- strict_lower_bound:

  Optional numeric minimum acceptable age.

  Candidates below this age receive a large penalty to prevent
  biologically implausible matches.

## Value

A numeric suitability score.

## Details

Lower scores indicate better matches.

A score of zero indicates that the candidate age falls within the
desired age interval.

This function is used throughout the household-generation workflow when
matching:

- Partners.

- Parents and children.

Suitability is calculated as follows:

- Within Range:

  Returns `0`.

- Below Range:

  Returns the number of years below the lower bound.

- Above Range:

  Returns the number of years above the upper bound.

If `strict_lower_bound` is supplied and the candidate falls below that
value, an additional penalty of `999` is added.

This penalty mechanism is used by the parent-child matching workflow to
discourage unrealistic parent-child age combinations.

## See also

[`calculate_age_range_from_gap`](https://ready4-dev.github.io/replica/reference/calculate_age_range_from_gap.md),
[`findCoupleCandidates`](https://ready4-dev.github.io/replica/reference/findCoupleCandidates.md),
[`findSecondaryPartner`](https://ready4-dev.github.io/replica/reference/findSecondaryPartner.md),
[`pair_partners`](https://ready4-dev.github.io/replica/reference/pair_partners.md),
[`matchAdultsWithChildren`](https://ready4-dev.github.io/replica/reference/matchAdultsWithChildren.md)

## Examples

``` r
# Candidate inside preferred range
if (FALSE) { # \dontrun{
score_suitability_by_age_disparity(
  partner_age = 30,
  age_start = 25,
  age_end = 35
)
} # }

# Candidate too young
if (FALSE) { # \dontrun{
score_suitability_by_age_disparity(
  partner_age = 20,
  age_start = 25,
  age_end = 35
)
} # }

# Candidate too old
if (FALSE) { # \dontrun{
score_suitability_by_age_disparity(
  partner_age = 40,
  age_start = 25,
  age_end = 35
)
} # }

# Candidate violates strict lower bound
if (FALSE) { # \dontrun{
score_suitability_by_age_disparity(
  partner_age = 12,
  age_start = 20,
  age_end = 25,
  strict_lower_bound = 14
)
} # }
```
