# Find a Secondary Household Partner

Selects the most suitable partner for a previously selected primary
partner.

## Usage

``` r
findSecondaryPartner(
  object,
  mask,
  primary_partner,
  primary_position_value,
  backup_position_values,
  gap_start,
  gap_end,
  gender
)
```

## Arguments

- object:

  A `ReplicaStructure` object.

- mask:

  Logical vector identifying agents eligible for partner selection.

- primary_partner:

  Single-row data frame or data.table representing the already-selected
  primary partner.

- primary_position_value:

  Character vector identifying household-position values eligible for
  secondary-partner selection.

- backup_position_values:

  Character vector containing alternative household-position categories
  that may be used when suitable candidates are unavailable in the
  primary pool.

- gap_start:

  Lower age-gap bound.

- gap_end:

  Upper age-gap bound.

- gender:

  Character string specifying the required gender of the secondary
  partner.

## Value

A single-row data frame or data.table representing the selected partner.

Returns `NULL` if no suitable candidate can be found.

## Details

Candidate partners are ranked according to age-gap suitability and
filtered according to household-position and gender requirements.

This function is used internally by `pair_partners` during couple
formation.

The function:

1.  Generates a ranked candidate list using
    [`findCoupleCandidates`](https://ready4-dev.github.io/replica/reference/findCoupleCandidates.md).

2.  Restricts candidates to the required gender.

3.  Selects the highest-ranked compatible candidate.

4.  Returns `NULL` if no compatible candidate is available.

Candidate suitability is determined using:

- Age-gap constraints.

- Household-position constraints.

- Availability of agents not already assigned.

More advanced workflows may use backup-position replacement logic via:

- [`findOppositeGenderReplacementForCandidate`](https://ready4-dev.github.io/replica/reference/findOppositeGenderReplacementForCandidate.md)

- [`switchHouseholdPositions`](https://ready4-dev.github.io/replica/reference/switchHouseholdPositions.md)

## See also

[`findPrimaryPartner`](https://ready4-dev.github.io/replica/reference/findPrimaryPartner.md),
[`findCoupleCandidates`](https://ready4-dev.github.io/replica/reference/findCoupleCandidates.md),
[`findOppositeGenderReplacementForCandidate`](https://ready4-dev.github.io/replica/reference/findOppositeGenderReplacementForCandidate.md)

## Examples

``` r
if (FALSE) { # \dontrun{

secondary_partner <- findSecondaryPartner(
  object = hh,
  mask = rep(
    TRUE,
    nrow(pop)
  ),
  primary_partner = primary_partner,
  primary_position_value = "Parent",
  backup_position_values = character(),
  gap_start = -5,
  gap_end = 5,
  gender = "Female"
)

} # }
```
