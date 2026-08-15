# Extract Conditional Fractions for a Target Attribute

Computes and extracts conditional fractions from a contingency table for
use during attribute assignment.

## Usage

``` r
getGroupFractions(object, dt)
```

## Arguments

- object:

  A
  [`ConditionalAttributeAdder`](https://ready4-dev.github.io/replica/reference/ConditionalAttributeAdder.md)
  object.

- dt:

  A contingency table containing the target attribute and a `count`
  column.

## Value

A data frame or data.table containing:

- The target attribute.

- Any relevant margin variables.

- A `fraction` column.

## Details

The function converts contingency-table counts into conditional
probabilities using
[`calculateFractions`](https://ready4-dev.github.io/replica/reference/calculateFractions.md)
and returns the resulting fractions indexed by the target attribute and
any relevant margin variables.

This function is used internally by `run` during conditional attribute
assignment.

Fractions are calculated separately within each conditioning group.

The result is subsequently used by:

- [`getAgentValuesFromFractions`](https://ready4-dev.github.io/replica/reference/getAgentValuesFromFractions.md)

- [`calculateGroupCounts`](https://ready4-dev.github.io/replica/reference/calculateGroupCounts.md)

- `run`

If margin constraints have been supplied using `addMargins`, the
returned table will also include the corresponding margin variables.

The function automatically removes duplicate index names when margins
overlap with the target attribute.

## See also

[`calculateFractions`](https://ready4-dev.github.io/replica/reference/calculateFractions.md),
[`calculateGroupCounts`](https://ready4-dev.github.io/replica/reference/calculateGroupCounts.md),
[`getAgentValuesFromFractions`](https://ready4-dev.github.io/replica/reference/getAgentValuesFromFractions.md),
[`ConditionalAttributeAdder`](https://ready4-dev.github.io/replica/reference/ConditionalAttributeAdder.md),
`run`

## Examples

``` r
if (FALSE) { # \dontrun{

fractions <- getGroupFractions(
  adder,
  contingency_group
)

fractions

} # }

if (FALSE) { # \dontrun{

# Typical output

# education fraction
# Degree      0.45
# Diploma     0.25
# School      0.30

} # }
```
