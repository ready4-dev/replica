# Ratify Attribute Assignment Results

Evaluates the quality of attribute assignment performed by a
`ReplicaAdder` and stores validation diagnostics within the module.

## Usage

``` r
# S4 method for class 'ReplicaAdder'
ratify(x, ...)
```

## Arguments

- x:

  A `ReplicaAdder` object.

- ...:

  Additional arguments passed to the generic method.

## Value

An updated `ReplicaAdder`.

An updated `ReplicaAdder`.

## Details

The `ratify()` method compares the observed distributions in the
synthetic population with the expected distributions supplied via the
reference contingency table.

Validation results are stored in the `validation_results` slot and
include:

- goodness-of-fit statistics;

- p-values;

- warning flags; and

- detailed comparisons of observed and expected distributions.

These diagnostics can subsequently be explored using the validation and
visualisation tools bundled with `replica`.

## ReplicaAdder Method

Evaluates the quality of attribute assignment and stores validation
diagnostics within the module.

The observed distributions in the synthetic population are compared with
the expected distributions supplied by the contingency table.

Validation results are stored in:


    x@validation_results

and include:

- z-squared statistics;

- p-values;

- warning flags; and

- detailed comparisons of observed and expected distributions.

## ReplicaAdder

For a `ReplicaAdder`, `ratify()`:

1.  checks the assigned synthetic population;

2.  compares observed and expected distributions;

3.  calculates validation statistics;

4.  stores validation results; and

5.  returns the updated module.

Validation results are stored in:


    x@validation_results

and may be inspected using:


    names(x@validation_results)

## See also

[`validate_synthetic_population_fit`](https://ready4-dev.github.io/replica/reference/validate_synthetic_population_fit.md),
[`plot_validation_distributions`](https://ready4-dev.github.io/replica/reference/plot_validation_distributions.md),
[`plot_validation_differences`](https://ready4-dev.github.io/replica/reference/plot_validation_differences.md),
[`plot_validation_heatmap`](https://ready4-dev.github.io/replica/reference/plot_validation_heatmap.md)

[`ReplicaAdder`](https://ready4-dev.github.io/replica/reference/ReplicaAdder.md),
[`validate_synthetic_population_fit`](https://ready4-dev.github.io/replica/reference/validate_synthetic_population_fit.md),
[`plot_validation_distributions`](https://ready4-dev.github.io/replica/reference/plot_validation_distributions.md),
[`plot_validation_differences`](https://ready4-dev.github.io/replica/reference/plot_validation_differences.md),
[`plot_validation_heatmap`](https://ready4-dev.github.io/replica/reference/plot_validation_heatmap.md)

## Examples

``` r
if (FALSE) { # \dontrun{

adder <- enhance(
  adder
)

adder <- ratify(
  adder
)

adder@validation_results

} # }

if (FALSE) { # \dontrun{

adder <- ReplicaAdder(
  synth_pop = population,
  contingency = contingency,
  target_attribute = "education",
  group_by = c(
    "age_group",
    "gender"
  )
)

adder <- enhance(adder)

adder <- ratify(adder)

adder@validation_results
} # }
```
