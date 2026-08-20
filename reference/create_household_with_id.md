# Create a Household Record and Assign a Household Identifier

Creates a new synthetic household and stores it within a
`ReplicaStructure` object.

## Usage

``` r
create_household_with_id(object, position, id_offset, agents)
```

## Arguments

- object:

  A `ReplicaStructure` object.

- position:

  Household-position definition returned by
  [`getPositionForName`](https://ready4-dev.github.io/replica/reference/getPositionForName.md).

- id_offset:

  Integer offset used to generate a unique household identifier.

- agents:

  Character vector containing the agent IDs that belong to the
  household.

## Value

An updated `ReplicaStructure` object containing the newly-created
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

- [`pair_partners`](https://ready4-dev.github.io/replica/reference/pair_partners.md)

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

[`getPositionForName`](https://ready4-dev.github.io/replica/reference/getPositionForName.md),
[`pair_partners`](https://ready4-dev.github.io/replica/reference/pair_partners.md),
[`matchAdultsWithChildren`](https://ready4-dev.github.io/replica/reference/matchAdultsWithChildren.md),
[`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)

## Examples

``` r
if (FALSE) { # \dontrun{

hh <- ReplicaStructure(
  "CoupleOnly"
)

hh <- renew(
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

hh <- create_household_with_id(
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
