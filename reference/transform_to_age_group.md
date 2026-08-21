# Convert an Integer Age to an Age Group

Maps an individual age to a categorical age-group label.

## Usage

``` r
transform_to_age_group(age, age_groups)
```

## Arguments

- age:

  Numeric age to be converted.

- age_groups:

  Character vector containing age-group definitions.

  Age groups should:

  - Cover the expected age range.

  - Not overlap.

  - Contain at most one open-ended category.

## Value

A character string containing the matching age-group label.

Returns `NA` if no matching age group can be found.

## Details

Age groups are specified using either:

- Closed-open intervals of the form `"lower-upper"`.

- Open-ended intervals of the form `"lower+"`.

Examples:


    "0-15"
    "15-25"
    "25-45"
    "45-65"
    "65+"

This function is useful when converting continuous age information into
the categorical age-group formats commonly used in contingency tables
and marginal distributions.

Age groups are interpreted as:

- `"a-b"`:

  Ages greater than or equal to `a` and strictly less than `b`.

- `"a+"`:

  Ages greater than or equal to `a`.

For example:


    transform_to_age_group(
      20,
      c(
        "0-15",
        "15-25",
        "25-45"
      )
    )

returns:


    "15-25"

## See also

[`transform_to_contingency`](https://ready4-dev.github.io/replica/reference/transform_to_contingency.md),
[`transform_to_combinations`](https://ready4-dev.github.io/replica/reference/transform_to_combinations.md)

## Examples

``` r
transform_to_age_group(
  age = 12,
  age_groups = c(
    "0-15",
    "15-25",
    "25-45"
  )
)
#> [1] "0-15"

transform_to_age_group(
  age = 20,
  age_groups = c(
    "0-15",
    "15-25",
    "25-45"
  )
)
#> [1] "15-25"

transform_to_age_group(
  age = 70,
  age_groups = c(
    "0-15",
    "15-25",
    "25-45",
    "45-65",
    "65+"
  )
)
#> [1] "65+"
```
