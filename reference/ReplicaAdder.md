# Create a ReplicaAdder Module

Creates a `ReplicaAdder` object for assigning attributes to a synthetic
population using contingency tables.

## Usage

``` r
ReplicaAdder(
  population,
  contingency_table,
  target_attribute,
  group_by = character(),
  missing_group_strategy = "borrow",
  warning_threshold = 0.05
)
```

## Arguments

- population:

  A synthetic population represented as a data.frame or data.table.

- contingency_table:

  A contingency table describing the expected relationship between
  conditioning variables and the target attribute.

- target_attribute:

  Character string identifying the attribute to be assigned.

- group_by:

  Character vector specifying conditioning variables used during
  assignment.

- missing_group_strategy:

  Character string specifying how groups missing from the contingency
  table should be handled. Options include `"borrow"`, `"overall"` and
  `"error"`.

- warning_threshold:

  Numeric significance threshold used when generating validation
  warnings.

## Value

A `ReplicaAdder` object.

## Details

The resulting module can subsequently be configured using
[`renew()`](https://ready4-dev.github.io/replica/reference/renew.md),
executed using
[`enhance()`](https://ready4-dev.github.io/replica/reference/enhance.md)
and validated using
[`ratify()`](https://ready4-dev.github.io/replica/reference/ratify.md).

## See also

`ReplicaAdder`,
[`renew`](https://ready4-dev.github.io/replica/reference/renew.md),
[`enhance`](https://ready4-dev.github.io/replica/reference/enhance.md),
[`ratify`](https://ready4-dev.github.io/replica/reference/ratify.md)

## Examples

``` r
age_gender <- data.frame(
  age_group = c("18-64", "65+"),
  count = c(10, 10)
)

population <- make_agents(
  age_gender
)

contingency_table <- data.frame(
  age_group = c("18-64", "65+"),
  education = c("Degree", "School"),
  count = c(60, 40)
)

adder <- ReplicaAdder(
  population = population,
  contingency_table = contingency_table,
  target_attribute = "education",
  group_by = "age_group"
)
```
