# Find a Primary Household Partner

Selects the primary adult candidate for household formation.

## Usage

``` r
findPrimaryPartner(
  object,
  mask,
  primary_position_value,
  backup_position_values,
  gender = NULL
)
```

## Arguments

- object:

  A `ReplicaStructure` object.

- mask:

  Logical vector identifying agents eligible for selection.

- primary_position_value:

  Character vector containing the household-position values that define
  the primary candidate pool.

- backup_position_values:

  Character vector containing alternative household-position categories
  that may be used if a suitable candidate cannot be found in the
  primary pool.

- gender:

  Optional character string specifying the required gender of the
  candidate.

## Value

A single-row data frame or data.table representing the selected
candidate.

## Details

This function is used during both single-adult household generation and
couple formation.

Candidate agents are selected from the synthetic population using the
specified household-position categories and an eligibility mask.

Optionally, candidate selection can be restricted to a specific gender.

The function:

1.  Retrieves all remaining eligible agents in the specified position
    categories.

2.  Optionally filters candidates by gender.

3.  Excludes agents already recorded in `sampled_agents`.

4.  Returns the highest-priority candidate.

If no suitable candidate can be found, an error is raised.

The current implementation returns the first available candidate after
filtering. More sophisticated behaviour may be applied when
backup-position replacement logic is enabled.

## See also

[`findSecondaryPartner`](https://ready4-dev.github.io/replica/reference/findSecondaryPartner.md),
[`getRemainingAgentsInPosition`](https://ready4-dev.github.io/replica/reference/getRemainingAgentsInPosition.md)

## Examples

``` r
if (FALSE) { # \dontrun{

candidate <- findPrimaryPartner(
  hh,
  mask = rep(
    TRUE,
    nrow(pop)
  ),
  primary_position_value =
    "SingleAdult",
  backup_position_values =
    character()
)

} # }
```
