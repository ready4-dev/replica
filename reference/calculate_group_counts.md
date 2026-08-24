# Convert Fractions into Integer Agent Counts

Converts a vector of fractional probabilities into integer counts while
preserving the required total number of agents.

## Usage

``` r
calculate_group_counts(fractions, n_agents_total)
```

## Arguments

- fractions:

  Named numeric vector containing category probabilities or fractions.

- n_agents_total:

  Integer total number of agents to allocate.

## Value

A named numeric vector containing integer counts.

## Details

Because synthetic agents cannot be subdivided, direct multiplication of
fractions by a target population size generally produces non-integer
values. Simple rounding can also lead to totals that differ from the
desired population size.

This function applies an iterative correction procedure that:

1.  Calculates initial rounded counts.

2.  Compares the resulting total with the desired population size.

3.  Identifies the category with the largest rounding discrepancy.

4.  Adjusts counts until the desired total is reached.

The returned counts always sum to `n_agents_total`.

The allocation procedure attempts to preserve the supplied proportions
as closely as possible while maintaining an integer-valued solution.

This function is used throughout the package wherever fractional
distributions must be converted into agent-level assignments.

It is used by:

- `matchAdultsWithChildren`

- Conditional attribute assignment workflows

## See also

[`calculate_fractions`](https://ready4-dev.github.io/replica/reference/calculate_fractions.md)

## Examples

``` r
fractions <- c(
  Degree = 0.45,
  Diploma = 0.25,
  School = 0.30
)

calculate_group_counts(
  fractions,
  10
)
#>  Degree Diploma  School 
#>       5       2       3 

fractions <- c(
  A = 0.33,
  B = 0.33,
  C = 0.34
)

calculate_group_counts(
  fractions,
  100
)
#>  A  B  C 
#> 33 33 34 
```
