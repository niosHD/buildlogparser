#
# Copyright (C) 2018 Mario Werner <nioshd@gmail.com>
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

class Gem5Test < Minitest::Test
  def test_stats_empty_input
    parser = BuildLogParser::Gem5Parser.new()

    logtext = ""
    parser.parseStats(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 0, parser.data.size()
  end

  def test_stats_no_match
    parser = BuildLogParser::Gem5Parser.new()

    logtext = "this\nstring\ndoes\nnot\ncontain\ngem5Stats\noutput"
    parser.parseStats(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 0, parser.data.size()
  end

  def test_stats
    parser = BuildLogParser::Gem5Parser.new()

    logtext = IO.read(File.expand_path('../gem5/stats.txt', __FILE__))
    parser.parseStats(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 1, parser.data.size()

    assert_equal 1.304923, parser.data[0][:sim_seconds]
    assert_equal 1304923361500, parser.data[0][:sim_ticks]
    # ...
    assert_equal 1304923361500, parser.data[0].dig(:system,:bootmem,:pwrStateResidencyTicks,:UNDEFINED)
    assert_equal 20, parser.data[0].dig(:system,:bootmem,:bytes_read,:cpu,:inst)
    # ...
    assert parser.data[0].dig(:system,:cpu,:dcache,:avg_blocked_cycles,:no_targets)&.nan?
    # ...
    assert_equal Float::INFINITY, parser.data[0].dig(:system,:cpu,:dcache,:CleanSharedReq_mshr_miss_rate,:cpu,:data)
    # ...
    assert_equal 1, parser.data[0].dig(:system,:mem_ctrls,:rdPerTurnAround,"1.31072e+06-1.44179e+06")
    # ...
    assert_equal 26871000, parser.data[0].dig(:system,:tol2bus,:respLayer3,:occupancy)
    assert_equal 0.0, parser.data[0].dig(:system,:tol2bus,:respLayer3,:utilization)
  end
end
