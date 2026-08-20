# Assign Household Identifiers to Agents

Writes household identifiers from the household structures stored within
a
[`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)
object back into the associated synthetic population.

## Usage

``` r
agentToHousehold(object)

# S4 method for class 'ReplicaStructure'
agentToHousehold(object)
```

## Arguments

- object:

  A
  [`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)
  object.

## Value

An updated
[`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)
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
[`enhance`](https://ready4-dev.github.io/replica/reference/enhance.md)
for
[`ReplicaGrouper`](https://ready4-dev.github.io/replica/reference/ReplicaGrouper.md)
objects.

## See also

[`householdsToDataFrame`](https://ready4-dev.github.io/replica/reference/householdsToDataFrame.md),
[`create_household_with_id`](https://ready4-dev.github.io/replica/reference/create_household_with_id.md),
[`enhance`](https://ready4-dev.github.io/replica/reference/enhance.md),
[`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)

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
