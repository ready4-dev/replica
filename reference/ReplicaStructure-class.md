# ReplicaStructure Class

Represents a household structure used during synthetic household
generation.

## Details

A `ReplicaStructure` object stores:

- Household composition requirements.

- Household-position definitions.

- Partner matching distributions.

- Parent-child matching distributions.

- Generated household records.

- Household assignment state.

Household types are used by
[`ReplicaGrouper`](https://ready4-dev.github.io/replica/reference/ReplicaGrouper.md)
to create synthetic households from an existing synthetic population.

Typical examples include:

- Couple household.

- Single-adult household.

- Family household.

- Single-parent household.

Household generation typically proceeds as follows:

1.  Create a `ReplicaStructure`.

2.  Define household positions using
    [`renew`](https://ready4-dev.github.io/replica/reference/renew.md).

3.  Configure distributions.

4.  Attach a synthetic population using
    [`updateState`](https://ready4-dev.github.io/replica/reference/updateState.md).

5.  Generate households using
    [`createFromMembers`](https://ready4-dev.github.io/replica/reference/createFromMembers.md).

Generated households are stored internally and can be exported using:

- [`agentToHousehold`](https://ready4-dev.github.io/replica/reference/agentToHousehold.md)

- [`householdsToDataFrame`](https://ready4-dev.github.io/replica/reference/householdsToDataFrame.md)

## Slots

- `hh_type`:

  Character string identifying the household type.

- `positions`:

  List of household-position definitions created via
  [`renew`](https://ready4-dev.github.io/replica/reference/renew.md).

- `position_identifiers`:

  Named list mapping position identifiers such as `"adult"` and
  `"child"` to entries in `positions`.

- `households`:

  List containing generated household records.

- `sampled_agents`:

  Character vector containing agents already assigned during household
  generation.

- `couple_gender_distribution`:

  Named numeric vector controlling gender composition of generated
  couples.

- `couple_age_distribution`:

  Named numeric vector controlling partner age-gap distributions.

- `parent_child_age_distribution`:

  Named numeric vector controlling parent-child age-gap distributions.

- `df_synth_pop`:

  Synthetic population used during household generation.

- `household_position_column`:

  Character string identifying the household-position column in the
  synthetic population.

## See also

[`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md),
[`ReplicaGrouper`](https://ready4-dev.github.io/replica/reference/ReplicaGrouper.md),
[`renew`](https://ready4-dev.github.io/replica/reference/renew.md),
[`createFromMembers`](https://ready4-dev.github.io/replica/reference/createFromMembers.md),
[`agentToHousehold`](https://ready4-dev.github.io/replica/reference/agentToHousehold.md),
[`householdsToDataFrame`](https://ready4-dev.github.io/replica/reference/householdsToDataFrame.md)

## Examples

``` r
if (FALSE) { # \dontrun{

hh <- ReplicaStructure(
  "Family"
)

hh <- renew(
  hh,
  household_position = "Parent",
  position_identifier = "adult",
  amount = 2,
  backup_position_identifiers = character()
)

hh <- renew(
  hh,
  household_position = "Child",
  position_identifier = "child",
  amount = 2,
  backup_position_identifiers = character()
)

} # }
```
