# Parse an Age-Gap Specification

Converts an age-gap specification into numeric lower and upper bounds.

## Usage

``` r
parse_age_gap(age_gap)
```

## Arguments

- age_gap:

  Character string specifying an age-gap range.

## Value

A named numeric vector containing:

- lower:

  Lower age-gap bound.

- upper:

  Upper age-gap bound.

## Details

Age-gap specifications are used throughout the household generation
workflow to define acceptable age differences between:

- Partners.

- Parents and children.

Supported formats include:


    "20-30"
    "-5-5"
    "-10--5"
    "-10-5"

Positive values indicate that the comparison individual is expected to
be older.

Negative values indicate that the comparison individual is expected to
be younger.

Examples:

- `"20-30"`:

  Parent should be between 20 and 30 years older than the child.

- `"-5-5"`:

  Partner may be up to 5 years younger or 5 years older.

- `"-10--5"`:

  Partner should be between 5 and 10 years younger.

- `"-10-5"`:

  Partner may be up to 10 years younger or up to 5 years older.

Invalid age-gap strings generate an error.

## See also

[`matchAdultsWithChildren`](https://ready4-dev.github.io/replica/reference/matchAdultsWithChildren.md),
[`calculate_age_range_from_gap`](https://ready4-dev.github.io/replica/reference/calculate_age_range_from_gap.md)

## Examples

``` r
parse_age_gap("20-30")
#> lower upper 
#>    20    30 

parse_age_gap("-5-5")
#> lower upper 
#>    -5     5 

parse_age_gap("-10--5")
#> lower upper 
#>   -10    -5 

parse_age_gap("-10-5")
#> lower upper 
#>   -10     5 
```
