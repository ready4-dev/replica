# Renew Replica Modules

Updates the configuration or state of a replica module.

## Usage

``` r
# S4 method for class 'ReplicaAdder'
renew(
  x,
  margins = list(),
  margins_names = list(),
  what = c("slot", "margins"),
  ...
)

# S4 method for class 'ReplicaGrouper'
renew(x, structure = NULL, what = c("slot", "structure"), ...)

# S4 method for class 'ReplicaStructure'
renew(
  x,
  what = c("positions", "state", "households"),
  household_position = NULL,
  position_identifier = NULL,
  amount = NULL,
  backup_position_identifiers = character(),
  population = NULL,
  position_column = NULL,
  ...
)
```

## Arguments

- x:

  A `ReplicaStructure`.

- margins:

  A list of marginal distributions.

- margins_names:

  A list containing names corresponding to supplied marginal
  distributions.

- what:

  Character string specifying which component of the structure should be
  updated.

  Options include:

  - `"positions"`

  - `"state"`

  - `"households"`

- ...:

  Additional arguments

- structure:

  A `ReplicaStructure` object to be registered when
  `what = "structure"`.

- household_position:

  Household position category.

- position_identifier:

  Internal household role identifier used during household formation.

- amount:

  Number of household members required.

- backup_position_identifiers:

  Alternative position identifiers that may be used if the primary
  position is unavailable.

- population:

  Synthetic population used for household generation.

- position_column:

  Character string identifying the column containing household-position
  information.

## Value

An updated `ReplicaAdder`.

An updated `ReplicaGrouper`.

An updated `ReplicaStructure`.

## Details

The behaviour of `renew()` depends on the class of the supplied object.

Methods are currently available for:

- `ReplicaAdder`

- `ReplicaStructure`

- `ReplicaGrouper`

`renew()` is the primary method used to update replica modules while
preserving their underlying class and structure.

Depending on the supplied module, `renew()` can:

- add marginal distributions to a `ReplicaAdder`;

- define household-member roles in a `ReplicaStructure`;

- update internal household-generation state;

- transfer household assignments to synthetic populations; and

- register household structures with a `ReplicaGrouper`.

## ReplicaAdder Method

Updates a `ReplicaAdder`.

By default, `renew()` updates one or more slots of a `ReplicaAdder`
using named arguments supplied via `...`.

For example:


    adder <- renew(
      adder,
      population = population
    )

Slot names must correspond to slots defined for the `ReplicaAdder`
class.

Alternatively, setting:


    what = "margins"

updates the marginal distributions used during attribute assignment.

Marginal distributions provide additional information about known
population totals and can be used alongside contingency tables during
attribute assignment.

Any existing validation results are automatically cleared when margins
are modified.

## ReplicaGrouper Method

Updates a `ReplicaGrouper`.

By default, `renew()` updates one or more slots of a `ReplicaGrouper`
using named arguments supplied via `...`.

For example:


    grouper <- renew(
      grouper,
      population = population,
      what = "structure"
    )

Slot names must correspond to slots defined for the `ReplicaGrouper`
class.

Alternatively, setting:


    what = "structure"

registers a `ReplicaStructure` with the grouper.

Registered structures are subsequently used during household generation
when
[`manufacture()`](https://ready4-dev.github.io/replica/reference/manufacture.md)
is called.

## ReplicaStructure Method

Updates the configuration or state of a `ReplicaStructure`.

The operation performed is determined by the `what` argument.

Supported options are:

- `"positions"`:

  Define or update household-member requirements.

  Household positions describe which synthetic agents are eligible for
  household roles and how many members are required.

- `"state"`:

  Update the internal population state used during household generation.

  This operation stores the synthetic population and household-position
  column used by subsequent household-generation methods.

- `"households"`:

  Transfer generated household assignments into the synthetic population
  stored by the structure.

## Examples
