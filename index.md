# replica

## Create, enrich, validate and organise synthetic populations.

`replica` is an R library for generating synthetic populations of
individual agents and households from aggregated demographic data.

The library provides tools for:

- creating synthetic agents from marginal distributions and contingency
  tables;

- assigning additional attributes using demographic reference data;

- generating synthetic households;

- validating synthetic population quality; and

- visualising goodness-of-fit.

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
Enriched Population
       ↓
ReplicaStructure
       +
ReplicaGrouper
       ↓
Synthetic Households
       ↓
Validation
```

## Getting Started

`replica` documentation is organised around the complete
synthetic-population workflow.

To install a development version of replica, run the following commands
in your R console:

``` r

utils::install.packages("devtools")

devtools::install_github("ready4-dev/replica")
```

### 1. Creating Synthetic Agents

Learn how to create individual synthetic agents from aggregate count
data.

Key function:

``` r

make_agents()
```

### 2. Assigning Attributes Using Contingency Tables

Learn how to enrich synthetic agents using demographic contingency
tables.

Key class:

``` r

ReplicaAdder
```

### 3. Generating Synthetic Households

Learn how to transform enriched agents into realistic household
structures.

Key classes:

``` r

ReplicaStructure
ReplicaGrouper
```

### 4. Evaluating Synthetic Population Quality

Learn how to compare synthetic populations with reference data and
assess population quality.

Key functions:

``` r

validate_synthetic_population_fit()

plot_validation_distributions()

plot_validation_differences()

plot_validation_heatmap()
```

## Current Status

`replica` is under active development.

Library classes, syntax, documentation and workflows continue to evolve
as additional functionality is implemented and tested.

This library should currently be used only for exploratory purposes.

## Use of AI

`replica` code, tests and documentation (including vignettes) have all
been authored by a human-machine partnership.

Microsoft Copilot has been used intensively in the development of this
library.

## References

de Mooij J, Sonnenschein T, Pellegrino M, Dastani M, Ettema D, Logan B
and Verstegen JA (2024).

*GenSynthPop: generating a spatially explicit synthetic population of
individuals and households from aggregated data.*

Autonomous Agents and Multi-Agent Systems.

<https://link.springer.com/article/10.1007/s10458-024-09680-7>
