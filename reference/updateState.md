# Update ReplicaStructure State

Attaches a synthetic population and household-position column to a
[`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)
object.

## Usage

``` r
updateState(object, df_synth_pop, household_position_column)

# S4 method for class 'ReplicaStructure'
updateState(object, df_synth_pop, household_position_column)
```

## Arguments

- object:

  A
  [`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)
  object.

- df_synth_pop:

  Synthetic population.

- household_position_column:

  Character string identifying the household-position column.

## Value

An updated
[`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)
object.

## Details

This method is typically called prior to household generation.

## See also

[`createFromMembers`](https://ready4-dev.github.io/replica/reference/createFromMembers.md),
[`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)

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
