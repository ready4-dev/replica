# Procure Components of Replica Modules

Retrieves information stored within a replica module.

## Usage

``` r
# S4 method for class 'ReplicaAdder'
procure(x, slot = character(0), ...)

# S4 method for class 'ReplicaGrouper'
procure(x, slot = character(0), ...)

# S4 method for class 'ReplicaStructure'
procure(x, slot = character(0), ...)
```

## Arguments

- x:

  A replica module.

- slot:

  Character string specifying the slot to retrieve.

- ...:

  Additional arguments passed to the method.

## Value

The contents of the requested slot.

The contents of the requested slot.

The contents of the requested slot.

The contents of the requested slot.

## Details

The behaviour of `procure()` depends on the class of the supplied
object.

Methods are currently available for:

- `ReplicaAdder`

- `ReplicaStructure`

- `ReplicaGrouper`

`procure()` is the primary method used to retrieve information from
replica modules.

Components are retrieved by supplying the name of a module slot.

It provides a consistent alternative to direct slot access and supports
a ready4-style workflow for working with replica modules.

Together with
[`renew`](https://ready4-dev.github.io/replica/reference/renew.md),
`procure()` forms the primary interface for accessing and updating
replica-module contents.

## ReplicaAdder Method

Retrieves components stored within a `ReplicaAdder`.

Typical uses include retrieving:

- synthetic populations;

- contingency tables; and

- validation results.

For a `ReplicaAdder`, `procure()` can be used to retrieve stored
components such as:

- synthetic populations;

- contingency tables;

- marginal distributions; and

- validation results.

## ReplicaGrouper Method

Retrieves components stored within a `ReplicaGrouper`.

For a `ReplicaGrouper`, `procure()` can be used to retrieve:

- synthetic populations;

- grouping definitions;

- registered structures; and

- household-generation settings.

## ReplicaStructure Method

Retrieves components stored within a `ReplicaStructure`.

For a `ReplicaStructure`, `procure()` can be used to retrieve stored
information on:

- household definitions;

- household positions;

- household assignments; and

- household-generation state.

## See also

[`ReplicaAdder`](https://ready4-dev.github.io/replica/reference/ReplicaAdder.md)

[`ReplicaGrouper`](https://ready4-dev.github.io/replica/reference/ReplicaGrouper.md)

[`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md)

[`renew`](https://ready4-dev.github.io/replica/reference/renew.md),
[`enhance`](https://ready4-dev.github.io/replica/reference/enhance.md),
[`ratify`](https://ready4-dev.github.io/replica/reference/ratify.md),
[`manufacture`](https://ready4-dev.github.io/replica/reference/manufacture.md)

## Examples

``` r
if (FALSE) { # \dontrun{

procure(
  ADDER,
  slot = "validation_results"
)

} # }

if (FALSE) { # \dontrun{

procure(
  GROUPER,
  slot = "population"
)

} # }

if (FALSE) { # \dontrun{

procure(
  STRUCTURE,
  slot = "households"
)

} # }

if (FALSE) { # \dontrun{

procure(
  ADDER,
  slot = "validation_results"
)

procure(
  STRUCTURE,
  slot = "households"
)

procure(
  GROUPER,
  slot = "population"
)

} # }
```
