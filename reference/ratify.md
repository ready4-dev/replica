# Ratify Replica Modules

Evaluates whether a replica module satisfies required validity criteria.

## Usage

``` r
# S4 method for class 'ReplicaAdder'
ratify(x, ...)

# S4 method for class 'ReplicaStructure'
ratify(x, output = c("self", "logical"))
```

## Arguments

- x:

  A replica module.

- ...:

  Additional arguments passed to the method.

- output:

  Character string specifying the desired return value for
  `ReplicaStructure` methods.

  Options are:

  - `"logical"` returns a logical validation result;

  - `"self"` returns the validated `ReplicaStructure`.

## Value

An updated `ReplicaAdder`.

For a `ReplicaAdder`, an updated `ReplicaAdder` containing validation
results.

For a `ReplicaStructure`:

- `output = "logical"` returns a logical value;

- `output = "self"` returns a validated `ReplicaStructure`.

## Details

The behaviour of `ratify()` depends on the class of the supplied object.

Methods are currently available for:

- `ReplicaAdder`

- `ReplicaStructure`

`ratify()` performs class-specific validation checks and returns either
validation results or a validated module.

For synthetic-population workflows, `ratify()` can be used to assess:

- attribute-assignment quality;

- household-assignment integrity; and

- internal consistency of replica modules.

## ReplicaAdder Method

Evaluates the quality of attribute assignment and stores validation
diagnostics within the module.

The observed distributions in the synthetic population are compared with
the expected distributions supplied by the contingency table.

Validation results are stored in:


    x@validation_results

and include:

- z-squared statistics;

- p-values;

- warning flags; and

- detailed comparisons of observed and expected distributions.

For a `ReplicaAdder`, `ratify()` evaluates the quality of attribute
assignment and stores validation diagnostics within the module.

Validation results are stored in:


    procure(ADDER, "validation_results")

and include:

- z-squared statistics;

- p-values;

- warning flags; and

- detailed comparisons of observed and expected distributions.

## ReplicaStructure Method

For a `ReplicaStructure`, `ratify()` evaluates household-assignment
integrity.

Validation checks include:

- duplicate household assignments; and

- eligible agents that have not been assigned to a household.

Agents eligible for assignment are identified using the
household-position definitions stored in the structure.

When duplicate assignments are detected, execution is stopped and an
error is generated.

When eligible agents have not been assigned to a household, a warning is
issued.

The method can return either:

- a logical validation result; or

- the validated `ReplicaStructure` object.

## See also

[`validate_synthetic_population_fit`](https://ready4-dev.github.io/replica/reference/validate_synthetic_population_fit.md),
[`plot_validation_distributions`](https://ready4-dev.github.io/replica/reference/plot_validation_distributions.md),
[`plot_validation_differences`](https://ready4-dev.github.io/replica/reference/plot_validation_differences.md),
[`plot_validation_heatmap`](https://ready4-dev.github.io/replica/reference/plot_validation_heatmap.md)

[`ReplicaAdder`](https://ready4-dev.github.io/replica/reference/ReplicaAdder.md),
[`ReplicaStructure`](https://ready4-dev.github.io/replica/reference/ReplicaStructure.md),
[`renew`](https://ready4-dev.github.io/replica/reference/renew.md),
[`enhance`](https://ready4-dev.github.io/replica/reference/enhance.md),
[`manufacture`](https://ready4-dev.github.io/replica/reference/manufacture.md)

## Examples

``` r
if (FALSE) { # \dontrun{

ADDER <- enhance(
  ADDER
)

ADDER <- ratify(
  ADDER
)

procure(ADDER, "validation_results")

} # }

if (FALSE) { # \dontrun{

## Validate a ReplicaAdder

ADDER <- enhance(ADDER)

ADDER <- ratify(
  ADDER
)

procure(ADDER, "validation_results")

## Validate a ReplicaStructure

ratify(
  structure,
  output = "logical"
)

structure <- ratify(
  structure,
  output = "self"
)

} # }
```
