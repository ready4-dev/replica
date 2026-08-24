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
  [`ReplicaAdder`](https://ready4-dev.github.io/replica/reference/ReplicaAdder.md)
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
[`calculate_fractions`](https://ready4-dev.github.io/replica/reference/calculate_fractions.md)
and returns the resulting fractions indexed by the target attribute and
any relevant margin variables.

This function is used internally by
[`enhance`](https://ready4-dev.github.io/replica/reference/enhance.md)
during conditional attribute assignment.

Fractions are calculated separately within each conditioning group.

The result is subsequently used by:

- [`calculate_group_counts`](https://ready4-dev.github.io/replica/reference/calculate_group_counts.md)

- [`enhance`](https://ready4-dev.github.io/replica/reference/enhance.md)

If margin constraints have been supplied using
[`renew`](https://ready4-dev.github.io/replica/reference/renew.md), the
returned table will also include the corresponding margin variables.

The function automatically removes duplicate index names when margins
overlap with the target attribute.

## See also

[`calculate_fractions`](https://ready4-dev.github.io/replica/reference/calculate_fractions.md),
[`calculate_group_counts`](https://ready4-dev.github.io/replica/reference/calculate_group_counts.md),
[`ReplicaAdder`](https://ready4-dev.github.io/replica/reference/ReplicaAdder.md),
[`enhance`](https://ready4-dev.github.io/replica/reference/enhance.md)

## Examples

``` r
if (FALSE) { # \dontrun{

fractions <- getGroupFractions(
  ADDER,
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
