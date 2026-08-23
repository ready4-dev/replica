# ReplicaGrouper Class

Coordinates the generation of synthetic households from a synthetic
population using one or more
[`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)
objects.

## Details

A `ReplicaGrouper` object manages one or more
[`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)
objects and applies household generation algorithms across user-defined
population groups.

The class is responsible for:

- Managing the synthetic population.

- Coordinating household-generation workflows.

- Applying household-generation rules within geographic or demographic
  groups.

- Assigning household identifiers.

- Producing household-level summary tables.

Household generation typically proceeds as follows:

1.  Create a `ReplicaGrouper`.

2.  Create one or more
    [`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)
    objects.

3.  Register the structures using
    [`renew`](https://ready4-dev.github.io/replica/reference/renew.md).

4.  Execute household generation using
    [`manufacture`](https://ready4-dev.github.io/replica/reference/manufacture.md).

During execution:

1.  The synthetic population is partitioned according to `group_by`.

2.  Households are generated independently within each group.

3.  Household identifiers are assigned.

4.  Household-level summary tables are generated.

Results are returned as:

- A synthetic population containing household IDs.

- A synthetic household table.

## Slots

- `population`:

  Synthetic population stored as a `data.table`.

- `group_by`:

  Character vector specifying the variables used to partition the
  synthetic population during household generation.

  Typical examples include:

  - `"neighb_code"`

  - `"sa2_code"`

  - Geographic or administrative identifiers

- `position_column`:

  Character string identifying the column containing household-position
  classifications such as `"Parent"`, `"Child"` or `"SingleAdult"`.

- `structures`:

  List of
  [`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)
  objects used during household generation.

## See also

[`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md),
[`manufacture`](https://ready4-dev.github.io/replica/reference/manufacture.md),
[`renew`](https://ready4-dev.github.io/replica/reference/renew.md),
[`procure`](https://ready4-dev.github.io/replica/reference/procure.md)

## Examples

``` r
if (FALSE) { # \dontrun{

grouper <- ReplicaGrouper(
  population = pop,
  group_by = "neighb_code"
)

STRUCTURE <- ReplicaStructure(
  household_type = "CoupleWithChildren"
)

grouper <- renew(
  grouper,
  STRUCTURE = STRUCTURE,
  what = "structure"
)

result <- manufacture(
  grouper
)

} # }
```
