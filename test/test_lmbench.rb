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

class LmbenchTest < Minitest::Test
  def test_lat_mem_rd_empty_input
    parser = BuildLogParser::LmbenchParser.new()

    logtext = ""
    parser.parseLatMemRd(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 0, parser.data.size()
  end

  def test_lat_mem_rd_no_match
    parser = BuildLogParser::LmbenchParser.new()

    logtext = "this\nstring\ndoes\nnot\ncontain\nlmbench\noutput"
    parser.parseLatMemRd(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 0, parser.data.size()
  end

  def test_lat_mem_rd
    parser = BuildLogParser::LmbenchParser.new()

    logtext = IO.read(File.expand_path('../lmbench/lat_mem_rd.txt', __FILE__))
    parser.parseLatMemRd(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 1, parser.data.size()

    assert_equal 32, parser.data[0][:stride]
    assert_equal 2.066, parser.data[0][0.00049]
    assert_equal 2.066, parser.data[0][0.00098]
    assert_equal 2.066, parser.data[0][0.00195]
    assert_equal 2.065, parser.data[0][0.00293]
    assert_equal 2.050, parser.data[0][0.00391]
    assert_equal 2.050, parser.data[0][0.00586]
    assert_equal 2.045, parser.data[0][0.00781]
    assert_equal 2.043, parser.data[0][0.01172]
    assert_equal 2.040, parser.data[0][0.01562]
    assert_equal 2.040, parser.data[0][0.02344]
    assert_equal 2.043, parser.data[0][0.03125]
    assert_equal 14.076, parser.data[0][0.04688]
    assert_equal 14.075, parser.data[0][0.06250]
    assert_equal 14.074, parser.data[0][0.09375]
    assert_equal 14.074, parser.data[0][0.12500]
    assert_equal 14.074, parser.data[0][0.18750]
    assert_equal 14.081, parser.data[0][0.25000]
    assert_equal 14.262, parser.data[0][0.37500]
    assert_equal 15.855, parser.data[0][0.50000]
    assert_equal 85.382, parser.data[0][0.75000]
    assert_equal 85.364, parser.data[0][1.00000]
    assert_equal 85.353, parser.data[0][1.50000]
    assert_equal 85.351 , parser.data[0][2.00000]
  end
end
