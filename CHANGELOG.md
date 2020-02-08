# Changelog

## v0.4.0 (08.02.2020)

* Updated command line parser library to new name.
* [ctest/log] Relaxed the command syntax to allow all possible characters.
* Added support for parsing *scimark2* command line output.
* Added support for parsing lmbench *lat_mem_rd* command line output.
* Added support for parsing *gem5* generated `stats.txt` files.

## v0.3.1 (11.05.2018)

* Fixed broken __FILE__ check in command line tool.

## v0.3.0 (09.05.2018)

* Added a registry which maps string names to parser functions.
* Added a simple command line tool named *buildlogparser* that ...
  - ... applies a parser function on an input file.
  - ... formats the results either as *yaml* (default), *csv*, or ASCII *table*.
  - ... writes the results to stdout or to an output file.
  - ... can load and use external parsers that register themselves via the registry.
* Added support for parsing *lld* generated map files.
* Removed redundant entries from the path match rules of the bundled parsers.

## v0.2.0 (28.10.2017)

* Added support for parsing *coremark* command line output.
* Added support for parsing *dhrystone* command line output.
* [ctest] Fixed parsing of regex errors in the command line output.
* [cmake] Fixed parsing of non empty text which does not match.
* [size] Fixed parsing of non empty text which does not match.

## v0.1.0 (Unreleased)

* Added support for parsing *cmake* generated makefile command line output.
* Added support for parsing *ctest* command line output.
* Added support for parsing *ctest* generated `LastTest.log` files.
* Added support for parsing *size* command line output in Berkeley format.
