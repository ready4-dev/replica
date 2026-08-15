# Create Households from Household Members

Executes the household-construction workflow for a
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md).

## Usage

``` r
createFromMembers(object, mask, id_offset)

# S4 method for class 'HouseholdType'
createFromMembers(object, mask, id_offset)
```

## Arguments

- object:

  A
  [`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
  object.

- mask:

  Logical vector identifying agents eligible for household generation.

- id_offset:

  Integer household-ID offset.

## Value

A list containing:

- object:

  Updated
  [`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
  object.

- id_offset:

  Updated household identifier offset.

## Details

Depending on the household definition, this method may:

- Create single-adult households.

- Create couples.

- Group children.

- Match adults and children.

- Create household records.

Adult households are generated first.

If children are present, sibling groups are created and matched to the
adult groups.

The resulting households are stored in the `households` slot.

## See also

[`pairPartners`](https://ready4-dev.github.io/replica/reference/pairPartners.md),
[`groupChildren`](https://ready4-dev.github.io/replica/reference/groupChildren.md),
[`matchAdultsWithChildren`](https://ready4-dev.github.io/replica/reference/matchAdultsWithChildren.md)

## Examples

``` r
if (FALSE) { # \dontrun{

result <- createFromMembers(
  hh,
  mask = rep(TRUE, nrow(pop)),
  id_offset = 1
)

hh <- result$object

} # }
```
