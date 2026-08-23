# Create a ReplicaGrouper Object

Creates a new `ReplicaGrouper` used to generate synthetic households
from an existing synthetic population.

## Usage

``` r
ReplicaGrouper(population, group_by, position_column = "household_position")
```

## Arguments

- population:

  A synthetic population stored as a data.frame or `data.table`.

  Each row should represent a single synthetic agent.

- group_by:

  Character vector specifying the variables used to partition the
  population during household generation.

  Typical examples include:

  - `"neighb_code"`

  - `"sa2_code"`

  - Other geographic identifiers

  Household generation is performed independently within each grouping
  combination.

- position_column:

  Character string identifying the column containing household-position
  classifications.

  The specified column should contain values such as:

  - `"Parent"`

  - `"Child"`

  - `"SingleAdult"`

  Defaults to:


      "household_position"

## Value

A new `ReplicaGrouper` object.

## Details

The resulting object acts as the top-level coordinator of the
household-generation workflow and manages one or more
[`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)
objects.

The constructor:

1.  Stores the synthetic population.

2.  Stores grouping information.

3.  Initializes an empty collection of
    [`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)
    objects.

4.  Creates an empty `household_id` column if one does not already
    exist.

[`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)
objects are subsequently registered using
[`renew`](https://ready4-dev.github.io/replica/reference/renew.md).

Household generation is then executed using
[`manufacture`](https://ready4-dev.github.io/replica/reference/manufacture.md).

## See also

[`ReplicaGrouper-class`](https://ready4-dev.github.io/replica/reference/ReplicaGrouper-class.md),
[`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md),
[`renew`](https://ready4-dev.github.io/replica/reference/renew.md),
[`manufacture`](https://ready4-dev.github.io/replica/reference/manufacture.md),
[`procure`](https://ready4-dev.github.io/replica/reference/procure.md)

## Examples

``` r
if (FALSE) { # \dontrun{

library(data.table)

pop <- data.table(
  agent_id = 1:100,
  neighb_code = sample(
    c("N1", "N2"),
    100,
    replace = TRUE
  )
)

grouper <- ReplicaGrouper(
  population = pop,
  group_by = "neighb_code"
)

} # }
```
