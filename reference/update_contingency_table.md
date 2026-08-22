# Prepare a Contingency Table for Attribute Assignment

Ensures that all conditioning-group combinations present in a synthetic
population are represented in a contingency table.

## Usage

``` r
update_contingency_table(
  contingency_table,
  population,
  group_by,
  target_attribute,
  strategy = "borrow"
)
```

## Arguments

- contingency_table:

  A contingency table containing the target attribute and a `count`
  column.

- population:

  A synthetic population used to determine which conditioning-group
  combinations must be represented.

- group_by:

  Character vector containing the conditioning variables used during
  attribute assignment.

- target_attribute:

  Character string identifying the target attribute.

- strategy:

  Character string specifying how missing contingency groups should be
  handled.

  One of:

  - `"borrow"`

  - `"overall"`

  - `"error"`

## Value

A completed contingency table returned as a `data.table`.

## Details

Missing contingency groups can be handled using one of three
configurable strategies:

- borrow:

  Borrow the nearest available conditional distribution.

- overall:

  Use the overall target-attribute distribution.

- error:

  Stop with an error if required groups are missing.

This function is typically invoked automatically by
[`enhance`](https://ready4-dev.github.io/replica/reference/enhance.md)
before conditional attribute assignment begins.

The function compares all unique combinations of `group_by` variables
found in the synthetic population against those present in the
contingency table.

Any missing combinations are handled according to the specified
strategy.

For `"borrow"`, the function attempts to construct a distribution using
a less-specific grouping level before falling back to the overall
distribution.

For `"overall"`, the function uses the overall target-attribute
distribution computed from the contingency table.

For `"error"`, an exception is raised whenever one or more required
conditioning groups are missing.

This function prevents failures during attribute assignment caused by
incomplete contingency tables and provides a configurable mechanism for
handling sparse input data.

## See also

[`ReplicaAdder`](https://ready4-dev.github.io/replica/reference/ReplicaAdder.md),
[`enhance`](https://ready4-dev.github.io/replica/reference/enhance.md),
[`calculate_fractions`](https://ready4-dev.github.io/replica/reference/calculate_fractions.md),
[`transform_to_contingency`](https://ready4-dev.github.io/replica/reference/transform_to_contingency.md)

## Examples

``` r
if (FALSE) { # \dontrun{

population <- data.frame(
  age_group = c(
    "18-64",
    "18-64"
  ),
  gender = c(
    "Male",
    "Female"
  )
)

contingency_table <- data.frame(
  age_group = c(
    "18-64",
    "18-64",
    "18-64"
  ),
  gender = c(
    "Male",
    "Male",
    "Male"
  ),
  education = c(
    "Degree",
    "Diploma",
    "School"
  ),
  count = c(
    50,
    30,
    20
  )
)

expanded <- update_contingency_table(
  contingency = contingency,
  population = population,
  group_by = c(
    "age_group",
    "gender"
  ),
  target_attribute = "education",
  strategy = "borrow"
)

} # }
```
