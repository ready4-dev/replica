# Exchange Household Positions Between Agents

Swaps household-position classifications between two agents in a
synthetic population.

## Usage

``` r
switchHouseholdPositions(object, agent_1, agent_2)
```

## Arguments

- object:

  A
  [`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)
  object.

- agent_1:

  Identifier of the first agent.

- agent_2:

  Identifier of the second agent.

## Value

An updated
[`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)
object.

## Details

This function supports fallback partner-matching logic in replica when
suitable candidates are unavailable within the preferred
household-position pool.

The function:

1.  Retrieves both agents.

2.  Exchanges their household-position values.

3.  Updates the stored synthetic population.

Both agents must belong to the same neighbourhood.

## See also

[`findOppositeGenderReplacementForCandidate`](https://ready4-dev.github.io/replica/reference/findOppositeGenderReplacementForCandidate.md)

## Examples

``` r
if (FALSE) { # \dontrun{
STRUCTURE <- switchHouseholdPositions(
  STRUCTURE,
  "A001",
  "A002"
)
} # }
```
