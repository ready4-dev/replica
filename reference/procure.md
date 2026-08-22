# Procure Components of Replica Modules

Retrieves components stored within a replica module.

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

`procure()` provides convenient access to information stored within
replica-module slots.

It is intended as a user-friendly alternative to direct slot access and
helps support a consistent ready4-style workflow.

Components are retrieved by supplying a slot name.

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

For a `ReplicaGrouper`, `procure()` can be used to retrieve stored
grouping information and synthetic population data.

## ReplicaStructure Method

Retrieves components stored within a `ReplicaStructure`.

For a `ReplicaStructure`, `procure()` can be used to retrieve stored
information on:

- household definitions;

- household positions;

- household assignments; and

- assignment state.

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
  adder,
  slot = "validation_results"
)

} # }

if (FALSE) { # \dontrun{

procure(
  grouper,
  slot = "population"
)

} # }

if (FALSE) { # \dontrun{

procure(
  structure,
  slot = "households"
)

} # }

if (FALSE) { # \dontrun{

procure(
  adder,
  slot = "validation_results"
)

procure(
  structure,
  slot = "households"
)

procure(
  grouper,
  slot = "population"
)

} # }
```
