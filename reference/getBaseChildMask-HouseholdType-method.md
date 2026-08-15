# Identify Agents Eligible for Child Roles

Creates a logical mask identifying agents whose household-position
values correspond to child household roles defined in a
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
object.

## Usage

``` r
# S4 method for class 'HouseholdType'
getBaseChildMask(object)
```

## Arguments

- object:

  A
  [`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
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

[`groupChildren`](https://ready4-dev.github.io/replica/reference/groupChildren.md),
[`matchAdultsWithChildren`](https://ready4-dev.github.io/replica/reference/matchAdultsWithChildren.md)

## Examples

``` r
if (FALSE) { # \dontrun{
child_mask <- getBaseChildMask(hh)
} # }
```
