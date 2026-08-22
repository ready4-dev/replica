# Convert a Synthetic Population to a Contingency Table

Converts an agent-level synthetic population into a contingency table.

## Usage

``` r
transform_to_contingency(
  df_synthetic_population,
  columns = NULL,
  full_crosstab = FALSE
)
```

## Arguments

- df_synthetic_population:

  A synthetic population stored as a data.frame or `data.table`.

- columns:

  Character vector identifying the variables to include in the
  contingency table.

  If `NULL`, all available variables are used.

- full_crosstab:

  Logical value indicating whether all possible combinations of factor
  levels should be represented.

  If:

  `FALSE`

  :   Only observed combinations are returned.

  `TRUE`

  :   Missing combinations are included with `count = 0`.

## Value

A contingency table containing the supplied grouping variables and a
`count` column.

## Details

The resulting table contains one row for each unique combination of the
supplied attributes together with a `count` column indicating the number
of synthetic agents belonging to that group.

This function is one of the core analytical utilities in replica and is
used for:

- Validation of synthetic populations.

- Comparison with reference contingency tables.

- Goodness-of-fit assessment.

- Calculation of marginal distributions.

- Python-parity testing.

The function aggregates the synthetic population by the supplied
variables and counts the number of agents in each resulting group.

When `full_crosstab = TRUE`, a complete cross-classification of all
observed factor levels is generated and any absent combinations receive
a count of zero.

This behaviour is particularly useful when comparing synthetic
populations against reference distributions.

## See also

[`validate_synthetic_population_fit`](https://ready4-dev.github.io/replica/reference/validate_synthetic_population_fit.md),
[`calculate_z_squared_score`](https://ready4-dev.github.io/replica/reference/calculate_z_squared_score.md),
[`update_contingency_table`](https://ready4-dev.github.io/replica/reference/update_contingency_table.md)

## Examples

``` r
population <- data.frame(
  gender = c(
    "Male",
    "Male",
    "Female"
  ),
  education = c(
    "Degree",
    "Degree",
    "School"
  )
)

transform_to_contingency(
  population,
  c(
    "gender",
    "education"
  )
)
#>   gender education count
#> 1   Male    Degree     2
#> 2 Female    School     1

transform_to_contingency(
  population,
  c(
    "gender",
    "education"
  ),
  full_crosstab = TRUE
)
#>   gender education count
#> 1 Female    Degree     0
#> 2 Female    School     1
#> 3   Male    Degree     2
#> 4   Male    School     0
```
