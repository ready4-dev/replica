# Verify a Conditionally Assigned Attribute

Performs validation checks on a synthetic population after a target
attribute has been assigned.

## Usage

``` r
# S4 method for class 'ConditionalAttributeAdder'
verify(object)
```

## Arguments

- object:

  A `ConditionalAttributeAdder` object.

## Value

The supplied `ConditionalAttributeAdder` object.

## Details

This method is typically called automatically by `run` and is
responsible for identifying potential issues in the generated
population.

Validation includes:

- Checking for missing target-attribute assignments.

- Comparing the resulting synthetic distribution to the source
  contingency table.

- Performing statistical goodness-of-fit checks.

If agents remain without values for the target attribute, a warning is
generated.

The method also evaluates whether the resulting synthetic population
remains statistically consistent with the source contingency
distribution.

Statistical validation is performed using:

- [`synthetic_population_to_contingency`](https://ready4-dev.github.io/replica/reference/synthetic_population_to_contingency.md)

- `validate_synthetic_population_fit`

- `calculate_z_squared_score`

Warnings are issued when the generated distribution differs
substantially from the expected contingency-table distribution.

## See also

`run`, `validate_synthetic_population_fit`, `calculate_z_squared_score`,
[`synthetic_population_to_contingency`](https://ready4-dev.github.io/replica/reference/synthetic_population_to_contingency.md),
[`ConditionalAttributeAdder`](https://ready4-dev.github.io/replica/reference/ConditionalAttributeAdder.md)

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
  )
)

adder <- run(adder)

adder <- verify(adder)

} # }
```
