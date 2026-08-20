# Renew replica modules

Updates the configuration of a replica module.

## Usage

``` r
# S4 method for class 'ReplicaAdder'
renew(x, margins, margins_names, ...)

# S4 method for class 'ReplicaGrouper'
renew(x, household_type, ...)

# S4 method for class 'ReplicaStructure'
renew(
  x,
  household_position,
  position_identifier,
  amount,
  backup_position_identifiers,
  ...
)
```

## Arguments

- x:

  A `ReplicaStructure`.

- margins:

  A list of marginal distributions.

- margins_names:

  A list of names corresponding to the supplied margins.

- ...:

  Additional arguments passed to the method.

- household_type:

  A `ReplicaStructure` object to be registered with the grouper.

- household_position:

  Household position category.

- position_identifier:

  Internal household role identifier used during household formation.

- amount:

  Number of household members required.

- backup_position_identifiers:

  Alternative position identifiers that may be used when primary
  positions are unavailable.

## Value

An updated `ReplicaAdder`.

An updated `ReplicaGrouper`.

An updated `ReplicaStructure`.

## Details

The behaviour of `renew()` depends on the class of the supplied object.

Methods are currently available for:

- `ReplicaAdder`

- `ReplicaStructure`

## ReplicaAdder Method

Updates a `ReplicaAdder` by adding or replacing marginal distributions.

Marginal distributions provide additional information about known
population totals and can be used alongside contingency tables during
attribute assignment.

Any existing validation results are automatically cleared when margins
are modified.

## ReplicaGrouper Method

For a `ReplicaGrouper`, `renew()` registers a `ReplicaStructure` that
can subsequently be used during household generation.

## ReplicaStructure Method

For a `ReplicaStructure`, `renew()` defines or updates household-member
requirements.

Household positions specify which synthetic agents are eligible for a
role, while position identifiers define the household roles used
internally by the matching algorithm.

## Examples

``` r
if (FALSE) { # \dontrun{

gender_margin <- data.frame(
  gender = c(
    "Male",
    "Female"
  ),
  count = c(
    100,
    120
  )
)

adder <- renew(
  adder,
  margins = list(
    gender_margin
  ),
  margins_names = list(
    "gender"
  )
)

} # }
```
