# Convert Synthetic Households to a Data Frame

Creates a household-level summary table from the household records
stored within a
[`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)
object.

## Usage

``` r
householdsToDataFrame(object)

# S4 method for class 'ReplicaStructure'
householdsToDataFrame(object)
```

## Arguments

- object:

  A
  [`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)
  object.

## Value

A data frame containing one row per household.

The returned table contains:

- household_id:

  Unique household identifier.

- neighb_code:

  Neighbourhood identifier associated with the household.

- hh_type:

  Household type.

- hh_size:

  Number of agents assigned to the household.

## Details

Each row in the returned data frame represents a single synthetic
household and contains summary information such as household identifier,
household type and household size.

This method is typically called after household generation and household
assignment have been completed.

Household size is calculated as:


    length(household$all)

where `household$all` contains the identifiers of all household members.

The neighbourhood code is obtained from the first household member and
is assumed to be common to all members of the household.

If no households have been generated, an empty data frame with the
expected columns is returned.

This method is typically used after:

1.  Household generation.

2.  [`agentToHousehold`](https://ready4-dev.github.io/replica/reference/agentToHousehold.md).

3.  Household validation.

## See also

[`agentToHousehold`](https://ready4-dev.github.io/replica/reference/agentToHousehold.md),
[`create_household_with_id`](https://ready4-dev.github.io/replica/reference/create_household_with_id.md),
[`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)

## Examples

``` r
if (FALSE) { # \dontrun{

households <- householdsToDataFrame(
  hh
)

head(households)

} # }
```
