# replica

## Create, enrich, validate and organise synthetic populations.

The `replica` package extends the ready4 framework developed by Hamilton
et al. (2024) by providing tools for:

- creating synthetic agents from marginal distributions and contingency
  tables;

- assigning additional attributes using demographic reference data;

- generating synthetic households;

- validating synthetic population quality using
  [`ratify()`](https://ready4-dev.github.io/replica/reference/ratify.md);
  and

- visualising validation diagnostics using
  [`depict()`](https://ready4-dev.github.io/replica/reference/depict.md).

The package implements and extends synthetic population generation
methods described by de Mooij et al. (2024) and is designed to support
health-economic microsimulation modelling and other simulation
workflows.

## Workflow

The workflow supported by `replica` can be summarised as:

``` text
Aggregate Counts
    ↓
make_agents()
    ↓
Synthetic Agents
    ↓
ReplicaAdder
    ↓
enhance()
    ↓
ratify()
    ↓
depict()
    ↓
Enriched Population
    ↓
ReplicaStructure
    +
ReplicaGrouper
    ↓
manufacture()
    ↓
Synthetic Households
```

## Core workflow methods

`replica` follows a ready4-style workflow centred on a small number of
generic methods:

- [`procure()`](https://ready4-dev.github.io/replica/reference/procure.md)
  for retrieving module contents;

- [`renew()`](https://ready4-dev.github.io/replica/reference/renew.md)
  for updating module contents;

- [`enhance()`](https://ready4-dev.github.io/replica/reference/enhance.md)
  for assigning attributes;

- [`ratify()`](https://ready4-dev.github.io/replica/reference/ratify.md)
  for generating validation diagnostics;

- [`depict()`](https://ready4-dev.github.io/replica/reference/depict.md)
  for visualising validation results; and

- [`manufacture()`](https://ready4-dev.github.io/replica/reference/manufacture.md)
  for generating household outputs.

## Accessing and updating module contents

Module contents can be retrieved using:

``` r

procure(ADDER, slot = "population")
```

and updated using:

``` r

renew(ADDER, population = population_dt)
```

Together,
[`procure()`](https://ready4-dev.github.io/replica/reference/procure.md)
and [`renew()`](https://ready4-dev.github.io/replica/reference/renew.md)
provide a consistent interface for reading and updating replica modules.

## Getting started

`replica` documentation is organised around the complete
synthetic-population workflow.

To install a development version of replica, run the following commands
in your R console:

``` r

utils::install.packages("devtools")

devtools::install_github("ready4-dev/replica")
```

### 1. Creating synthetic agents

Learn how to create individual synthetic agents from aggregate count
data.

Key function:

``` r

make_agents()
```

### 2. Assigning attributes using contingency tables

Learn how to enrich synthetic agents using demographic contingency
tables.

Key class:

``` r

ReplicaAdder
```

### 3. Generating synthetic households

Learn how to transform enriched agents into realistic household
structures.

Key classes:

``` r

ReplicaStructure
ReplicaGrouper
```

### 4. Evaluating synthetic population quality

Learn how to compare synthetic populations with reference data and
assess population quality.

Key methods:

``` r

ratify()
procure()
depict()
```

Validation diagnostics can be generated using:

``` r

ADDER <- ratify(ADDER)
```

inspected using:

``` r

ADDER <- procure(ADDER, slot = "validation_results")
```

and visualised using:

``` r

ADDER <- depict(ADDER, type = "difference")
```

## Current status

`replica` is under active initial development.

**Library classes, syntax, documentation and workflows are evolving
without the use of deprecation conventions.**

This library should currently be used only for exploratory purposes.

## Use of AI

`replica` code, tests and documentation (including vignettes) have all
been authored by a human-machine partnership.

Microsoft Copilot has been used intensively in the development of this
library.

## References

Hamilton MP, Gao C, Wiesner G, Filia KM, Menssink JM, Plencnerova P,
Baker DG, McGorry PD, Parker A, Karnon J, Cotton SM. and Mihalopoulos C
(2024)

*A prototype software framework for transferable computational health
economic models and its early application in youth mental health.*

PharmacoEconomics.

<https://link.springer.com/article/10.1007/s40273-024-01378-8>

<https://ready4-dev.github.io/ready4/>

de Mooij J, Sonnenschein T, Pellegrino M, Dastani M, Ettema D, Logan B
and Verstegen JA (2024).

*GenSynthPop: generating a spatially explicit synthetic population of
individuals and households from aggregated data.*

Autonomous Agents and Multi-Agent Systems.

<https://link.springer.com/article/10.1007/s10458-024-09680-7>
