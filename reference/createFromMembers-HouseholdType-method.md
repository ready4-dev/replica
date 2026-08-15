# Create Households from Household Members

Executes the household-construction workflow for a single
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md).

## Usage

``` r
# S4 method for class 'HouseholdType'
createFromMembers(object, mask, id_offset)
```

## Arguments

- object:

  A
  [`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
  object.

- mask:

  Logical vector identifying agents eligible for household construction.

- id_offset:

  Integer household identifier offset used to generate unique household
  IDs.

## Value

A list containing:

- object:

  Updated
  [`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
  object containing newly-created household records.

- id_offset:

  Updated household identifier offset.

## Details

Depending on the household structure, this method:

- Creates single-adult households using `createSingles`.

- Creates couples using
  [`pairPartners`](https://ready4-dev.github.io/replica/reference/pairPartners.md).

- Groups children using
  [`groupChildren`](https://ready4-dev.github.io/replica/reference/groupChildren.md).

- Matches adults and children using
  [`matchAdultsWithChildren`](https://ready4-dev.github.io/replica/reference/matchAdultsWithChildren.md).

- Creates household records and household identifiers.

This method forms the core execution step of the
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
workflow and is typically invoked by `runHouseholdGrouper`.

Household creation proceeds in several stages.

First, adult groups are created:

- If the household requires two adults, couples are created using
  [`pairPartners`](https://ready4-dev.github.io/replica/reference/pairPartners.md).

- Otherwise, single-adult households are created using `createSingles`.

If a child role has been defined:

- Children are grouped into sibling sets using
  [`groupChildren`](https://ready4-dev.github.io/replica/reference/groupChildren.md).

- Adult groups are matched to child groups using
  [`matchAdultsWithChildren`](https://ready4-dev.github.io/replica/reference/matchAdultsWithChildren.md).

If no child role has been defined, adult households are created
directly.

Newly-created households are stored in the `households` slot of the
returned object.

## See also

`createSingles`,
[`pairPartners`](https://ready4-dev.github.io/replica/reference/pairPartners.md),
[`groupChildren`](https://ready4-dev.github.io/replica/reference/groupChildren.md),
[`matchAdultsWithChildren`](https://ready4-dev.github.io/replica/reference/matchAdultsWithChildren.md),
[`createHouseholdWithId`](https://ready4-dev.github.io/replica/reference/createHouseholdWithId.md),
`runHouseholdGrouper`,
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)

## Examples

``` r
if (FALSE) { # \dontrun{

result <- createFromMembers(
  hh,
  mask = rep(
    TRUE,
    nrow(pop)
  ),
  id_offset = 1
)

hh <- result$object

} # }
```
