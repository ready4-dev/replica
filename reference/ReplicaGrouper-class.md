# ReplicaGrouper Class

Coordinates the generation of synthetic households from a synthetic
population.

## Details

A `ReplicaGrouper` object manages one or more
[`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)
objects and applies household generation algorithms across user-defined
population groups.

The class is responsible for:

- Managing the synthetic population.

- Coordinating household generation workflows.

- Applying household-generation rules within geographic or demographic
  groups.

- Assigning household identifiers.

- Producing household-level summary tables.

Household generation typically proceeds as follows:

1.  Create a `ReplicaGrouper`.

2.  Create one or more
    [`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)
    objects.

3.  Register the household types using
    [`renew`](https://ready4-dev.github.io/replica/reference/renew.md).

4.  Execute household generation using
    [`enhance`](https://ready4-dev.github.io/replica/reference/enhance.md).

During execution:

1.  The synthetic population is partitioned according to `group_by`.

2.  Households are generated independently within each group.

3.  Household identifiers are assigned.

4.  Household-level summary tables are generated.

Results are returned as:

- A synthetic population containing household IDs.

- A synthetic household table.

## Slots

- `df_synth_pop`:

  Synthetic population stored as a `data.table`.

- `group_by`:

  Character vector specifying the variables used to partition the
  synthetic population during household generation.

  Typical examples include:

  - `"neighb_code"`

  - `"sa2_code"`

  - Geographic or administrative identifiers

- `target_column`:

  Character string identifying the column containing household-position
  classifications such as `"Parent"`, `"Child"` or `"SingleAdult"`.

- `household_types`:

  List of
  [`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)
  objects used during household generation.

## See also

[`ReplicaGrouper`](https://ready4-dev.github.io/replica/reference/ReplicaGrouper.md),
[`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md),
[`renew`](https://ready4-dev.github.io/replica/reference/renew.md),
[`enhance`](https://ready4-dev.github.io/replica/reference/enhance.md)

## Examples

``` r
if (FALSE) { # \dontrun{

hg <- ReplicaGrouper(
  df_synth_pop = pop,
  group_by = "neighb_code"
)

hg <- renew(
  hg,
  hh
)

result <- enhance(
  hg
)

} # }
```
