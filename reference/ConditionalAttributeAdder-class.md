# Conditional Attribute Adder

Represents a conditional attribute assignment workflow for synthetic
population generation.

## Details

A `ConditionalAttributeAdder` object adds a target attribute to an
existing synthetic population using one or more contingency tables and,
optionally, margin constraints.

Attributes are assigned conditionally on one or more
previously-generated attributes specified by `group_by`.

Missing contingency groups can be handled using configurable strategies:

- borrow:

  Borrow the nearest available conditional distribution.

- overall:

  Use the overall target distribution.

- error:

  Stop with an error.

ConditionalAttributeAdder forms the core of the replica
attribute-generation workflow.

The object:

1.  Validates contingency information.

2.  Resolves missing conditioning groups.

3.  Computes conditional fractions.

4.  Converts fractions to agent counts.

5.  Assigns target attribute values.

6.  Verifies the resulting distribution.

## Slots

- `synth_pop`:

  A synthetic population stored as a `data.table`.

- `contingency`:

  A contingency table containing the target attribute distribution.

- `target_attribute`:

  Character string identifying the attribute to be added.

- `group_by`:

  Character vector containing conditioning variables.

- `margins`:

  List of margin tables used for IPF fitting.

- `margins_names`:

  Names corresponding to supplied margin tables.

- `margins_group`:

  Grouping variables present in supplied margins.

- `missing_group_strategy`:

  Strategy used when a conditioning group is absent from the contingency
  table.

## See also

`run`, `addMargins`, `verify`,
[`prepareContingencyTable`](https://ready4-dev.github.io/replica/reference/prepareContingencyTable.md)
