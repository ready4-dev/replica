# Validate the Fit of a Synthetic Population

Compares a synthetic population against an expected contingency table
and evaluates goodness-of-fit.

## Usage

``` r
validate_synthetic_population_fit(
  synthetic_population,
  expected,
  dimensions,
  name
)
```

## Arguments

- synthetic_population:

  A synthetic population stored as a data.frame or data.table.

- expected:

  Reference contingency table containing the expected distribution.

- dimensions:

  Character vector identifying the variables used to construct the
  comparison contingency table.

- name:

  Character string used in validation messages and warning output.

## Value

A list object with multiple comparison results.

## Details

The function:

1.  Converts the synthetic population into a contingency table using
    [`synthetic_population_to_contingency`](https://ready4-dev.github.io/replica/reference/synthetic_population_to_contingency.md).

2.  Aligns the observed and expected distributions.

3.  Calculates goodness-of-fit statistics using
    [`calculate_z_squared_score`](https://ready4-dev.github.io/replica/reference/calculate_z_squared_score.md).

4.  Emits a warning if the p-value is below 0.05.

## See also

[`calculate_z_squared_score`](https://ready4-dev.github.io/replica/reference/calculate_z_squared_score.md),
[`synthetic_population_to_contingency`](https://ready4-dev.github.io/replica/reference/synthetic_population_to_contingency.md)

## Examples

``` r
if (FALSE) { # \dontrun{

validate_synthetic_population_fit(
  synthetic_population,
  expected,
  dimensions = c(
    "gender",
    "education"
  ),
  name = "Education"
)

} # }
```
