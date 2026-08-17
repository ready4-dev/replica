# Generate Agent Values from Conditional Fractions

Converts a conditional probability distribution into a vector of
target-attribute values suitable for assignment to synthetic agents.

## Usage

``` r
getAgentValuesFromFractions(fractions, group_size)
```

## Arguments

- fractions:

  Named numeric vector containing conditional probabilities or
  fractions.

  Each name represents a target-attribute category.

- group_size:

  Integer number of synthetic agents to be assigned values.

## Value

A character vector containing one target-attribute value for each
synthetic agent in the group.

## Details

The function:

1.  Converts fractions into integer counts using
    [`calculate_group_counts`](https://ready4-dev.github.io/replica/reference/calculate_group_counts.md).

2.  Expands the counts into individual target-attribute values.

3.  Randomises the resulting values to avoid systematic ordering
    effects.

This function is used internally by
[`run`](https://ready4-dev.github.io/replica/reference/run.md) during
conditional attribute assignment.

Fractions are first converted into integer counts using
[`calculate_group_counts`](https://ready4-dev.github.io/replica/reference/calculate_group_counts.md).

For example:


    Degree   0.50
    Diploma  0.30
    School   0.20

with:


    group_size = 10

produces:


    Degree   5
    Diploma  3
    School   2

which is then expanded into:


    Degree
    Degree
    Degree
    Degree
    Degree
    Diploma
    Diploma
    Diploma
    School
    School

The returned vector is randomly permuted before being returned.

## See also

[`calculate_group_counts`](https://ready4-dev.github.io/replica/reference/calculate_group_counts.md),
[`calculate_fractions`](https://ready4-dev.github.io/replica/reference/calculate_fractions.md),
[`getGroupFractions`](https://ready4-dev.github.io/replica/reference/getGroupFractions.md),
[`ConditionalAttributeAdder`](https://ready4-dev.github.io/replica/reference/ConditionalAttributeAdder.md),
[`run`](https://ready4-dev.github.io/replica/reference/run.md)

## Examples

``` r
if (FALSE) { # \dontrun{
fractions <- c(
  Degree = 0.50,
  Diploma = 0.30,
  School = 0.20
)

values <- getAgentValuesFromFractions(
  fractions,
  group_size = 10
)

length(values)
} # }

if (FALSE) { # \dontrun{
fractions <- c(
  Degree = 0.45,
  Diploma = 0.25,
  School = 0.30
)

getAgentValuesFromFractions(
  fractions,
  group_size = 20
)
} # }
```
