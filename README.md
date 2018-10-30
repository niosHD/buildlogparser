[![Gem Version](https://badge.fury.io/rb/buildlogparser.svg)](https://rubygems.org/gems/buildlogparser)
[![Build Status](https://travis-ci.org/niosHD/buildlogparser.svg?branch=develop)](https://travis-ci.org/niosHD/buildlogparser)
[![codecov](https://codecov.io/gh/niosHD/buildlogparser/branch/develop/graph/badge.svg)](https://codecov.io/gh/niosHD/buildlogparser)

Collection of various parsers for the extraction of information from build and execution logs.

# buildlogparser Gem

To enable easy processing and analysis using automated tools, it is best to have data in a format that is easily machine-readable (e.g., XML, JSON, YAML, CSV, ...). However, not every tool supports the generation of such output formats or using them may not be possible. Therefore, other ways to gather the needed information have to be found. Log files, which are often available, are such an alternative information source.

This gem provides a collection of simple parsers to extract information from such log files. Of course, gathering the same data as from reading a machine-readable format is probably not possible given that log files are typically only semi-structured and/or optimized for human readability. Still, quite some valuable information can be extracted.

## Installation

Release versions of the gem can be installed from rubygems:

~~~bash
$ gem install buildlogparser
~~~

## Usage as Command Line Tool

Like shown in the following examples, the included `buildlogparser` command line tool is a convenient way to apply one specific parser to an input file.
~~~bash
# parse coremark output and print the result as yaml to stdout
$ buildlogparser -t coremark -f yaml -i test/coremark/example_1.txt
# parse size output in Berkeley format and print the result as ASCII table to stdout
$ buildlogparser -t sizeBerkeleyStdout -f table -i test/size/berkeley_stdout_multi_line.txt
# parse ctest stdout output and write the result as csv into result.csv
$ buildlogparser -t ctestStdout -f csv -i test/ctest/stdout_success.txt -o result.csv
~~~
Note that also the usage of external parsers, which are not bundled with the gem, is supported given that they register themselves. More information on the supported arguments as well as the names for the bundled parsers can be found in the included help (i.e., `buildlogparser -h`).

## Usage as Library

It is also possible to use the `buildlogparser` gem as library in situations where more complex parsers are needed or when the extracted data should be directly processed. Simply require the gem and instantiate the desired parsers, either directly or indirectly via the registry, as in the following example.

~~~ruby
require 'rubygems'
require 'buildlogparser'

logtext = """
   text	   data	    bss	    dec	    hex	filename
   4960	     72	     64	   5096	   13e8	aes
  12656	     72	     68	  12796	   31fc	bigen
    952	     72	     64	   1088	    440	indcall
"""

parser = BuildLogParser::SizeParser.new()
parse_result = parser.parseBerkeleyStdout(logtext)

puts "data/bss ratios:"
parse_result.each do |line|
  puts "#{line[:filename]}: #{line[:data].to_f/line[:bss].to_f}"
end
~~~

## Developing the gem

Running tests:
~~~bash
# execute the full test suite
$ rake test
# execute the full test suite in verbose mode
$ rake test TESTOPTS='-v'
# execute only the `RegistryTest#test_get_names` test
$ rake test TESTOPTS='-n=/RegistryTest#test_get_names/'
~~~

Executing the command line tool without installation:
~~~bash
$ RUBYLIB=<repo-path>/lib <repo-path>/bin/buildlogparser <arguments>
~~~

## Tested Program Versions

* cmake/ctest 3.5.1
* coremark 1.0
* dhrystone (C Version) 2.1 and 2.2
* lld 7.0 (development version)
* lmbench lat_mem_rd 3.0-a9
* scimark (C Version) 2.0
* size (GNU Binutils 2.26.1)
