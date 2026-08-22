# Extract a Margin Distribution from a Synthetic Population

Calculates a marginal distribution for one or more variables in a
synthetic population.

## Usage

``` r
get_margin_series_from_synthetic_population(population, margins)
```

## Arguments

- population:

  A synthetic population stored as a data.frame or `data.table`.

- margins:

  Character vector identifying the variables that define the margin.

## Value

A data frame containing the requested grouping variables and a `count`
column.

## Details

The resulting margin can be used for:

- Validation.

- Comparison with external data sources.

- Iterative proportional fitting (IPF).

- Diagnostic reporting.

The function aggregates the synthetic population over the supplied
variables and counts the number of agents in each resulting category.

Unlike
[`transform_to_contingency`](https://ready4-dev.github.io/replica/reference/transform_to_contingency.md),
this function is intended specifically for marginal distributions rather
than higher-dimensional contingency tables.

## See also

[`get_margin_frames_from_synthetic_population`](https://ready4-dev.github.io/replica/reference/get_margin_frames_from_synthetic_population.md),
[`transform_to_contingency`](https://ready4-dev.github.io/replica/reference/transform_to_contingency.md)

## Examples

``` r
population <- data.frame(
  gender = c(
    "Male",
    "Male",
    "Female"
  )
)

get_margin_series_from_synthetic_population(
  population,
  "gender"
)
#> $gender
#> [1] 2 1
#> 
```
