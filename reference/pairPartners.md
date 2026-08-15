# Create Couples from Eligible Adults

Forms couples from eligible adults according to household structure
definitions, gender distributions and age-gap distributions.

## Usage

``` r
pairPartners(object, group_mask)
```

## Arguments

- object:

  A `HouseholdType` object.

- group_mask:

  Logical vector identifying agents eligible for couple formation.

## Value

A list of couples.

Each couple is represented as:


    list(
      c(agent_id, age, gender),
      c(agent_id, age, gender)
    )

The updated `HouseholdType` object is attached as:


    attr(result, "object")

## Details

This function is one of the core household-generation algorithms in
GenSynthPopR and is typically called indirectly via `createFromMembers`.

Couples are created by:

1.  Determining the required number of couples.

2.  Allocating couples according to the specified gender-distribution
    constraints.

3.  Allocating partner age gaps according to the specified age-gap
    distribution.

4.  Selecting a primary partner.

5.  Selecting the best available secondary partner.

6.  Recording assigned agents in `sampled_agents`.

Couple composition is controlled by:

- `couple_gender_distribution`

- `couple_age_distribution`

Age-gap specifications are interpreted using `parseAgeGap`.

Candidate partners are selected using:

- [`findPrimaryPartner`](https://ready4-dev.github.io/replica/reference/findPrimaryPartner.md)

- [`findSecondaryPartner`](https://ready4-dev.github.io/replica/reference/findSecondaryPartner.md)

- [`findCoupleCandidates`](https://ready4-dev.github.io/replica/reference/findCoupleCandidates.md)

Agents assigned to a couple are added to the `sampled_agents` slot to
prevent subsequent reassignment.

## See also

[`findPrimaryPartner`](https://ready4-dev.github.io/replica/reference/findPrimaryPartner.md),
[`findSecondaryPartner`](https://ready4-dev.github.io/replica/reference/findSecondaryPartner.md),
[`findCoupleCandidates`](https://ready4-dev.github.io/replica/reference/findCoupleCandidates.md),
`parseAgeGap`, `createSingles`, `createFromMembers`,
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)

## Examples

``` r
if (FALSE) { # \dontrun{

hh <- HouseholdType(
  "CoupleHousehold"
)

hh <- addMembers(
  hh,
  household_position = "Parent",
  position_identifier = "adult",
  amount = 2,
  backup_position_identifiers = character()
)

hh@couple_gender_distribution <- c(
  "Male|Female" = 1
)

hh@couple_age_distribution <- c(
  "-5-5" = 1
)

couples <- pairPartners(
  hh,
  rep(TRUE, nrow(pop))
)

} # }
```
