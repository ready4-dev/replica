# Find and Rank Couple Candidates

Identifies and ranks potential secondary partners for a selected primary
partner.

## Usage

``` r
findCoupleCandidates(
  object,
  mask,
  position_value,
  primary_partner,
  gap_start,
  gap_end
)
```

## Arguments

- object:

  A `HouseholdType` object.

- mask:

  Logical vector identifying agents eligible for partner selection.

- position_value:

  Character vector containing eligible household-position values.

- primary_partner:

  Single-row data frame or data.table representing the already-selected
  primary partner.

- gap_start:

  Lower bound of the preferred age gap.

- gap_end:

  Upper bound of the preferred age gap.

## Value

A data frame or data.table containing candidate partners ranked by
suitability.

## Details

Candidates are restricted to eligible household-position categories and
are scored according to the age-gap requirements currently being
considered.

This function is used internally by
[`findSecondaryPartner`](https://ready4-dev.github.io/replica/reference/findSecondaryPartner.md)
and
[`pairPartners`](https://ready4-dev.github.io/replica/reference/pairPartners.md).

The function:

1.  Restricts candidates to the specified household positions.

2.  Removes agents already listed in `sampled_agents`.

3.  Removes the primary partner from consideration.

4.  Converts the supplied age gap into an acceptable age range using
    [`calculate_age_range_from_gap`](https://ready4-dev.github.io/replica/reference/calculate_age_range_from_gap.md).

5.  Computes a suitability score for every candidate using
    [`score_suitability_by_age_disparity`](https://ready4-dev.github.io/replica/reference/score_suitability_by_age_disparity.md).

6.  Returns candidates sorted from best to worst match.

Lower suitability scores indicate better matches.

Candidates with a suitability score of zero fall within the preferred
age-gap range.

## See also

[`findPrimaryPartner`](https://ready4-dev.github.io/replica/reference/findPrimaryPartner.md),
[`findSecondaryPartner`](https://ready4-dev.github.io/replica/reference/findSecondaryPartner.md),
[`pairPartners`](https://ready4-dev.github.io/replica/reference/pairPartners.md),
[`calculate_age_range_from_gap`](https://ready4-dev.github.io/replica/reference/calculate_age_range_from_gap.md),
[`score_suitability_by_age_disparity`](https://ready4-dev.github.io/replica/reference/score_suitability_by_age_disparity.md)

## Examples

``` r
if (FALSE) { # \dontrun{

candidates <- findCoupleCandidates(
  object = hh,
  mask = rep(
    TRUE,
    nrow(pop)
  ),
  position_value = "Parent",
  primary_partner = primary_partner,
  gap_start = -5,
  gap_end = 5
)

candidates[
  ,
  c(
    "agent_id",
    "age",
    "suitability"
  )
]

} # }
```
