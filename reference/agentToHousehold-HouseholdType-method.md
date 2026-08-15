# Assign Household Identifiers to Agents

Writes household identifiers from the household structures stored within
a `HouseholdType` object back into the associated synthetic population.

## Usage

``` r
# S4 method for class 'HouseholdType'
agentToHousehold(object)
```

## Arguments

- object:

  A `HouseholdType` object.

## Value

An updated `HouseholdType` object containing household identifiers in
the synthetic population stored in the `df_synth_pop` slot.

## Details

Each agent belonging to a generated household receives the corresponding
household identifier in the `household_id` column of the synthetic
population.

This method is typically called after household generation and before
household-level summary tables are created using
`householdsToDataFrame`.

Household membership is obtained from the `households` slot.

For each household:

- Agents listed in `household$all` are identified.

- The household identifier is written to the `household_id` column of
  the synthetic population.

After this method executes, each assigned agent can be linked directly
to a synthetic household using:


    object@df_synth_pop$household_id

## See also

`householdsToDataFrame`,
[`createHouseholdWithId`](https://ready4-dev.github.io/replica/reference/createHouseholdWithId.md),
`checkIntegrity`,
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)

## Examples

``` r
if (FALSE) { # \dontrun{

hh <- HouseholdType(
  "CoupleOnly"
)

hh@households <- list(

  SSH000001 = list(
    all = c(
      "A001",
      "A002"
    )
  )

)

hh <- agentToHousehold(
  hh
)

head(
  hh@df_synth_pop
)

} # }
```
