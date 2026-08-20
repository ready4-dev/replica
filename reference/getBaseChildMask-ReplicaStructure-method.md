# Identify Agents Eligible for Child Roles

Creates a logical mask identifying agents whose household-position
values correspond to child household roles defined in a
[`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)
object.

## Usage

``` r
# S4 method for class 'ReplicaStructure'
getBaseChildMask(object)
```

## Arguments

- object:

  A
  [`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)
  object.

## Value

A logical vector indicating which agents belong to configured child
household positions.

## Details

This utility is used by the household-generation workflow in replica
when constructing sibling groups and family households.

Child positions are determined from the household-position definition
registered under:


    position_identifier = "child"

## See also

[`group_children`](https://ready4-dev.github.io/replica/reference/group_children.md),
[`matchAdultsWithChildren`](https://ready4-dev.github.io/replica/reference/matchAdultsWithChildren.md)

## Examples

``` r
if (FALSE) { # \dontrun{
child_mask <- getBaseChildMask(hh)
} # }
```
