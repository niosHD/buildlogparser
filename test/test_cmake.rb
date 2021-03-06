#
# Copyright (C) 2017 Mario Werner <nioshd@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
require 'helper'

class CMakeTest < Minitest::Test
  def test_stdout_makefile_empty_input
    parser = BuildLogParser::CMakeParser.new()

    logtext = ""
    parser.parseMakefileStdout(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 0, parser.targets.size()
  end

  def test_stdout_makefile_no_match
    parser = BuildLogParser::CMakeParser.new()

    logtext = "this\nstring\ndoes\nnot\ncontain\ncmake\noutput"
    parser.parseMakefileStdout(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 0, parser.targets.size()
  end

  def test_stdout_makefile_clean_initial_build
    parser = BuildLogParser::CMakeParser.new()

    logtext = IO.read(File.expand_path('../cmake/stdout_makefile_clean_initial_build.txt', __FILE__))
    parser.parseMakefileStdout(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 1, parser.targets.size()

    assert_equal "main", parser.targets[0][:name]
    assert_equal 4, parser.targets[0][:events].size()

    assert_equal 25, parser.targets[0][:events][0][:percentage]
    assert_equal :building, parser.targets[0][:events][0][:operation]
    assert_equal :c, parser.targets[0][:events][0][:language]
    assert_equal :object, parser.targets[0][:events][0][:targettype]
    assert_equal "CMakeFiles/main.dir/foo.c.o", parser.targets[0][:events][0][:path]
    assert_equal "", parser.targets[0][:events][0][:output]

    assert_equal 50, parser.targets[0][:events][1][:percentage]
    assert_equal :building, parser.targets[0][:events][1][:operation]
    assert_equal :cxx, parser.targets[0][:events][1][:language]
    assert_equal :object, parser.targets[0][:events][1][:targettype]
    assert_equal "CMakeFiles/main.dir/main.cpp.o", parser.targets[0][:events][1][:path]
    assert_equal "", parser.targets[0][:events][1][:output]

    assert_equal 75, parser.targets[0][:events][2][:percentage]
    assert_equal :building, parser.targets[0][:events][2][:operation]
    assert_equal :cxx, parser.targets[0][:events][2][:language]
    assert_equal :object, parser.targets[0][:events][2][:targettype]
    assert_equal "CMakeFiles/main.dir/bar.cpp.o", parser.targets[0][:events][2][:path]
    assert_equal "", parser.targets[0][:events][2][:output]

    assert_equal 100, parser.targets[0][:events][3][:percentage]
    assert_equal :linking, parser.targets[0][:events][3][:operation]
    assert_equal :cxx, parser.targets[0][:events][3][:language]
    assert_equal :executable, parser.targets[0][:events][3][:targettype]
    assert_equal "main", parser.targets[0][:events][3][:path]
    assert_equal "", parser.targets[0][:events][3][:output]
  end

  def test_stdout_makefile_clean_build
    parser = BuildLogParser::CMakeParser.new()

    logtext = IO.read(File.expand_path('../cmake/stdout_makefile_clean_build.txt', __FILE__))
    parser.parseMakefileStdout(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 1, parser.targets.size()

    assert_equal "main", parser.targets[0][:name]
    assert_equal 4, parser.targets[0][:events].size()

    assert_equal 25, parser.targets[0][:events][0][:percentage]
    assert_equal :building, parser.targets[0][:events][0][:operation]
    assert_equal :c, parser.targets[0][:events][0][:language]
    assert_equal :object, parser.targets[0][:events][0][:targettype]
    assert_equal "CMakeFiles/main.dir/foo.c.o", parser.targets[0][:events][0][:path]
    assert_equal "", parser.targets[0][:events][0][:output]

    assert_equal 50, parser.targets[0][:events][1][:percentage]
    assert_equal :building, parser.targets[0][:events][1][:operation]
    assert_equal :cxx, parser.targets[0][:events][1][:language]
    assert_equal :object, parser.targets[0][:events][1][:targettype]
    assert_equal "CMakeFiles/main.dir/main.cpp.o", parser.targets[0][:events][1][:path]
    assert_equal "", parser.targets[0][:events][1][:output]

    assert_equal 75, parser.targets[0][:events][2][:percentage]
    assert_equal :building, parser.targets[0][:events][2][:operation]
    assert_equal :cxx, parser.targets[0][:events][2][:language]
    assert_equal :object, parser.targets[0][:events][2][:targettype]
    assert_equal "CMakeFiles/main.dir/bar.cpp.o", parser.targets[0][:events][2][:path]
    assert_equal "", parser.targets[0][:events][2][:output]

    assert_equal 100, parser.targets[0][:events][3][:percentage]
    assert_equal :linking, parser.targets[0][:events][3][:operation]
    assert_equal :cxx, parser.targets[0][:events][3][:language]
    assert_equal :executable, parser.targets[0][:events][3][:targettype]
    assert_equal "main", parser.targets[0][:events][3][:path]
    assert_equal "", parser.targets[0][:events][3][:output]
  end

  def test_stdout_makefile_noop
    parser = BuildLogParser::CMakeParser.new()

    logtext = IO.read(File.expand_path('../cmake/stdout_makefile_noop.txt', __FILE__))
    parser.parseMakefileStdout(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 1, parser.targets.size()

    assert_equal "main", parser.targets[0][:name]
    assert_equal 0, parser.targets[0][:events].size()
  end

  def test_stdout_makefile_static_libs
    parser = BuildLogParser::CMakeParser.new()

    logtext = IO.read(File.expand_path('../cmake/stdout_makefile_static_libs.txt', __FILE__))
    parser.parseMakefileStdout(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 3, parser.targets.size()

    assert_equal "cpu", parser.targets[0][:name]
    assert_equal 4, parser.targets[0][:events].size()

    assert_equal "arch", parser.targets[1][:name]
    assert_equal 7, parser.targets[1][:events].size()

    assert_equal "aes", parser.targets[2][:name]
    assert_equal 3, parser.targets[2][:events].size()
  end

  def test_stdout_makefile_verbose_initial_build
    parser = BuildLogParser::CMakeParser.new()

    logtext = IO.read(File.expand_path('../cmake/stdout_makefile_verbose_initial_build.txt', __FILE__))
    parser.parseMakefileStdout(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 1, parser.targets.size()

    assert_equal "main", parser.targets[0][:name]
    assert_equal 4, parser.targets[0][:events].size()

    assert_equal 25, parser.targets[0][:events][0][:percentage]
    assert_equal :building, parser.targets[0][:events][0][:operation]
    assert_equal :c, parser.targets[0][:events][0][:language]
    assert_equal :object, parser.targets[0][:events][0][:targettype]
    assert_equal "CMakeFiles/main.dir/foo.c.o", parser.targets[0][:events][0][:path]
    assert_equal "/usr/lib/ccache/cc     -o CMakeFiles/main.dir/foo.c.o   -c /home/mwerner/tmp/test/foo.c\n", parser.targets[0][:events][0][:output]

    assert_equal 50, parser.targets[0][:events][1][:percentage]
    assert_equal :building, parser.targets[0][:events][1][:operation]
    assert_equal :cxx, parser.targets[0][:events][1][:language]
    assert_equal :object, parser.targets[0][:events][1][:targettype]
    assert_equal "CMakeFiles/main.dir/main.cpp.o", parser.targets[0][:events][1][:path]
    assert_equal "/usr/lib/ccache/c++      -o CMakeFiles/main.dir/main.cpp.o -c /home/mwerner/tmp/test/main.cpp\n", parser.targets[0][:events][1][:output]

    assert_equal 75, parser.targets[0][:events][2][:percentage]
    assert_equal :building, parser.targets[0][:events][2][:operation]
    assert_equal :cxx, parser.targets[0][:events][2][:language]
    assert_equal :object, parser.targets[0][:events][2][:targettype]
    assert_equal "CMakeFiles/main.dir/bar.cpp.o", parser.targets[0][:events][2][:path]
    assert_equal "/usr/lib/ccache/c++      -o CMakeFiles/main.dir/bar.cpp.o -c /home/mwerner/tmp/test/bar.cpp\n", parser.targets[0][:events][2][:output]

    assert_equal 100, parser.targets[0][:events][3][:percentage]
    assert_equal :linking, parser.targets[0][:events][3][:operation]
    assert_equal :cxx, parser.targets[0][:events][3][:language]
    assert_equal :executable, parser.targets[0][:events][3][:targettype]
    assert_equal "main", parser.targets[0][:events][3][:path]
    assert_equal "/usr/bin/cmake -E cmake_link_script CMakeFiles/main.dir/link.txt --verbose=1\n/usr/lib/ccache/c++      CMakeFiles/main.dir/foo.c.o CMakeFiles/main.dir/main.cpp.o CMakeFiles/main.dir/bar.cpp.o  -o main -rdynamic \nmake[2]: Leaving directory '/home/mwerner/tmp/test/_build'\n", parser.targets[0][:events][3][:output]
  end
end
