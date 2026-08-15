# Add Household Members to a HouseholdType

Defines one component of a household structure used during synthetic
household generation.

## Usage

``` r
addMembers(
  object,
  household_position,
  position_identifier,
  amount,
  backup_position_identifiers
)

# S4 method for class 'HouseholdType'
addMembers(
  object,
  household_position,
  position_identifier,
  amount,
  backup_position_identifiers
)
```

## Arguments

- object:

  A
  [`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
  object.

- household_position:

  Character vector identifying household-position categories.

- position_identifier:

  Internal role identifier.

  Typical values include:

  - `"adult"`

  - `"child"`

- amount:

  Number of agents required for the role.

- backup_position_identifiers:

  Alternative household positions that may be used if the primary
  position pool becomes exhausted.

## Value

An updated
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
object.

## Details

Household members are registered by:

- Household-position category.

- Internal position identifier.

- Required number of agents.

- Optional backup positions.

## See also

[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md),
[`createFromMembers`](https://ready4-dev.github.io/replica/reference/createFromMembers.md)

## Examples

``` r
if (FALSE) { # \dontrun{

hh <- HouseholdType("Family")

hh <- addMembers(
  hh,
  household_position = "Parent",
  position_identifier = "adult",
  amount = 2,
  backup_position_identifiers = character()
)

} # }
```
