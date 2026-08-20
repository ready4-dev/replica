# replica

## Create, enrich, validate and organise synthetic populations.

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![ready4](https://img.shields.io/badge/ready4-modelling-indigo?style=flat&labelColor=black&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAFzUkdCAK7OHOkAAAAEZ0FNQQAAsY8L/GEFAAAACXBIWXMAABYlAAAWJQFJUiTwAAAAIXRFWHRDcmVhdGlvbiBUaW1lADIwMjI6MDM6MDcgMTY6MTM6NTPZeG5UAAABa0lEQVQ4T4WT607CQBCFpyUi3qIR0eAfNfCi/vENfEgENIAIlcJ6vr1oLaZOerJzdst0zpklc49nznqHZs6ZfWwDem1xM1sqXwtXkb8rL4SuOLEoLXPPXWfD01Dg9dPsrTQbngQ+EZ+LDyIfiy/FHyIfFZbbTslWKOOqxx/uWBPSfp07FahGlqlNfWGqL9HNfBO+CAfwdO55WS8g4MFML834sfJVA9e7vwsg50aGohncdmRojV9XeL+jArRNmZxVSJ4Acj3NHqARdyeFJqC2KJiCfKE9zsfxnNYTl5TcCtmNMcwY/ZXf+3wdzzVza2vj4iCaq3d1R/bvwVSH6IPjNIUHx0FSNZA7WquDqOVb35+eiO8h7Oe+vRfp0a3yGtFMDuiAIg2R20YaVwJ3Hj+4kehO/J/I7VJ/jHtpvBP6mrHnR4EzdyQ0xI8HhM8jUiChxVpDK3iVuadzx43yRdI4E2d0gNtX74TCs419AR8YEST/cHPBAAAAAElFTkSuQmCC)](https://www.ready4-dev.com/docs/software/libraries/types/module/)
[![R-CMD-check](https://github.com/ready4-dev/replica/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ready4-dev/replica/actions/workflows/R-CMD-check.yaml)

<!-- badges: end -->

`replica` is an R library for generating synthetic populations of individual agents and households from aggregated demographic data.

The library provides tools for:

- creating synthetic agents from marginal distributions and contingency tables;

- assigning additional attributes using demographic reference data;

- generating synthetic households;

- validating synthetic population quality; and

- visualising goodness-of-fit.

The package implements and extends synthetic population generation methods described by de Mooij et al. (2024) and is designed to support health-economic microsimulation modelling and other simulation workflows.

## Workflow

The workflow supported by `replica` can be summarised as:

```text
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

`replica` documentation is organised around the complete synthetic-population workflow.

To install a development version of replica, run the following commands in your R console:

```r
utils::install.packages("devtools")

devtools::install_github("ready4-dev/replica")

```


### 1. Creating Synthetic Agents

Learn how to create individual synthetic agents from aggregate count data.

Key function:

```r
make_agents()
```

### 2. Assigning Attributes Using Contingency Tables

Learn how to enrich synthetic agents using demographic contingency tables.

Key class:

```r
ReplicaAdder
```

### 3. Generating Synthetic Households

Learn how to transform enriched agents into realistic household structures.

Key classes:

```r
ReplicaStructure
ReplicaGrouper
```

### 4. Evaluating Synthetic Population Quality

Learn how to compare synthetic populations with reference data and assess population quality.

Key functions:

```r
validate_synthetic_population_fit()

plot_validation_distributions()

plot_validation_differences()

plot_validation_heatmap()
```

## Current Status

`replica` is under active development.

Library classes, syntax, documentation and workflows continue to evolve as additional functionality is implemented and tested.

This library should currently be used only for exploratory purposes.

## Use of AI
`replica` code, tests and documentation (including vignettes) have all been authored by a human-machine partnership. 

Microsoft Copilot has been used intensively in the development of this library.


## References

de Mooij J, Sonnenschein T, Pellegrino M, Dastani M, Ettema D, Logan B and Verstegen JA (2024).

*GenSynthPop: generating a spatially explicit synthetic population of individuals and households from aggregated data.*

Autonomous Agents and Multi-Agent Systems.

https://link.springer.com/article/10.1007/s10458-024-09680-7


