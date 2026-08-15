# Convert a Synthetic Population to a Contingency Table

Converts an agent-level synthetic population into a contingency table.

## Usage

``` r
synthetic_population_to_contingency(
  df_synthetic_population,
  columns = NULL,
  full_crosstab = FALSE
)
```

## Arguments

- df_synthetic_population:

  A synthetic population stored as a data.frame or `data.table`.

  Each row should correspond to a single agent.

- columns:

  Character vector containing the attributes to include in the
  contingency table.

  If `NULL`, all columns are used.

- full_crosstab:

  Logical value indicating whether missing combinations should be
  explicitly included.

  If:

  FALSE

  :   Only observed combinations are returned.

  TRUE

  :   Missing combinations are included with a count of zero.

## Value

A contingency table containing:

- The requested grouping variables.

- A `count` column.

## Details

The resulting contingency table contains one row for each unique
combination of the specified attributes together with a `count` column
indicating the number of agents in that group.

This function is used extensively throughout GenSynthPopR for:

- Constructing validation tables.

- Computing marginal distributions.

- Comparing synthetic populations against target contingency tables.

- Statistical goodness-of-fit testing.

For each unique combination of the selected attributes, the function
counts the number of agents in the synthetic population belonging to
that combination.

When `full_crosstab = TRUE`, the function generates a complete
cross-classification of all observed levels and assigns zero counts to
combinations that do not occur in the population.

This behaviour is particularly useful when preparing data for iterative
proportional fitting (IPF) or statistical validation procedures.

## See also

`get_margin_series_from_synthetic_population`,
`get_margin_frames_from_synthetic_population`,
`validate_synthetic_population_fit`, `calculate_z_squared_score`

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

synthetic_population_to_contingency(
  population,
  c(
    "gender",
    "education"
  )
)
#> Error in .(count = .N): could not find function "."

synthetic_population_to_contingency(
  population,
  c(
    "gender",
    "education"
  ),
  full_crosstab = TRUE
)
#> Error in .(count = .N): could not find function "."
```
