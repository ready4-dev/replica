# Create a ReplicaStructure Object

Creates a new `ReplicaStructure` used during synthetic household
generation.

## Usage

``` r
ReplicaStructure(
  household_type,
  couple_gender_distribution = numeric(),
  couple_age_distribution = numeric(),
  parent_child_age_distribution = numeric()
)
```

## Arguments

- household_type:

  Character string identifying the household type.

  Examples include:

  - `"CoupleHousehold"`

  - `"Family"`

  - `"SingleAdultHousehold"`

  - `"SingleParent"`

- couple_gender_distribution:

  Named numeric vector controlling the gender composition of generated
  couples.

  For example:


      c(
        "Male|Female" = 1
      )

  generates only male-female couples.

- couple_age_distribution:

  Named numeric vector controlling partner age-gap distributions.

  For example:


      c(
        "-5-5" = 1
      )

  indicates that partners should typically be within five years of one
  another.

- parent_child_age_distribution:

  Named numeric vector controlling parent-child age-gap distributions.

  For example:


      c(
        "20-30" = 1
      )

  indicates that parents should generally be between twenty and thirty
  years older than their children.

## Value

A new `ReplicaStructure` object.

## Details

A `ReplicaStructure` defines:

- The type of household to be generated.

- The positions required within the household (for example adults and
  children).

- Couple gender distributions.

- Couple age-gap distributions.

- Parent-child age-gap distributions.

Household structures are subsequently configured using
[`renew`](https://ready4-dev.github.io/replica/reference/renew.md).

After construction, household-position requirements should be specified
using
[`renew`](https://ready4-dev.github.io/replica/reference/renew.md).

Example:


    STRUCTURE <- ReplicaStructure(
      "Family"
    )

    STRUCTURE <- renew(
      what = "positions",
      STRUCTURE,
      household_position = "Parent",
      position_identifier = "adult",
      amount = 2,
      backup_position_identifiers = character()
    )

    STRUCTURE <- renew(
      STRUCTURE,
      what = "positions",
      household_position = "Child",
      position_identifier = "child",
      amount = 2,
      backup_position_identifiers = character()
    )

The resulting object can then be supplied to a
[`ReplicaGrouper`](https://ready4-dev.github.io/replica/reference/ReplicaGrouper.md)
for household generation.

## See also

[`ReplicaStructure-class`](https://ready4-dev.github.io/replica/reference/ReplicaStructure-class.md),
[`ReplicaGrouper`](https://ready4-dev.github.io/replica/reference/ReplicaGrouper.md),
[`renew`](https://ready4-dev.github.io/replica/reference/renew.md)

## Examples

``` r
if (FALSE) { # \dontrun{

STRUCTURE <- ReplicaStructure(
  household_type = "Family",
  couple_gender_distribution = c(
    "Male|Female" = 1
  ),
  couple_age_distribution = c(
    "-5-5" = 1
  ),
  parent_child_age_distribution = c(
    "20-30" = 1
  )
)

} # }
```
