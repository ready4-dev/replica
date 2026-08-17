# Group Children into Sibling Sets

Creates sibling groups from eligible children within a synthetic
population.

## Usage

``` r
group_children(object, mask, child_position)
```

## Arguments

- object:

  A `HouseholdType` object.

- mask:

  Logical vector identifying agents eligible for child grouping.

- child_position:

  Position definition returned by
  [`getPositionForName`](https://ready4-dev.github.io/replica/reference/getPositionForName.md)
  for the `"child"` role.

## Value

A list of sibling groups.

Each sibling group is represented as a character vector of agent
identifiers.

The updated `HouseholdType` object is attached as:


    attr(result, "object")

## Details

Children are grouped according to the child-position specification
stored in a `HouseholdType` object.

The algorithm:

- Identifies all eligible children.

- Randomises the candidate pool to avoid systematic ordering effects.

- Selects an initial child.

- Iteratively finds the most age-similar sibling using
  findSiblingFromPool.

- Creates sibling groups of the required size.

- Marks assigned children as unavailable for future household
  generation.

This method is typically called indirectly through
[`createFromMembers`](https://ready4-dev.github.io/replica/reference/createFromMembers.md)
during household generation.

The number of children per sibling group is determined by the `amount`
element of the child-position definition.

Children are assigned exactly once. Assigned children are recorded in
`sampled_agents` and removed from the pool of eligible children.

Age similarity between children is evaluated using
score_sibling_age_suitability.

## See also

[`matchAdultsWithChildren`](https://ready4-dev.github.io/replica/reference/matchAdultsWithChildren.md),
[`createFromMembers`](https://ready4-dev.github.io/replica/reference/createFromMembers.md),
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)

## Examples

``` r
if (FALSE) { # \dontrun{

child_position <- getPositionForName(
  hh,
  "child"
)

groups <- group_children(
  hh,
  mask = rep(
    TRUE,
    nrow(pop)
  ),
  child_position = child_position
)

groups

} # }
```
