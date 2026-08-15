# Create a Household Record and Assign a Household Identifier

Creates a new synthetic household and stores it within a `HouseholdType`
object.

## Usage

``` r
createHouseholdWithId(object, position, id_offset, agents)
```

## Arguments

- object:

  A `HouseholdType` object.

- position:

  Household-position definition returned by `getPositionForName`.

- id_offset:

  Integer offset used to generate a unique household identifier.

- agents:

  Character vector containing the agent IDs that belong to the
  household.

## Value

An updated `HouseholdType` object containing the newly-created
household.

## Details

Each household is assigned a unique household identifier of the form:


    SSH000001
    SSH000002
    SSH000003

The newly-created household stores:

- The complete list of household members.

- Members associated with the supplied household role.

This function is used internally during household generation by:

- `createSingles`

- [`pairPartners`](https://ready4-dev.github.io/replica/reference/pairPartners.md)

- [`matchAdultsWithChildren`](https://ready4-dev.github.io/replica/reference/matchAdultsWithChildren.md)

The household is stored in the `households` slot.

Each household contains:

- all:

  Character vector containing all household members.

- position_identifier:

  Members assigned under the role associated with the supplied position
  definition.

Household identifiers are generated using:


    sprintf("SSH

## See also

`getPositionForName`, `createSingles`,
[`pairPartners`](https://ready4-dev.github.io/replica/reference/pairPartners.md),
[`matchAdultsWithChildren`](https://ready4-dev.github.io/replica/reference/matchAdultsWithChildren.md),
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)

## Examples

``` r
if (FALSE) { # \dontrun{

hh <- HouseholdType(
  "CoupleOnly"
)

hh <- addMembers(
  hh,
  household_position = "Parent",
  position_identifier = "adult",
  amount = 2,
  backup_position_identifiers = character()
)

adult_position <- getPositionForName(
  hh,
  "adult"
)

hh <- createHouseholdWithId(
  hh,
  position = adult_position,
  id_offset = 1,
  agents = c(
    "A001",
    "A002"
  )
)

names(hh@households)

} # }
```
