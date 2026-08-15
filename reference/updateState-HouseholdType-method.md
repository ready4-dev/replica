# Update the Internal HouseholdType State

Attaches the current synthetic population and the household position
column to a `HouseholdType` object.

## Usage

``` r
# S4 method for class 'HouseholdType'
updateState(object, df_synth_pop, household_position_column)
```

## Arguments

- object:

  A `HouseholdType` object.

- df_synth_pop:

  A data frame or data.table containing the synthetic population.

- household_position_column:

  Character string identifying the column containing household-position
  classifications such as `"Parent"`, `"Child"`, or `"SingleAdult"`.

## Value

An updated `HouseholdType` object.

## Details

This method is typically called by household-generation workflows such
as `runHouseholdGrouper` prior to household construction.

The synthetic population stored by this method is subsequently used by:

- `createSingles`

- [`pairPartners`](https://ready4-dev.github.io/replica/reference/pairPartners.md)

- [`groupChildren`](https://ready4-dev.github.io/replica/reference/groupChildren.md)

- [`matchAdultsWithChildren`](https://ready4-dev.github.io/replica/reference/matchAdultsWithChildren.md)

- `agentToHousehold`

The supplied synthetic population is stored internally in the
`df_synth_pop` slot.

The supplied household-position column name is stored in the
`household_position_column` slot and used throughout the
household-generation workflow.

## See also

[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md),
`createSingles`,
[`pairPartners`](https://ready4-dev.github.io/replica/reference/pairPartners.md),
[`groupChildren`](https://ready4-dev.github.io/replica/reference/groupChildren.md),
[`matchAdultsWithChildren`](https://ready4-dev.github.io/replica/reference/matchAdultsWithChildren.md),
`runHouseholdGrouper`

## Examples

``` r
if (FALSE) { # \dontrun{

library(data.table)

pop <- data.table(
  agent_id = c(
    "A001",
    "A002"
  ),
  household_position = c(
    "Parent",
    "Parent"
  )
)

hh <- HouseholdType(
  "CoupleOnly"
)

hh <- updateState(
  hh,
  pop,
  "household_position"
)

hh@household_position_column

} # }
```
