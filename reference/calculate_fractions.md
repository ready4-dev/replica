# Calculate Conditional Fractions from a Contingency Table

Converts contingency-table counts into conditional probabilities
(fractions).

## Usage

``` r
calculate_fractions(dt, group_by, target_attribute, margins_group = NULL)
```

## Arguments

- dt:

  A contingency table containing a `count` column.

- group_by:

  Character vector containing the conditioning variables.

- target_attribute:

  Character string identifying the target attribute.

- margins_group:

  Optional character vector containing additional grouping variables
  introduced through margin fitting.

## Value

The supplied contingency table with an additional column named
`fraction`.

## Details

For each conditioning group, the function computes the proportion
represented by each target-attribute category.

The resulting fractions are subsequently used to allocate synthetic
agents during conditional attribute assignment.

Fractions are calculated separately within each conditioning group.

For a contingency table:


    age_group gender education count
    18-64     Male   Degree    45
    18-64     Male   Diploma   25
    18-64     Male   School    30

the resulting fractions are:


    Degree   0.45
    Diploma  0.25
    School   0.30

Groups whose total count equals zero receive fractions of zero rather
than `NA` or `NaN`.

This behaviour prevents failures during synthetic-population generation
when contingency tables contain zero-count groups.

## See also

[`getGroupFractions`](https://ready4-dev.github.io/replica/reference/getGroupFractions.md),
[`calculate_group_counts`](https://ready4-dev.github.io/replica/reference/calculate_group_counts.md),
[`ReplicaAdder`](https://ready4-dev.github.io/replica/reference/ReplicaAdder.md),
[`enhance`](https://ready4-dev.github.io/replica/reference/enhance.md)

## Examples

``` r
library(data.table)
#> 
#> Attaching package: ‘data.table’
#> The following object is masked from ‘package:base’:
#> 
#>     %notin%

dt <- data.table(
  age_group = c(
    "18-64",
    "18-64",
    "18-64"
  ),
  gender = c(
    "Male",
    "Male",
    "Male"
  ),
  education = c(
    "Degree",
    "Diploma",
    "School"
  ),
  count = c(
    45,
    25,
    30
  )
)

calculate_fractions(
  dt,
  group_by = c(
    "age_group",
    "gender"
  ),
  target_attribute =
    "education"
)
#>    age_group gender education count fraction
#>       <char> <char>    <char> <num>    <num>
#> 1:     18-64   Male    Degree    45     0.45
#> 2:     18-64   Male   Diploma    25     0.25
#> 3:     18-64   Male    School    30     0.30

dt <- data.table(
  gender = c(
    "Female",
    "Female",
    "Female"
  ),
  education = c(
    "Degree",
    "Diploma",
    "School"
  ),
  count = c(
    0,
    0,
    0
  )
)

calculate_fractions(
  dt,
  group_by = "gender",
  target_attribute = "education"
)
#>    gender education count fraction
#>    <char>    <char> <num>    <num>
#> 1: Female    Degree     0        0
#> 2: Female   Diploma     0        0
#> 3: Female    School     0        0
```
