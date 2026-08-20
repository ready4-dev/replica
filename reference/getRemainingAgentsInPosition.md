# Retrieve Eligible Unassigned Agents in Household Positions

Returns agents occupying one or more specified household positions that
have not yet been assigned during household generation.

## Usage

``` r
getRemainingAgentsInPosition(object, position, mask = NULL)
```

## Arguments

- object:

  A
  [`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)
  object.

- position:

  Character string or character vector identifying eligible
  household-position values.

  Examples include:

  - `"Parent"`

  - `"Child"`

  - `"SingleAdult"`

- mask:

  Optional logical vector identifying agents that are currently eligible
  for selection.

  If omitted, all agents occupying the specified position categories are
  considered.

## Value

A data frame or data.table containing the remaining eligible agents.

## Details

This function is a core candidate-selection utility used throughout the
household-generation workflow.

Agents are retained only if:

- Their household-position value matches one of the requested positions.

- They satisfy the supplied eligibility mask.

- They do not appear in the `sampled_agents` slot.

The function performs three filtering steps:

1.  Identify agents whose household-position values belong to the
    specified position categories.

2.  Apply the supplied logical mask.

3.  Remove agents already assigned and recorded in `sampled_agents`.

This function is used by:

- [`findPrimaryPartner`](https://ready4-dev.github.io/replica/reference/findPrimaryPartner.md)

- [`findSecondaryPartner`](https://ready4-dev.github.io/replica/reference/findSecondaryPartner.md)

- [`pair_partners`](https://ready4-dev.github.io/replica/reference/pair_partners.md)

and provides the candidate pools used by household-matching algorithms.

## See also

[`findPrimaryPartner`](https://ready4-dev.github.io/replica/reference/findPrimaryPartner.md),
[`findSecondaryPartner`](https://ready4-dev.github.io/replica/reference/findSecondaryPartner.md),
[`pair_partners`](https://ready4-dev.github.io/replica/reference/pair_partners.md),
[`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)

## Examples

``` r
if (FALSE) { # \dontrun{

candidates <- getRemainingAgentsInPosition(
  hh,
  "Parent"
)

head(candidates)

} # }

if (FALSE) { # \dontrun{

candidates <- getRemainingAgentsInPosition(
  hh,
  c(
    "Parent",
    "SingleAdult"
  )
)

} # }

if (FALSE) { # \dontrun{

candidates <- getRemainingAgentsInPosition(
  hh,
  "Parent",
  mask = age > 30
)

} # }
```
