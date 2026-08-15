# Add Margin Constraints

Adds one or more margin tables to a
[`ConditionalAttributeAdder`](https://ready4-dev.github.io/replica/reference/ConditionalAttributeAdder.md)
object.

## Usage

``` r
addMargins(object, margins, margins_names)

# S4 method for class 'ConditionalAttributeAdder'
addMargins(object, margins, margins_names)
```

## Arguments

- object:

  A
  [`ConditionalAttributeAdder`](https://ready4-dev.github.io/replica/reference/ConditionalAttributeAdder.md)
  object.

- margins:

  List of margin tables.

  Each margin table should contain a `count` column and one or more
  grouping variables.

- margins_names:

  List describing the variables represented in each margin table.

## Value

An updated
[`ConditionalAttributeAdder`](https://ready4-dev.github.io/replica/reference/ConditionalAttributeAdder.md)
object.

## Details

Margin tables are used during iterative proportional fitting (IPF)
workflows to align contingency tables with known marginal distributions.

Margin tables are stored internally and may subsequently be used to fit
contingency distributions before attribute assignment.

Typical workflow:


    adder <- ConditionalAttributeAdder(...)

    adder <- addMargins(
      adder,
      margins = margin_tables,
      margins_names = margin_names
    )

    adder <- run(adder)

## See also

[`ConditionalAttributeAdder`](https://ready4-dev.github.io/replica/reference/ConditionalAttributeAdder.md),
[`run`](https://ready4-dev.github.io/replica/reference/run.md),
[`verify`](https://ready4-dev.github.io/replica/reference/verify.md)

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

adder <- addMargins(
  adder,
  margins = list(
    gender_margin
  ),
  margins_names = list(
    "gender"
  )
)

} # }
```
