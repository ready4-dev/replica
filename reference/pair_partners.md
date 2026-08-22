# Create Couples from Eligible Adults

Forms couples from eligible adults according to household structure
definitions, gender distributions and age-gap distributions.

## Usage

``` r
pair_partners(object, group_mask)
```

## Arguments

- object:

  A `ReplicaStructure` object.

- group_mask:

  Logical vector identifying agents eligible for couple formation.

## Value

A list of couples.

Each couple is represented as:


    list(
      c(agent_id, age, gender),
      c(agent_id, age, gender)
    )

The updated `ReplicaStructure` object is attached as:


    attr(result, "object")

## Details

This function is one of the core household-generation algorithms in
replica and is typically called indirectly via `createFromMembers`.

Couples are created by:

1.  Determining the required number of couples.

2.  Allocating couples according to the specified gender-distribution
    constraints.

3.  Allocating partner age gaps according to the specified age-gap
    distribution.

4.  Selecting a primary partner.

5.  Selecting the best available secondary partner.

6.  Recording assigned agents in `assigned_agents`.

Couple composition is controlled by:

- `couple_gender_distribution`

- `couple_age_distribution`

Age-gap specifications are interpreted using
[`transform_to_age_gap`](https://ready4-dev.github.io/replica/reference/transform_to_age_gap.md).

Candidate partners are selected using:

- [`findPrimaryPartner`](https://ready4-dev.github.io/replica/reference/findPrimaryPartner.md)

- [`findSecondaryPartner`](https://ready4-dev.github.io/replica/reference/findSecondaryPartner.md)

- [`findCoupleCandidates`](https://ready4-dev.github.io/replica/reference/findCoupleCandidates.md)

Agents assigned to a couple are added to the `assigned_agents` slot to
prevent subsequent reassignment.

## See also

[`findPrimaryPartner`](https://ready4-dev.github.io/replica/reference/findPrimaryPartner.md),
[`findSecondaryPartner`](https://ready4-dev.github.io/replica/reference/findSecondaryPartner.md),
[`findCoupleCandidates`](https://ready4-dev.github.io/replica/reference/findCoupleCandidates.md),
[`transform_to_age_gap`](https://ready4-dev.github.io/replica/reference/transform_to_age_gap.md),
[`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)

## Examples

``` r
if (FALSE) { # \dontrun{

hh <- ReplicaStructure(
  "CoupleHousehold"
)

hh <- renew(
  hh,
  what = "positions",
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

couples <- pair_partners(
  hh,
  rep(TRUE, nrow(pop))
)

} # }
```
