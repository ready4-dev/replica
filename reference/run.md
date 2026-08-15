# Execute a replica Workflow

Executes a workflow represented by a supported replica object.

## Usage

``` r
run(object)

# S4 method for class 'ConditionalAttributeAdder'
run(object)

# S4 method for class 'HouseholdGrouper'
run(object)
```

## Arguments

- object:

  A supported replica workflow object.

## Value

Depends on the class of `object`.

- `ConditionalAttributeAdder`:

  Returns an updated
  [`ConditionalAttributeAdder`](https://ready4-dev.github.io/replica/reference/ConditionalAttributeAdder.md)
  object.

- `HouseholdGrouper`:

  Returns a list containing:

  - Synthetic population.

  - Synthetic household table.

  - Updated HouseholdGrouper object.

## Details

The specific behaviour depends on the class of the supplied object.

Current implementations include:

- [`ConditionalAttributeAdder`](https://ready4-dev.github.io/replica/reference/ConditionalAttributeAdder.md)

- [`HouseholdGrouper`](https://ready4-dev.github.io/replica/reference/HouseholdGrouper.md)

The `run()` generic provides a unified execution interface for major
replica workflows.

Method dispatch determines the specific implementation used.

## ConditionalAttributeAdder Method

Executes the conditional attribute-assignment workflow.

Typical usage:


    adder <- ConditionalAttributeAdder(
      synth_pop = population,
      contingency = contingency,
      target_attribute = "education",
      group_by = c(
        "age_group",
        "gender"
      )
    )

    adder <- run(adder)

    result <- adder@synth_pop

The method:

1.  Completes missing contingency groups.

2.  Calculates conditional fractions.

3.  Converts fractions into agent allocations.

4.  Assigns target-attribute values.

5.  Verifies the resulting synthetic population.

## HouseholdGrouper Method

Executes the complete household-generation workflow.

Typical usage:


    hg <- HouseholdGrouper(
      df_synth_pop = pop,
      group_by = "neighb_code"
    )

    hg <- addHouseholdType(
      hg,
      hh
    )

    result <- run(hg)

The method:

1.  Updates registered HouseholdType objects.

2.  Creates adult households.

3.  Groups children.

4.  Creates family households.

5.  Assigns household identifiers.

6.  Produces a household summary table.

## See also

[`ConditionalAttributeAdder`](https://ready4-dev.github.io/replica/reference/ConditionalAttributeAdder.md),
[`HouseholdGrouper`](https://ready4-dev.github.io/replica/reference/HouseholdGrouper.md)

## Examples

``` r
if (FALSE) { # \dontrun{

# -----------------------------------
# ConditionalAttributeAdder workflow
# -----------------------------------

adder <- ConditionalAttributeAdder(
  synth_pop = population,
  contingency = contingency,
  target_attribute = "education",
  group_by = c(
    "age_group",
    "gender"
  ),
  missing_group_strategy = "borrow"
)

adder <- run(adder)

result <- adder@synth_pop

table(result$education)


# -----------------------------------
# HouseholdGrouper workflow
# -----------------------------------

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

result <- run(
  hg
)

synthetic_population <-
  result$synthetic_population

synthetic_households <-
  result$synthetic_households

} # }
```
