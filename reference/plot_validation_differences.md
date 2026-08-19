# Plot percentage-point differences

Creates a visualisation of percentage-point differences between observed
and expected distributions.

## Usage

``` r
plot_validation_differences(validation_result)
```

## Arguments

- validation_result:

  A validation object returned by
  [`validate_synthetic_population_fit`](https://ready4-dev.github.io/replica/reference/validate_synthetic_population_fit.md).

## Value

A ggplot object.

## Examples

``` r
if (FALSE) { # \dontrun{
plot_validation_differences(
  adder@validation_results
)
} # }
```
