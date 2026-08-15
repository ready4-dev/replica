# Register a HouseholdType with a HouseholdGrouper

Adds a
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
object to a
[`HouseholdGrouper`](https://ready4-dev.github.io/replica/reference/HouseholdGrouper.md).

## Usage

``` r
addHouseholdType(object, household_type)

# S4 method for class 'HouseholdGrouper'
addHouseholdType(object, household_type)
```

## Arguments

- object:

  A
  [`HouseholdGrouper`](https://ready4-dev.github.io/replica/reference/HouseholdGrouper.md)
  object.

- household_type:

  A
  [`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
  object.

## Value

An updated
[`HouseholdGrouper`](https://ready4-dev.github.io/replica/reference/HouseholdGrouper.md)
object.

## Details

Registered household types define the household structures that may be
generated during household construction.

Multiple household types can be added to the same
[`HouseholdGrouper`](https://ready4-dev.github.io/replica/reference/HouseholdGrouper.md),
allowing the synthetic population to contain a mixture of household
structures.

Household types are stored internally in the `household_types` slot.

During execution of:


    run(hg)

each registered household type is processed in turn.

Typical workflow:

1.  Create a
    [`HouseholdGrouper`](https://ready4-dev.github.io/replica/reference/HouseholdGrouper.md).

2.  Create one or more
    [`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md)
    objects.

3.  Register household types using `addHouseholdType()`.

4.  Execute household generation using
    [`run`](https://ready4-dev.github.io/replica/reference/run.md).

Household types are applied in the order in which they are registered.

## See also

[`HouseholdGrouper`](https://ready4-dev.github.io/replica/reference/HouseholdGrouper.md),
[`HouseholdType`](https://ready4-dev.github.io/replica/reference/HouseholdType.md),
[`addMembers`](https://ready4-dev.github.io/replica/reference/addMembers.md),
[`run`](https://ready4-dev.github.io/replica/reference/run.md)

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

hg <- addHouseholdType(
  hg,
  hh
)

result <- run(hg)

} # }
```
