# Renew Replica Modules

Updates the configuration or state of a replica module.

## Usage

``` r
# S4 method for class 'ReplicaAdder'
renew(x, margins, margins_names, ...)

# S4 method for class 'ReplicaGrouper'
renew(x, household_type, ...)

# S4 method for class 'ReplicaStructure'
renew(
  x,
  what = c("positions", "state", "households"),
  household_position = NULL,
  position_identifier = NULL,
  amount = NULL,
  backup_position_identifiers = character(),
  df_synth_pop = NULL,
  household_position_column = NULL,
  ...
)
```

## Arguments

- x:

  A `ReplicaStructure`.

- margins:

  A list of marginal distributions.

- margins_names:

  A list of names corresponding to the

- ...:

  Additional arguments

- household_type:

  A `ReplicaStructure` object to be registered.

- what:

  Character string specifying which component of the structure should be
  updated.

  Options include:

  - `"positions"`

  - `"state"`

  - `"households"`

- household_position:

  Household position category.

- position_identifier:

  Internal household role identifier used during household formation.

- amount:

  Number of household members required.

- backup_position_identifiers:

  Alternative position identifiers that may be used if the primary
  position is unavailable.

- df_synth_pop:

  Synthetic population used for household generation.

- household_position_column:

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

Updates a `ReplicaAdder` by adding or replacing marginal distributions.

Marginal distributions provide additional information about known
population totals and can be used alongside contingency tables during
attribute assignment.

Any existing validation results are automatically cleared when margins
are modified.

## ReplicaGrouper Method

Registers a `ReplicaStructure` with a `ReplicaGrouper`.

Registered structures are subsequently used during household generation
when
[`manufacture()`](https://ready4-dev.github.io/replica/reference/manufacture.md)
is called on the grouper.

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

``` r
if (FALSE) { # \dontrun{

grouper <- renew(
  grouper,
  household_type = structure
)

} # }

if (FALSE) { # \dontrun{

structure <- renew(
  structure,
  what = "positions",
  household_position = "Parent",
  position_identifier = "adult",
  amount = 2
)

structure <- renew(
  structure,
  what = "state",
  df_synth_pop = population,
  household_position_column =
    "household_position"
)

structure <- renew(
  structure,
  what = "households"
)

} # }
```
