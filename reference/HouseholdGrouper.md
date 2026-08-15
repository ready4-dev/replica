# Create a HouseholdGrouper Object

Creates a new `HouseholdGrouper` used to generate synthetic households
from an existing synthetic population.

## Usage

``` r
HouseholdGrouper(df_synth_pop, group_by, target_column = "household_position")
```

## Arguments

- df_synth_pop:

  A synthetic population stored as a data.frame or `data.table`.

  Each row should represent a single synthetic agent.

- group_by:

  Character vector specifying the variables used to partition the
  population during household generation.

  Typical examples include:

  - `"neighb_code"`

  - `"sa2_code"`

  - Other geographic identifiers

  Household generation is performed independently within each grouping
  combination.

- target_column:

  Character string identifying the column containing household-position
  classifications.

  Typical values include:

  - `"Parent"`

  - `"Child"`

  - `"SingleAdult"`

  Defaults to:


      "household_position"

## Value

A new `HouseholdGrouper` object.

## Details

The resulting object acts as the top-level coordinator of the
household-generation workflow and manages one or more
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
objects.

The constructor:

1.  Stores the synthetic population.

2.  Stores grouping information.

3.  Initializes the household-type list.

4.  Creates an empty `household_id` column if one does not already
    exist.

Household types are subsequently registered using `addHouseholdType`.

The resulting object is typically executed using `runHouseholdGrouper`.

## See also

[`HouseholdGrouper-class`](https://ready4-dev.github.io/replica/reference/HouseholdGrouper-class.md),
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md),
`addHouseholdType`, `runHouseholdGrouper`

## Examples

``` r
if (FALSE) { # \dontrun{

library(data.table)

pop <- data.table(
  agent_id = 1:100,
  neighb_code = sample(
    c("N1", "N2"),
    100,
    replace = TRUE
  )
)

hg <- HouseholdGrouper(
  df_synth_pop = pop,
  group_by = "neighb_code"
)

} # }
```
