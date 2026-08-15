# HouseholdGrouper Class

Coordinates the generation of synthetic households from a synthetic
population.

## Details

A `HouseholdGrouper` object manages one or more
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
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

1.  Create a `HouseholdGrouper`.

2.  Create one or more
    [`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
    objects.

3.  Register the household types using
    [`addHouseholdType`](https://ready4-dev.github.io/replica/reference/addHouseholdType.md).

4.  Execute household generation using
    [`run`](https://ready4-dev.github.io/replica/reference/run.md).

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
  [`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
  objects used during household generation.

## See also

[`HouseholdGrouper`](https://ready4-dev.github.io/replica/reference/HouseholdGrouper.md),
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md),
[`addHouseholdType`](https://ready4-dev.github.io/replica/reference/addHouseholdType.md),
[`run`](https://ready4-dev.github.io/replica/reference/run.md)

## Examples

``` r
if (FALSE) { # \dontrun{

hg <- HouseholdGrouper(
  df_synth_pop = pop,
  group_by = "neighb_code"
)

hg <- addHouseholdType(
  hg,
  hh
)

result <- run(
  hg
)

} # }
```
