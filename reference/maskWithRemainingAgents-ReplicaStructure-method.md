# Filter to Agents Not Yet Assigned

Applies an eligibility mask and removes agents already assigned during
synthetic household generation.

## Usage

``` r
# S4 method for class 'ReplicaStructure'
maskWithRemainingAgents(object, df, mask)
```

## Arguments

- object:

  A
  [`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)
  object.

- df:

  Candidate-agent data frame or data.table.

- mask:

  Logical vector identifying currently eligible agents.

## Value

A filtered data frame or data.table containing only agents that remain
available for assignment.

## Details

This function is a core integrity safeguard in replica and helps ensure
that each synthetic agent is assigned to at most one household.

Agents recorded in:


    object@sampled_agents

are excluded from the returned candidate set.

This function is used extensively by candidate-selection routines
throughout replica.

## See also

[`getRemainingAgentsInPosition`](https://ready4-dev.github.io/replica/reference/getRemainingAgentsInPosition.md),
[`findPrimaryPartner`](https://ready4-dev.github.io/replica/reference/findPrimaryPartner.md)

## Examples

``` r
if (FALSE) { # \dontrun{
remaining <- maskWithRemainingAgents(
  hh,
  hh@df_synth_pop,
  rep(TRUE, nrow(hh@df_synth_pop))
)
} # }
```
