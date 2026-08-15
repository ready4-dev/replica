# Run Household Generation

Executes the complete household-generation workflow for a synthetic
population.

## Usage

``` r
# S4 method for class 'HouseholdGrouper'
runHouseholdGrouper(object)
```

## Arguments

- object:

  A
  [`HouseholdGrouper`](https://ready4-dev.github.io/replica/reference/HouseholdGrouper.md)
  object.

## Value

A list containing:

- synthetic_population:

  Synthetic population with household identifiers assigned.

- synthetic_households:

  Household-level summary table.

- object:

  Updated
  [`HouseholdGrouper`](https://ready4-dev.github.io/replica/reference/HouseholdGrouper.md)
  object.

## Details

This method coordinates one or more
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
objects and generates synthetic households according to their configured
structures, partner-matching distributions and parent-child matching
distributions.

Household generation may include:

- Single-adult household creation.

- Couple formation.

- Child grouping.

- Parent-child matching.

- Household identifier assignment.

The workflow proceeds through the following stages:

1.  Update each registered
    [`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
    with the current synthetic population.

2.  Partition the synthetic population according to the grouping
    variables specified by `group_by`.

3.  Generate households independently within each grouping combination
    using `createFromMembers`.

4.  Validate household assignments using `checkIntegrity`.

5.  Assign household identifiers to agents using `agentToHousehold`.

6.  Construct a household-level summary table using
    `householdsToDataFrame`.

Household identifiers are generated sequentially using the current
household offset.

The returned synthetic population and household table are suitable for
downstream analysis, simulation and validation.

## See also

[`HouseholdGrouper`](https://ready4-dev.github.io/replica/reference/HouseholdGrouper.md),
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md),
`addHouseholdType`, `createFromMembers`, `agentToHousehold`,
`householdsToDataFrame`, `checkIntegrity`

## Examples

``` r
if (FALSE) { # \dontrun{

hg <- HouseholdGrouper(
  df_synth_pop = pop,
  group_by = "neighb_code"
)

hh <- HouseholdType(
  "CoupleHousehold"
)

hh <- addMembers(
  hh,
  household_position = "Parent",
  position_identifier = "adult",
  amount = 2,
  backup_position_identifiers = character()
)

hh@couple_gender_distribution <- c(
  "Male|Female" = 1
)

hh@couple_age_distribution <- c(
  "-5-5" = 1
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
