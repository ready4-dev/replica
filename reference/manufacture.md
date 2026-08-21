# Manufacture Replica Outputs

Creates new outputs from replica modules.

## Usage

``` r
# S4 method for class 'ReplicaGrouper'
manufacture(x, ...)

# S4 method for class 'ReplicaStructure'
manufacture(x, ...)
```

## Arguments

- x:

  A `ReplicaStructure`.

- ...:

  Additional arguments

## Value

A list containing:

- `synthetic_population`;

- `synthetic_households`; and

- `object`.

The `synthetic_population` table contains one row per synthetic agent.

The `synthetic_households` table contains one row per synthetic
household.

A data.frame containing one row per synthetic household.

## Details

The behaviour of `manufacture()` depends on the class of the supplied
object.

Methods are currently available for:

- `ReplicaStructure`

- `ReplicaGrouper`

`manufacture()` is used when a replica module generates a new output
object rather than updating itself.

Depending on the module supplied, the method may:

- create household-level summary tables; or

- generate complete synthetic household outputs.

## ReplicaGrouper Method

Generates synthetic households from a synthetic population using one or
more registered `ReplicaStructure` definitions.

For each grouping region, the method:

1.  identifies eligible household members;

2.  applies registered household structures;

3.  matches agents according to demographic rules;

4.  generates synthetic households;

5.  assigns household identifiers; and

6.  creates household-level summary outputs.

## ReplicaStructure Method

Creates a household-level summary table from a `ReplicaStructure`.

One row is returned per synthetic household.

Household-level summaries typically include:

- household identifiers;

- household type;

- household size; and

- grouping-region identifiers.

The resulting table can be used for reporting, validation and downstream
analysis.

## See also

[`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md),
`manufacture`

[`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md),
[`ReplicaGrouper`](https://ready4-dev.github.io/replica/reference/ReplicaGrouper.md),
[`renew`](https://ready4-dev.github.io/replica/reference/renew.md),
[`ratify`](https://ready4-dev.github.io/replica/reference/ratify.md)

## Examples

``` r
if (FALSE) { # \dontrun{

result <- manufacture(
  grouper
)

result$synthetic_population

result$synthetic_households

} # }

if (FALSE) { # \dontrun{

household_summary <- manufacture(
  structure
)

household_summary

} # }
```
