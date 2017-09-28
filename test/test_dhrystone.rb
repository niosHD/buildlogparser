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

class DhrystoneTest < Minitest::Test
  def test_empty_input
    parser = BuildLogParser::DhrystoneParser.new()

    logtext = ""
    parser.parse(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 0, parser.data.size()
  end

  def test_no_match
    parser = BuildLogParser::DhrystoneParser.new()

    logtext = "this\nstring\ndoes\nnot\ncontain\ndhrystone\noutput"
    parser.parse(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 0, parser.data.size()
  end

  def test_version21_example_1
    parser = BuildLogParser::DhrystoneParser.new()

    logtext = IO.read(File.expand_path('../dhrystone/version21_example_1.txt', __FILE__))
    parser.parse(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 1, parser.data.size()

    assert_equal "2.1", parser.data[0][:version]
    assert_equal 1000000, parser.data[0][:runs]
    assert_equal 24.6, parser.data[0][:usec_per_run]
    assert_equal 40600.9, parser.data[0][:dhrystones_per_sec]
  end

  def test_version22_custom_output
    parser = BuildLogParser::DhrystoneParser.new()

    logtext = IO.read(File.expand_path('../dhrystone/version22_custom_output.txt', __FILE__))
    parser.parse(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 1, parser.data.size()

    assert_equal "2.2", parser.data[0][:version]
    assert_equal 5000, parser.data[0][:runs]
    assert_equal 4070000, parser.data[0][:total_ticks]
  end

  def test_version22_stdout_only
    parser = BuildLogParser::DhrystoneParser.new()

    logtext = IO.read(File.expand_path('../dhrystone/version22_stdout_only.txt', __FILE__))
    parser.parse(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 1, parser.data.size()

    assert_equal "2.2", parser.data[0][:version]
    assert_equal 50000000, parser.data[0][:runs]
    assert_equal 0.1, parser.data[0][:usec_per_run]
    assert_equal 9328358, parser.data[0][:dhrystones_per_sec]
  end

  def test_version22_increasing_runs
    parser = BuildLogParser::DhrystoneParser.new()

    logtext = IO.read(File.expand_path('../dhrystone/version22_increasing_runs.txt', __FILE__))
    parser.parse(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 1, parser.data.size()

    assert_equal "2.2", parser.data[0][:version]
    assert_equal 50000000, parser.data[0][:runs]
    assert_equal 0.1, parser.data[0][:usec_per_run]
    assert_equal 9310987, parser.data[0][:dhrystones_per_sec]
  end
end
