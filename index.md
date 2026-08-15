# replica

## Very early, experimental project currently comprised of a port of a third party python algorithm

The medium term intention of this repository is to include a suite of
tools for generating synthetic populations that can be used in
conjunction with [the ready4 framework](https://www.ready4-dev.com/).

However, right now it consists almost exclusively of an attempt at
making an R port of a python library that implements [the method
described by Jan de Mooij, Tabea Sonnenschein, Marco Pellegrino, Mehdi
Dastani, Dick Ettema, Brian Logan & Judith A.
Verstegen](https://link.springer.com/article/10.1007/s10458-024-09680-7).

This means that although the developers of that python algorithm were
not involved in this R port (and therefore are not responsible for any
errors introduced in the translation), any attribution for this package
should credit these authors as the original developers of the algorithm
this library attempts to implement.

The python toolkit that this library aims to port (with minor
modifications) is
[GenSynthPop](https://github.com/A-Practical-Agent-Programming-Language/GenSynthPop-Python/tree/main).
There is an [existing R implementation of
GenSynthPop](https://github.com/TabeaSonnenschein/GenSynthPop) but this
appears to be less full featured than the python library, which is one
of the reasons I have attempted a more comprehensive port here. I was
not involved in the work to develop GenSynthPop (in python or R) or its
underlying algorithm but have started the replica library by porting
this toolkit because it is potentially relevant to some projects being
developed with ready4. Unlike other ready4 suite libraries, I have not
yet used the ready4 modules and code style in implementing this library
yet as the names are designed to correspond closely with their python
counterparts to make following the logic a little easier. This may
change with future iterations.

Finally, I am much more comfortable working in R than in python and
would not have attempted this port without leaning massively on my robot
fried Microsoft Copilot. I have been impressed with its ability to make
this port project feasible to implement in a relatively short timeframe.

To install a development version of replica, run the following commands
in your R console:

``` r

utils::install.packages("devtools")

devtools::install_github("ready4-dev/replica")
```
