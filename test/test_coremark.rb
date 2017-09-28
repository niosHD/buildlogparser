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

class CoremarkTest < Minitest::Test
  def test_empty_input
    parser = BuildLogParser::CoremarkParser.new()

    logtext = ""
    parser.parse(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 0, parser.data.size()
  end

  def test_no_match
    parser = BuildLogParser::CoremarkParser.new()

    logtext = "this\nstring\ndoes\nnot\ncontain\ncoremark\noutput"
    parser.parse(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 0, parser.data.size()
  end

  def test_example_1
    parser = BuildLogParser::CoremarkParser.new()

    logtext = IO.read(File.expand_path('../coremark/example_1.txt', __FILE__))
    parser.parse(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 1, parser.data.size()

    assert_equal 3512687483, parser.data[0][:total_ticks]
    assert_equal 20.908854, parser.data[0][:time_sec]
    assert_equal 478.266287, parser.data[0][:iterations_per_sec]
    assert_equal 10000, parser.data[0][:iterations]
    assert_equal "ARM C/C++ Compiler, 5.03 [Build 24]", parser.data[0][:compiler_version]
    assert_equal "-O3 -Otime --loop_optimization_level=2", parser.data[0][:compiler_flags]
    assert_equal "STACK", parser.data[0][:memory_location]
  end
end
