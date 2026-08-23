# Identify Agents Eligible for Adult Roles

Creates a logical mask identifying agents whose household-position
values correspond to adult household roles defined within a
[`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)
object.

## Usage

``` r
# S4 method for class 'ReplicaStructure'
getBaseAdultMask(object, strict = TRUE)
```

## Arguments

- object:

  A
  [`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)
  object.

- strict:

  Logical value controlling behaviour when no adult position has been
  defined.

  If:

  `TRUE`

  :   An error is raised.

  `FALSE`

  :   A logical vector of `FALSE` values is returned.

## Value

A logical vector indicating which agents belong to configured adult
household positions.

## Details

This utility is used throughout the household-generation workflow in
replica when constructing:

- Single-adult households.

- Couple households.

- Family households.

Adult positions are determined from the household-position definition
registered under:


    position_identifier = "adult"

## Examples

``` r
if (FALSE) { # \dontrun{
adult_mask <- getBaseAdultMask(STRUCTURE)
} # }
```
