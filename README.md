# replica

## Very early, experimental project currently comprised of a port of a third party python algorithm

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![ready4](https://img.shields.io/badge/ready4-modelling-indigo?style=flat&labelColor=black&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAAFzUkdCAK7OHOkAAAAEZ0FNQQAAsY8L/GEFAAAACXBIWXMAABYlAAAWJQFJUiTwAAAAIXRFWHRDcmVhdGlvbiBUaW1lADIwMjI6MDM6MDcgMTY6MTM6NTPZeG5UAAABa0lEQVQ4T4WT607CQBCFpyUi3qIR0eAfNfCi/vENfEgENIAIlcJ6vr1oLaZOerJzdst0zpklc49nznqHZs6ZfWwDem1xM1sqXwtXkb8rL4SuOLEoLXPPXWfD01Dg9dPsrTQbngQ+EZ+LDyIfiy/FHyIfFZbbTslWKOOqxx/uWBPSfp07FahGlqlNfWGqL9HNfBO+CAfwdO55WS8g4MFML834sfJVA9e7vwsg50aGohncdmRojV9XeL+jArRNmZxVSJ4Acj3NHqARdyeFJqC2KJiCfKE9zsfxnNYTl5TcCtmNMcwY/ZXf+3wdzzVza2vj4iCaq3d1R/bvwVSH6IPjNIUHx0FSNZA7WquDqOVb35+eiO8h7Oe+vRfp0a3yGtFMDuiAIg2R20YaVwJ3Hj+4kehO/J/I7VJ/jHtpvBP6mrHnR4EzdyQ0xI8HhM8jUiChxVpDK3iVuadzx43yRdI4E2d0gNtX74TCs419AR8YEST/cHPBAAAAAElFTkSuQmCC)](https://www.ready4-dev.com/docs/software/libraries/types/module/)
[![R-CMD-check](https://github.com/ready4-dev/replica/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ready4-dev/replica/actions/workflows/R-CMD-check.yaml)
[![CRAN status](https://www.r-pkg.org/badges/version/replica)](https://CRAN.R-project.org/package=template)
<!-- badges: end -->

The medium term intention of this repository is to include a suite of tools for generating synthetic populations that can be used in conjunction with the ready4 framework.

However, right now it consists almost exclusively of an attempt at making an R port of a python toolkit for synthetic population generation.

This means that although the developers of that python algorithm were not involved in this R port (and therefore are not responsible for any errors introduced in the translation), any attribution for this package should credit these developers as the original authors of the algorithm this library attempts to implement in R.

The python toolkit that this library aims to port (with minor modifications) is [GenSynthPop](https://github.com/A-Practical-Agent-Programming-Language/GenSynthPop-Python/tree/main) which was developed in conjunction with [this research study](https://link.springer.com/article/10.1007/s10458-024-09680-7). There is an [existing R implementation of GenSynthPop](https://github.com/TabeaSonnenschein/GenSynthPop) but this appears to be less full featured than the python library, which is one of the reasons I have attempted a more comprehensive port here. I was not involved in the work to develop GenSynthPop (in python or R) but have started the replica library with a port of this toolkit because it is potentially relevant to some projects being developed with ready4. Unlike other ready4 suite libraries, I have not yet used the ready4 modules and code style in implementing this library yet as the names are designed to correspond closely with their python counterparts to make following the logic a little easier. This may change with future iterations.

Finally, I am much more comfortable working in R than in python and would not have attempted this port without leaning massively on my robot fried Microsoft Copilot. I have been impressed with its ability to make this port project feasible to implement in a relatively short timeframe.


To install a development version of replica, run the following commands in your R console:

```r
utils::install.packages("devtools")

devtools::install_github("ready4-dev/replica")

```
