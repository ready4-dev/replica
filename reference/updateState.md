# Update HouseholdType State

Attaches a synthetic population and household-position column to a
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
object.

## Usage

``` r
updateState(object, df_synth_pop, household_position_column)

# S4 method for class 'HouseholdType'
updateState(object, df_synth_pop, household_position_column)
```

## Arguments

- object:

  A
  [`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
  object.

- df_synth_pop:

  Synthetic population.

- household_position_column:

  Character string identifying the household-position column.

## Value

An updated
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
object.

## Details

This method is typically called prior to household generation.

## See also

[`createFromMembers`](https://ready4-dev.github.io/replica/reference/createFromMembers.md),
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)

## Examples

``` r
if (FALSE) { # \dontrun{

hh <- updateState(
  hh,
  pop,
  "household_position"
)

} # }
```
