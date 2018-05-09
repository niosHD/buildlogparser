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

class RegistryTest < Minitest::Test
  def template(name, parser_class)
    parser = BuildLogParser.getParser(name)
    assert_instance_of parser_class, parser
    assert_equal [], BuildLogParser.parse(name, parser, "")
  end

  def test_get_names
    assert_equal BuildLogParser.getParserNames.sort, [:cmakeMakefileStdout,
                                                      :coremark,
                                                      :ctestStdout,
                                                      :ctestLog,
                                                      :dhrystone,
                                                      :lldMap,
                                                      :sizeBerkeleyStdout].sort
  end

  def test_cmake_parser_entry
    template(:cmakeMakefileStdout, BuildLogParser::CMakeParser)
  end

  def test_coremark_parser_entry
    template(:coremark, BuildLogParser::CoremarkParser)
  end

  def test_ctest_parser_entry
    template(:ctestStdout, BuildLogParser::CTestParser)
    template(:ctestLog, BuildLogParser::CTestParser)
  end

  def test_dhrystone_parser_entry
    template(:dhrystone, BuildLogParser::DhrystoneParser)
  end

  def test_lld_parser_entry
    template(:lldMap, BuildLogParser::LLDParser)
  end

  def test_size_parser_entry
    template(:sizeBerkeleyStdout, BuildLogParser::SizeParser)
  end
end
