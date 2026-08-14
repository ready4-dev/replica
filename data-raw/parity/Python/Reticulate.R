## 1. PRE
library(reticulate)
# py_install("pandas")
# py_install("gensynthpop@git+https://github.com/A-Practical-Agent-Programming-Language/GenSynthPop-Python")
# py_require("gensynthpop@git+https://github.com/A-Practical-Agent-Programming-Language/GenSynthPop-Python")
repl_python()

## 2. SOURCE PYTHON SCRIPT OF CHOICE (Not specified here)

## 3. POST
library(reticulate)

# 1. Clear globals in the Python main module
py_run_string("
for name in list(globals().keys()):
    if not name.startswith('_'):
        del globals()[name]
")

# 2. Force Python's garbage collector to free memory
py_run_string("
import gc
gc.collect()
")
# 3. Remove all python.builtin.object class objects from global environment (important as classes are named the same in python and R so conflicts will arise)
rm(list = ls(all.names = TRUE)[sapply(ls(all.names = TRUE), function(x) inherits(get(x), "python.builtin.object"))])
