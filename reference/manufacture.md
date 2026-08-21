# Manufacture Replica Outputs

Creates new outputs from replica modules.

## Usage

``` r
# S4 method for class 'ReplicaGrouper'
manufacture(x, ...)
```

## Arguments

- x:

  A `ReplicaGrouper`.

- ...:

  Additional arguments that can be supplied to the method.

## Value

A list containing:

- `synthetic_population`;

- `synthetic_households`; and

- `object`.

## Details

The behaviour of `manufacture()` depends on the class of the supplied
object.

Methods are currently available for:

- `ReplicaGrouper`

## ReplicaGrouper Method

Generates synthetic households from a synthetic population using one or
more registered `ReplicaStructure` definitions.

Household generation is performed independently within each grouping
region.

## See also

[`ReplicaGrouper`](https://ready4-dev.github.io/replica/reference/ReplicaGrouper.md),
[`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md),
[`renew`](https://ready4-dev.github.io/replica/reference/renew.md)

## Examples

``` r
if (FALSE) { # \dontrun{

result <- manufacture(
  grouper
)

result$synthetic_population

result$synthetic_households

} # }
```
