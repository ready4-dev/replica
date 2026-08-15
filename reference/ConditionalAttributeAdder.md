# Create a ConditionalAttributeAdder Object

Creates a new `ConditionalAttributeAdder` used to add a target attribute
to an existing synthetic population from a contingency table.

## Usage

``` r
ConditionalAttributeAdder(
  synth_pop,
  contingency,
  target_attribute,
  group_by = character(),
  missing_group_strategy = "borrow"
)
```

## Arguments

- synth_pop:

  A synthetic population stored as a data.frame or `data.table`. Each
  row represents a single synthetic agent.

- contingency:

  A contingency table containing the target attribute and a `count`
  column.

  The contingency table defines the joint distribution of the target
  attribute and the specified conditioning variables.

- target_attribute:

  Character string identifying the attribute to be added to the
  synthetic population.

- group_by:

  Character vector containing the conditioning variables used during
  attribute assignment.

- missing_group_strategy:

  Character string specifying how conditioning groups present in the
  synthetic population but absent from the contingency table should be
  handled.

  One of:

  - `"borrow"` (default)

  - `"overall"`

  - `"error"`

## Value

A `ConditionalAttributeAdder` object.

## Details

The resulting object stores the synthetic population, contingency table
and assignment settings required for conditional attribute generation.

After construction, the object is typically executed using
[`run`](https://ready4-dev.github.io/replica/reference/run.md).

During execution, the object:

1.  Partitions the synthetic population using `group_by`.

2.  Obtains conditional distributions from the contingency table.

3.  Converts distributions into integer agent counts.

4.  Assigns target-attribute values.

5.  Validates the resulting synthetic population.

Missing contingency groups may be handled as follows:

- borrow:

  Borrow the nearest available conditional distribution.

- overall:

  Use the overall target-attribute distribution.

- error:

  Stop with an error if a required group is missing.

Margin constraints can be added after construction using
[`addMargins`](https://ready4-dev.github.io/replica/reference/addMargins.md).

## See also

[`run`](https://ready4-dev.github.io/replica/reference/run.md),
[`addMargins`](https://ready4-dev.github.io/replica/reference/addMargins.md),
[`verify`](https://ready4-dev.github.io/replica/reference/verify.md),
[`prepareContingencyTable`](https://ready4-dev.github.io/replica/reference/prepareContingencyTable.md),
[`ConditionalAttributeAdder-class`](https://ready4-dev.github.io/replica/reference/ConditionalAttributeAdder-class.md)

## Examples

``` r
if (FALSE) { # \dontrun{

adder <- ConditionalAttributeAdder(
  synth_pop = population,
  contingency = contingency,
  target_attribute = "education",
  group_by = c(
    "age_group",
    "gender"
  ),
  missing_group_strategy = "borrow"
)

adder <- run(adder)

result <- adder@synth_pop

} # }
```
