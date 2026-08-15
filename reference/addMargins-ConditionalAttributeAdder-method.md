# Add Margin Constraints to a ConditionalAttributeAdder

Adds one or more margin tables to a `ConditionalAttributeAdder` object.

## Usage

``` r
# S4 method for class 'ConditionalAttributeAdder'
addMargins(object, margins, margins_names)
```

## Arguments

- object:

  A `ConditionalAttributeAdder` object.

- margins:

  List of margin tables. Each table must contain a `count` column and
  the variables specified in the corresponding entry of `margins_names`.

- margins_names:

  List describing the variables contained in each margin table.

## Value

An updated `ConditionalAttributeAdder` object.

## Details

Margin tables are used to fit contingency tables to known marginal
distributions prior to attribute assignment.

This functionality mirrors the Iterative Proportional Fitting (IPF)
workflow used in the original GenSynthPop implementation.

Margin constraints are used when contingency information is available at
a lower level of aggregation than the available marginal distributions.

During execution:

1.  The contingency table is fitted to the supplied margins.

2.  Conditional probabilities are recalculated.

3.  Target attribute values are assigned.

All margin tables must contain a `count` column.

Each element of `margins_names` should correspond to the variables
represented in the matching entry of `margins`.

## See also

[`ConditionalAttributeAdder`](https://ready4-dev.github.io/replica/reference/ConditionalAttributeAdder.md),
`run`, `verify`

## Examples

``` r
if (FALSE) { # \dontrun{

gender_margin <- data.frame(
  gender = c(
    "Male",
    "Female"
  ),
  count = c(
    100,
    120
  )
)

age_margin <- data.frame(
  age_group = c(
    "0-17",
    "18-64",
    "65+"
  ),
  count = c(
    50,
    140,
    30
  )
)

adder <- addMargins(
  adder,
  margins = list(
    gender_margin,
    age_margin
  ),
  margins_names = list(
    "gender",
    "age_group"
  )
)

} # }
```
