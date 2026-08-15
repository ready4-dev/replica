# Retrieve a Household Position Definition

Returns a household-position definition stored within a
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
object.

## Usage

``` r
getPositionForName(object, position)

# S4 method for class 'HouseholdType'
getPositionForName(object, position)
```

## Arguments

- object:

  A
  [`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
  object.

- position:

  Character string identifying the required household role.

  Typical values include:

  - `"adult"`

  - `"child"`

## Value

A list describing the requested household-position definition.

## Details

Household positions are created using
[`addMembers`](https://ready4-dev.github.io/replica/reference/addMembers.md)
and describe the composition of a household type.

Typical position identifiers include:

- `"adult"`

- `"child"`

The returned object contains:

- position_identifier:

  Internal role identifier.

- position:

  Household-position value(s) used in the synthetic population.

- amount:

  Number of agents required for the role.

- backup_position_identifiers:

  Alternative household-position categories that may be used if suitable
  agents cannot be found in the primary candidate pool.

Household-position definitions are stored internally and are referenced
extensively throughout the household-generation workflow.

This method is used by:

- [`pairPartners`](https://ready4-dev.github.io/replica/reference/pairPartners.md)

- [`groupChildren`](https://ready4-dev.github.io/replica/reference/groupChildren.md)

- [`matchAdultsWithChildren`](https://ready4-dev.github.io/replica/reference/matchAdultsWithChildren.md)

An error is raised if the requested position identifier does not exist.

## See also

[`addMembers`](https://ready4-dev.github.io/replica/reference/addMembers.md),
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)

## Examples

``` r
if (FALSE) { # \dontrun{

hh <- HouseholdType(
  "Family"
)

hh <- addMembers(
  hh,
  household_position = "Parent",
  position_identifier = "adult",
  amount = 2,
  backup_position_identifiers = character()
)

adult_position <- getPositionForName(
  hh,
  "adult"
)

adult_position$amount

} # }
```
