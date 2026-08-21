# Calculate an Age Range from an Age-Gap Specification

Converts an age-gap specification into a valid age range for candidate
selection.

## Usage

``` r
calculate_age_range_from_gap(age, gap_start, gap_end)
```

## Arguments

- age:

  Numeric reference age.

- gap_start:

  Numeric lower age-gap bound.

- gap_end:

  Numeric upper age-gap bound.

## Value

A named list containing:

- age_start:

  Lower age bound.

- age_end:

  Upper age bound.

## Details

Given a reference age and lower/upper age-gap bounds, the function
calculates the corresponding acceptable age range.

This function is used by the household-generation subsystem when
searching for compatible partners.

Age bounds are calculated by adding the supplied age-gap values to the
reference age.

For example:


    age = 40
    gap_start = -5
    gap_end = 5

produces:


    age_start = 35
    age_end = 45

If the calculated lower bound is greater than the upper bound, the two
values are automatically swapped so that the returned interval is always
valid.

This behaviour mirrors the original GenSynthPop implementation.

## See also

[`parse_age_gap`](https://ready4-dev.github.io/replica/reference/parse_age_gap.md),
[`score_suitability_by_age_disparity`](https://ready4-dev.github.io/replica/reference/score_suitability_by_age_disparity.md),
[`findCoupleCandidates`](https://ready4-dev.github.io/replica/reference/findCoupleCandidates.md)

## Examples

``` r
calculate_age_range_from_gap(
  age = 40,
  gap_start = -5,
  gap_end = 5
)
#> $age_start
#> [1] 35
#> 
#> $age_end
#> [1] 45
#> 

calculate_age_range_from_gap(
  age = 40,
  gap_start = 5,
  gap_end = 15
)
#> $age_start
#> [1] 45
#> 
#> $age_end
#> [1] 55
#> 

calculate_age_range_from_gap(
  age = 40,
  gap_start = -10,
  gap_end = -5
)
#> $age_start
#> [1] 30
#> 
#> $age_end
#> [1] 35
#> 
```
