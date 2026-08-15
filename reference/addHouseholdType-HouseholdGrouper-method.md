# Add a HouseholdType to a HouseholdGrouper

Registers a
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
object with a
[`HouseholdGrouper`](https://ready4-dev.github.io/replica/reference/HouseholdGrouper.md).

## Usage

``` r
# S4 method for class 'HouseholdGrouper'
addHouseholdType(object, household_type)
```

## Arguments

- object:

  A `HouseholdGrouper` object.

- household_type:

  A
  [`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
  object.

## Value

An updated `HouseholdGrouper` object.

## Details

Household types define the structures that will be generated during the
household-generation workflow.

Multiple household types may be added to the same grouper, allowing
different household structures to be constructed within a single
synthetic population.

Added household types are stored internally in the `household_types`
slot.

During execution, `runHouseholdGrouper` iterates over all registered
household types and applies their corresponding household-generation
rules.

Typical workflow:

1.  Create a `HouseholdGrouper`.

2.  Create one or more `HouseholdType` objects.

3.  Register the household types using `addHouseholdType()`.

4.  Execute household generation using `runHouseholdGrouper`.

Household types are applied in the order in which they are added.

## See also

[`HouseholdGrouper`](https://ready4-dev.github.io/replica/reference/HouseholdGrouper.md),
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md),
`runHouseholdGrouper`

## Examples

``` r
if (FALSE) { # \dontrun{

hg <- HouseholdGrouper(
  df_synth_pop = pop,
  group_by = "neighb_code"
)

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

hg <- addHouseholdType(
  hg,
  hh
)

} # }
```
