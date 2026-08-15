# Assign Household Identifiers to Agents

Writes household identifiers from the household structures stored within
a
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
object back into the associated synthetic population.

## Usage

``` r
agentToHousehold(object)

# S4 method for class 'HouseholdType'
agentToHousehold(object)
```

## Arguments

- object:

  A
  [`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
  object.

## Value

An updated
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
object containing household identifiers in the synthetic population.

## Details

Each agent belonging to a generated household receives a value in the
`household_id` column corresponding to the household to which they
belong.

This method is typically called after household generation has completed
and before household-level summary tables are created using
[`householdsToDataFrame`](https://ready4-dev.github.io/replica/reference/householdsToDataFrame.md).

Household identifiers are obtained from the `households` slot.

For each household:

1.  Household members listed in `household$all` are identified.

2.  The corresponding household identifier is written to the synthetic
    population.

After execution, household assignments can be accessed via:


    object@df_synth_pop$household_id

This method is used as part of the household-generation workflow
implemented by
[`run`](https://ready4-dev.github.io/replica/reference/run.md) for
[`HouseholdGrouper`](https://ready4-dev.github.io/replica/reference/HouseholdGrouper.md)
objects.

## See also

[`householdsToDataFrame`](https://ready4-dev.github.io/replica/reference/householdsToDataFrame.md),
[`createHouseholdWithId`](https://ready4-dev.github.io/replica/reference/createHouseholdWithId.md),
[`run`](https://ready4-dev.github.io/replica/reference/run.md),
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)

## Examples

``` r
if (FALSE) { # \dontrun{

hh <- agentToHousehold(
  hh
)

head(
  hh@df_synth_pop
)

} # }
```
