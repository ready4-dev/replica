# Plot observed and expected distributions

Creates a faceted comparison of observed and expected percentages from a
validation result.

## Usage

``` r
plot_validation_distributions(validation_result)
```

## Arguments

- validation_result:

  A validation object returned by
  [`validate_synthetic_population_fit`](https://ready4-dev.github.io/replica/reference/validate_synthetic_population_fit.md)
  or stored in the `validation_results` slot of a
  [`ReplicaAdder`](https://ready4-dev.github.io/replica/reference/ReplicaAdder.md).

## Value

A ggplot object.

## Examples

``` r
if (FALSE) { # \dontrun{
plot_validation_distributions(
  adder@validation_results
)
} # }
```
