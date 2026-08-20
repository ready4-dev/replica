# Enhance Replica Modules

Executes a replica workflow.

## Usage

``` r
# S4 method for class 'ReplicaAdder'
enhance(x = "ReplicaAdder", ...)

# S4 method for class 'ReplicaGrouper'
enhance(x, ...)
```

## Arguments

- x:

  A `ReplicaGrouper`.

- ...:

  Additional arguments passed to the method.

## Value

An updated `ReplicaAdder`.

A list containing:

- `synthetic_population`,

- `synthetic_households`, and

- `object`.

The returned population contains one row per synthetic agent, while the
household table contains one row per synthetic household.

## Details

The behaviour of `enhance()` depends on the class of the supplied
object.

Methods are currently available for:

- `ReplicaAdder`

- `ReplicaGrouper`

`enhance()` is the primary workflow execution method used by replica
modules.

Depending on the module supplied, the method may:

- assign attributes to synthetic agents;

- generate synthetic households; or

- perform other population-enhancement tasks.

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


    x@synth_pop

## ReplicaGrouper Method

Generates synthetic households from a synthetic population using one or
more registered `ReplicaStructure` definitions.

For each grouping region, the method:

1.  identifies eligible household members;

2.  applies registered household structures;

3.  matches agents according to demographic rules;

4.  creates synthetic households;

5.  assigns household identifiers; and

6.  generates household-level outputs.

Household generation is performed independently within each grouping
region defined by the `group_by` slot.

## See also

[`renew`](https://ready4-dev.github.io/replica/reference/renew.md),
[`ratify`](https://ready4-dev.github.io/replica/reference/ratify.md),
[`ReplicaAdder`](https://ready4-dev.github.io/replica/reference/ReplicaAdder.md)

[`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md),
[`ReplicaGrouper`](https://ready4-dev.github.io/replica/reference/ReplicaGrouper.md),
[`renew`](https://ready4-dev.github.io/replica/reference/renew.md)

## Examples

``` r
if (FALSE) { # \dontrun{

adder <- enhance(
  adder
)

head(
  adder@synth_pop
)

} # }

if (FALSE) { # \dontrun{

result <- enhance(
  grouper
)

result$synthetic_population

result$synthetic_households

} # }
```
