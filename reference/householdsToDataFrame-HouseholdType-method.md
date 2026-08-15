# Convert Household Structures to a Data Frame

Constructs a household-level data frame from the households stored
within a `HouseholdType` object.

## Usage

``` r
# S4 method for class 'HouseholdType'
householdsToDataFrame(object)
```

## Arguments

- object:

  A `HouseholdType` object.

## Value

A data frame containing one row per synthetic household.

## Details

Each row of the returned data frame represents a single synthetic
household and contains:

- Household identifier.

- Neighbourhood code.

- Household type.

- Household size.

This method is typically called after household generation has completed
and household identifiers have been assigned to agents via
`agentToHousehold`.

Household size is calculated as the number of agents listed in the
household's `all` member vector.

The neighbourhood code is obtained from the first agent in each
household and is assumed to be common to all household members.

If no households have been created, an empty data frame with the
expected columns is returned.

Returned columns include:

- household_id:

  Unique household identifier.

- neighb_code:

  Neighbourhood code associated with the household.

- hh_type:

  Household type.

- hh_size:

  Number of agents assigned to the household.

## See also

`agentToHousehold`,
[`createHouseholdWithId`](https://ready4-dev.github.io/replica/reference/createHouseholdWithId.md),
`runHouseholdGrouper`,
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)

## Examples

``` r
if (FALSE) { # \dontrun{

households <- householdsToDataFrame(
  hh
)

head(households)

} # }
```
