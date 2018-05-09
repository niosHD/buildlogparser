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
require 'yaml'

class LLDTest < Minitest::Test
  def parseMap_file_template(mapFilename)
    parser = BuildLogParser::LLDParser.new()

    logtext = IO.read(File.expand_path("../lld/#{mapFilename}.map", __FILE__))
    parser.parseMap(logtext)
    assert_equal logtext, parser.logtext

    expected = YAML.load_file(File.expand_path("../lld/#{mapFilename}.yaml", __FILE__))
    assert_equal expected, parser.data
  end

  def test_lld_map_empty_input
    parser = BuildLogParser::LLDParser.new()

    logtext = ""
    parser.parseMap(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 0, parser.data.size()
  end

  def test_lld_map_no_match
    parser = BuildLogParser::LLDParser.new()

    logtext = "this\nstring\ndoes\nnot\ncontain\nlld\noutput"
    parser.parseMap(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 0, parser.data.size()
  end

  def test_empty_main_x86_64
    parseMap_file_template("empty_main_x86_64")
  end

  def test_printf_hello_world_x86_64
    parseMap_file_template("printf_hello_world_x86_64")
  end

  def test_puts_hello_world_x86_64
    parseMap_file_template("puts_hello_world_x86_64")
  end
end
