# Generate Multiple Margin Tables from a Synthetic Population

Creates a collection of marginal distributions from a synthetic
population.

## Usage

``` r
get_margin_frames_from_synthetic_population(df_synth_pop, margins)
```

## Arguments

- df_synth_pop:

  A synthetic population stored as a data.frame or `data.table`.

- margins:

  List of variable names defining the requested margins.

  Each list entry specifies the variables that will be aggregated
  together.

## Value

A list of margin tables.

## Details

This function is useful when multiple margin tables are required for:

- Validation.

- Iterative proportional fitting (IPF).

- Statistical reporting.

For each entry in `margin_names`, the function computes the
corresponding marginal distribution and returns the collection as a
named list.

This utility is commonly used when preparing inputs for IPF workflows
and validating synthetic populations against known marginals.

## See also

[`get_margin_series_from_synthetic_population`](https://ready4-dev.github.io/replica/reference/get_margin_series_from_synthetic_population.md),
[`ConditionalAttributeAdder`](https://ready4-dev.github.io/replica/reference/ConditionalAttributeAdder.md)

## Examples

``` r
if (FALSE) { # \dontrun{

margins <- get_margin_frames_from_synthetic_population(
  population,
  list(
    "gender",
    "age_group"
  )
)

} # }
```
