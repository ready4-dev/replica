# Create Synthetic Agents From Aggregate Counts

Expands a marginal distribution or contingency table into an agent-level
synthetic population.

## Usage

``` r
make_agents(
  counts,
  count_col = "count",
  agent_id_col = "agent_id",
  prefix = "Agent_"
)
```

## Arguments

- counts:

  A data frame or data.table containing one or more attribute columns
  and a count column.

- count_col:

  Name of the count column.

- agent_id_col:

  Name of the generated agent identifier column.

- prefix:

  Prefix used when generating agent identifiers.

## Value

A data.table containing one row per synthetic agent.

## Details

Each row of the input table is replicated according to its count value,
generating one row per synthetic agent.

## Examples

``` r
age_margin <- data.frame(
  age_group = c(
    "0-17",
    "18-64"
  ),
  count = c(
    2,
    3
  )
)

make_agents(
  age_margin
)
#>    agent_id age_group
#>      <char>    <char>
#> 1:  Agent_1      0-17
#> 2:  Agent_2      0-17
#> 3:  Agent_3     18-64
#> 4:  Agent_4     18-64
#> 5:  Agent_5     18-64
```
