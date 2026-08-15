# Find a Replacement Candidate of the Opposite Gender

Identifies an available candidate of the opposite gender that most
closely resembles a supplied candidate.

## Usage

``` r
findOppositeGenderReplacementForCandidate(
  object,
  wrong_candidate,
  mask,
  position
)
```

## Arguments

- object:

  A
  [`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
  object.

- wrong_candidate:

  Candidate requiring replacement.

- mask:

  Logical eligibility mask.

- position:

  Household-position category to search.

## Value

A single-row data frame or data.table containing the selected
replacement candidate.

Returns `NULL` if no suitable replacement exists.

## Details

This function supports fallback partner-matching behaviour within
replica when the preferred gender composition cannot be achieved
directly from the primary candidate pool.

Candidate selection is restricted to agents who:

- Occupy the specified household-position category.

- Have the opposite gender.

- Have not already been assigned.

Candidates are ranked according to a simple similarity score based on
matching demographic and household characteristics.

## See also

[`switchHouseholdPositions`](https://ready4-dev.github.io/replica/reference/switchHouseholdPositions.md),
[`findSecondaryPartner`](https://ready4-dev.github.io/replica/reference/findSecondaryPartner.md)

## Examples

``` r
if (FALSE) { # \dontrun{
replacement <-
  findOppositeGenderReplacementForCandidate(
    hh,
    wrong_candidate,
    mask,
    "SingleAdult"
  )
} # }
```
