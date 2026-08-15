# Run Household Generation

Executes the complete household-generation workflow and assigns
synthetic households to agents in a synthetic population.

## Usage

``` r
# S4 method for class 'ConditionalAttributeAdder'
run(object)
```

## Arguments

- object:

  A `HouseholdGrouper` object.

## Value

A list containing:

- synthetic_population:

  Synthetic population with household identifiers assigned.

- synthetic_households:

  Household-level summary table.

- object:

  Updated `HouseholdGrouper` object.

## Details

The method coordinates one or more
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
objects and generates household structures according to their
configuration.

Household generation may include:

- Single-adult household creation.

- Couple formation.

- Child grouping.

- Parent-child matching.

- Household identifier assignment.

The workflow consists of the following stages:

1.  Update the state of each
    [`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md).

2.  Partition the synthetic population according to the specified
    grouping variables.

3.  Create households within each group using `createFromMembers`.

4.  Validate household assignments using `checkIntegrity`.

5.  Write household identifiers back to the synthetic population using
    `agentToHousehold`.

6.  Generate a household summary table using `householdsToDataFrame`.

The resulting synthetic population and household table are returned
together to facilitate subsequent analysis and validation.

## See also

[`HouseholdGrouper`](https://ready4-dev.github.io/replica/reference/HouseholdGrouper.md),
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md),
`createFromMembers`, `checkIntegrity`, `agentToHousehold`,
`householdsToDataFrame`

## Examples

``` r
if (FALSE) { # \dontrun{

hg <- HouseholdGrouper(
  df_synth_pop = pop,
  group_by = "neighb_code"
)

hg <- addHouseholdType(
  hg,
  hh
)

result <- runHouseholdGrouper(
  hg
)

synthetic_population <-
  result$synthetic_population

synthetic_households <-
  result$synthetic_households

} # }
```
