# Verify Synthetic Attribute Assignment

Performs validation checks on the results of a conditional
attribute-assignment workflow.

## Usage

``` r
verify(object)

# S4 method for class 'ConditionalAttributeAdder'
verify(object)
```

## Arguments

- object:

  A
  [`ConditionalAttributeAdder`](https://ready4-dev.github.io/replica/reference/ConditionalAttributeAdder.md)
  object.

## Value

The supplied
[`ConditionalAttributeAdder`](https://ready4-dev.github.io/replica/reference/ConditionalAttributeAdder.md)
object.

## Details

This method is typically executed automatically by
[`run`](https://ready4-dev.github.io/replica/reference/run.md) and is
responsible for identifying potential issues in the generated synthetic
population.

Validation may include:

- Checking for missing target-attribute values.

- Comparing the synthetic distribution against the source contingency
  table.

- Assessing goodness-of-fit statistics.

- Confirming population totals are preserved.

The verification process is intended to identify situations where the
generated synthetic population differs substantially from the intended
distribution.

The method may generate warnings when:

- Target-attribute assignments are missing.

- Contingency distributions differ substantially from the expected
  values.

- Population totals are inconsistent.

Statistical validation utilities used by this workflow may include:

- [`synthetic_population_to_contingency`](https://ready4-dev.github.io/replica/reference/synthetic_population_to_contingency.md)

- [`validate_synthetic_population_fit`](https://ready4-dev.github.io/replica/reference/validate_synthetic_population_fit.md)

- [`calculate_z_squared_score`](https://ready4-dev.github.io/replica/reference/calculate_z_squared_score.md)

## See also

[`run`](https://ready4-dev.github.io/replica/reference/run.md),
[`ConditionalAttributeAdder`](https://ready4-dev.github.io/replica/reference/ConditionalAttributeAdder.md),
[`synthetic_population_to_contingency`](https://ready4-dev.github.io/replica/reference/synthetic_population_to_contingency.md),
[`validate_synthetic_population_fit`](https://ready4-dev.github.io/replica/reference/validate_synthetic_population_fit.md),
[`calculate_z_squared_score`](https://ready4-dev.github.io/replica/reference/calculate_z_squared_score.md)

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
