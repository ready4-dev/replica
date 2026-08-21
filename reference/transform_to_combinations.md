# Convert Multiple Columns to Attribute Combinations

Creates combined attribute values from multiple columns in a synthetic
population or contingency table.

## Usage

``` r
transform_to_combinations(df, attr_name, columns)
```

## Arguments

- df:

  Input data frame or data.table.

- attr_name:

  Character string specifying the name of the generated attribute.

- columns:

  Character vector containing the columns to convert.

## Value

A character vector containing combined attribute values.

## Details

This function is useful when constructing composite grouping variables
from several demographic attributes.

Examples include:

- Age-group and gender combinations.

- Education and employment combinations.

- Geographic and demographic combinations.

Values from the supplied columns are combined into a single string
representation for each row.

The resulting values can be used as:

- Composite identifiers.

- Grouping variables.

- Keys for matching and aggregation.

This function is used internally by several utilities in replica but may
also be useful for user-defined reporting and validation workflows.

## See also

[`transform_to_contingency`](https://ready4-dev.github.io/replica/reference/transform_to_contingency.md),
[`get_margin_series_from_synthetic_population`](https://ready4-dev.github.io/replica/reference/get_margin_series_from_synthetic_population.md)

## Examples

``` r
df <- data.frame(
  Degree = c(50, 20),
  Diploma = c(30, 10),
  School = c(20, 70),
  gender = c(
    "Male",
    "Female"
  )
)

transform_to_combinations(
  df = df,
  attr_name = "education",
  columns = c(
    "Degree",
    "Diploma",
    "School"
  )
)
#>    gender education count
#>    <char>    <fctr> <num>
#> 1:   Male    Degree    50
#> 2: Female    Degree    20
#> 3:   Male   Diploma    30
#> 4: Female   Diploma    10
#> 5:   Male    School    20
#> 6: Female    School    70
```
