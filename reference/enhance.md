# Enhance Replica Modules

Enhances a replica module by updating or enriching the data managed by
that module.

## Usage

``` r
# S4 method for class 'ReplicaAdder'
enhance(x = "ReplicaAdder", ...)
```

## Arguments

- x:

  A `ReplicaAdder`.

- ...:

  Additional arguments passed to the method.

## Value

An updated `ReplicaAdder`.

## Details

The behaviour of `enhance()` depends on the class of the supplied
object.

Methods are currently available for:

- `ReplicaAdder`

In the current implementation, `enhance()` is used to execute
attribute-assignment workflows.

For a `ReplicaAdder`, the method assigns values of a target attribute to
synthetic agents using information supplied in contingency tables and
optional marginal distributions.

The resulting enriched synthetic population is stored within the module
and can subsequently be validated using
[`ratify`](https://ready4-dev.github.io/replica/reference/ratify.md).

Workflows that generate new output objects, such as household
generation, are implemented using
[`manufacture`](https://ready4-dev.github.io/replica/reference/manufacture.md).

## ReplicaAdder Method

Executes the attribute-assignment workflow.

The method:

1.  resolves missing contingency groups;

2.  calculates conditional fractions;

3.  converts fractions into agent allocations;

4.  assigns target attribute values; and

5.  updates the synthetic population.

Validation results are cleared before execution and may subsequently be
regenerated using
[`ratify()`](https://ready4-dev.github.io/replica/reference/ratify.md).

The updated synthetic population is stored in:


    x@population

## See also

[`renew`](https://ready4-dev.github.io/replica/reference/renew.md),
[`ratify`](https://ready4-dev.github.io/replica/reference/ratify.md),
[`ReplicaAdder`](https://ready4-dev.github.io/replica/reference/ReplicaAdder.md)

[`renew`](https://ready4-dev.github.io/replica/reference/renew.md),
[`ratify`](https://ready4-dev.github.io/replica/reference/ratify.md),
[`manufacture`](https://ready4-dev.github.io/replica/reference/manufacture.md),
[`ReplicaAdder`](https://ready4-dev.github.io/replica/reference/ReplicaAdder.md)

## Examples

``` r
if (FALSE) { # \dontrun{

ADDER <- enhance(
  ADDER
)

head(
  procure(ADDER, "population")
)

} # }
```
