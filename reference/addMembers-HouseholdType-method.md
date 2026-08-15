# Add Household Members to a HouseholdType

Defines one component of a household structure used during synthetic
household generation.

## Usage

``` r
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

  A `HouseholdType` object.

- household_position:

  Character vector identifying one or more household-position values in
  the synthetic population.

- position_identifier:

  Internal identifier used by the household generation algorithms.
  Typical values are `"adult"` and `"child"`.

- amount:

  Number of agents required for this position.

- backup_position_identifiers:

  Character vector of alternative household-position categories that may
  be used when insufficient suitable agents are available in the primary
  pool.

## Value

An updated `HouseholdType` object.

## Details

This method specifies:

- The household position (for example, `"Parent"` or `"Child"`).

- A position identifier used internally by the household generation
  algorithms (for example, `"adult"` or `"child"`).

- The number of agents required for that position.

- Optional backup positions that may be used when suitable agents cannot
  be found in the primary position pool.

Multiple calls to `addMembers()` can be used to define complex household
structures.

For example, a household consisting of two parents and two children can
be defined by:


    hh <- addMembers(
      hh,
      household_position = "Parent",
      position_identifier = "adult",
      amount = 2,
      backup_position_identifiers = character()
    )

    hh <- addMembers(
      hh,
      household_position = "Child",
      position_identifier = "child",
      amount = 2,
      backup_position_identifiers = character()
    )

## See also

`createFromMembers`, `updateState`,
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)

## Examples

``` r
hh <- HouseholdType("Family")

hh <- addMembers(
  hh,
  household_position = "Parent",
  position_identifier = "adult",
  amount = 2,
  backup_position_identifiers = character()
)

hh <- addMembers(
  hh,
  household_position = "Child",
  position_identifier = "child",
  amount = 2,
  backup_position_identifiers = character()
)
```
