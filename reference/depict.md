# Depict Replica Modules

Creates visual representations of information stored within replica
modules.

## Usage

``` r
# S4 method for class 'ReplicaAdder'
depict(x, type = c("distribution", "difference", "heatmap"), ...)
```

## Arguments

- x:

  A `ReplicaAdder`.

- type:

  Character string specifying the type of visualisation to create.

  Options are:

  - `"distribution"`

  - `"difference"`

  - `"heatmap"`

- ...:

  Additional arguments passed to the underlying plotting function.

## Value

A graphical object.

## Details

The behaviour of `depict()` depends on the class of the supplied object.

Methods are currently available for:

- `ReplicaAdder`

`depict()` is the primary method used to visualise information generated
by replica modules.

For synthetic-population validation workflows, `depict()` is typically
used after
[`ratify`](https://ready4-dev.github.io/replica/reference/ratify.md) has
been called.

Together,
[`ratify`](https://ready4-dev.github.io/replica/reference/ratify.md) and
`depict()` support evaluation of synthetic-population quality.

[`ratify()`](https://ready4-dev.github.io/replica/reference/ratify.md)
generates validation diagnostics and stores the results within a module,
whereas `depict()` creates graphical summaries of those diagnostics.

## ReplicaAdder Method

Creates graphical summaries of validation results stored within a
`ReplicaAdder`.

Validation results must first be generated using
[`ratify`](https://ready4-dev.github.io/replica/reference/ratify.md).

Supported visualisations include:

- `"distribution"`: observed versus expected distributions;

- `"difference"`: percentage-point differences;

- `"heatmap"`: differences displayed as a heatmap.

## See also

[`ratify`](https://ready4-dev.github.io/replica/reference/ratify.md),
[`plot_validation_distributions`](https://ready4-dev.github.io/replica/reference/plot_validation_distributions.md),
[`plot_validation_differences`](https://ready4-dev.github.io/replica/reference/plot_validation_differences.md),
[`plot_validation_heatmap`](https://ready4-dev.github.io/replica/reference/plot_validation_heatmap.md)

[`ratify`](https://ready4-dev.github.io/replica/reference/ratify.md),
[`renew`](https://ready4-dev.github.io/replica/reference/renew.md),
[`procure`](https://ready4-dev.github.io/replica/reference/procure.md)

## Examples

``` r
if (FALSE) { # \dontrun{

ADDER <- enhance(
  ADDER
)

ADDER <- ratify(
  ADDER
)

depict(
  ADDER,
  type = "distribution"
)

depict(
  ADDER,
  type = "difference"
)

depict(
  ADDER,
  type = "heatmap"
)

} # }
```
