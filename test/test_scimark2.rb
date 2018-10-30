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

class Scimark2Test < Minitest::Test
  def test_empty_input
    parser = BuildLogParser::Scimark2Parser.new()

    logtext = ""
    parser.parse(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 0, parser.data.size()
  end

  def test_no_match
    parser = BuildLogParser::Scimark2Parser.new()

    logtext = "this\nstring\ndoes\nnot\ncontain\nscimark2\noutput"
    parser.parse(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 0, parser.data.size()
  end

  def test_c_large
    parser = BuildLogParser::Scimark2Parser.new()

    logtext = IO.read(File.expand_path('../scimark2/c_large.txt', __FILE__))
    parser.parse(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 1, parser.data.size()

    assert_equal 0.1, parser.data[0][:time_per_kernel]
    assert_equal 58.47, parser.data[0][:composite]
    assert_equal 15.14, parser.data[0][:fft]
    assert_equal 1048576, parser.data[0][:fft_n]
    assert_equal 135.31, parser.data[0][:sor]
    assert_equal 1000, parser.data[0][:sor_1]
    assert_equal 1000, parser.data[0][:sor_2]
    assert_equal 45.86, parser.data[0][:monte_carlo]
    assert_equal 36.22, parser.data[0][:sparse_matmult]
    assert_equal 100000, parser.data[0][:sparse_matmult_n]
    assert_equal 1000000, parser.data[0][:sparse_matmult_nz]
    assert_equal 59.83, parser.data[0][:lu]
    assert_equal 1000, parser.data[0][:lu_m]
    assert_equal 1000, parser.data[0][:lu_n]
  end
  
  def test_c_small
    parser = BuildLogParser::Scimark2Parser.new()

    logtext = IO.read(File.expand_path('../scimark2/c_small.txt', __FILE__))
    parser.parse(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 1, parser.data.size()

    assert_equal 0.1, parser.data[0][:time_per_kernel]
    assert_equal 128.90, parser.data[0][:composite]
    assert_equal 115.71, parser.data[0][:fft]
    assert_equal 1024, parser.data[0][:fft_n]
    assert_equal 241.14, parser.data[0][:sor]
    assert_equal 100, parser.data[0][:sor_1]
    assert_equal 100, parser.data[0][:sor_2]
    assert_equal 45.85, parser.data[0][:monte_carlo]
    assert_equal 100.23, parser.data[0][:sparse_matmult]
    assert_equal 1000, parser.data[0][:sparse_matmult_n]
    assert_equal 5000, parser.data[0][:sparse_matmult_nz]
    assert_equal 141.55, parser.data[0][:lu]
    assert_equal 100, parser.data[0][:lu_m]
    assert_equal 100, parser.data[0][:lu_n]
  end
end
