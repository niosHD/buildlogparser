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

class SizeTest < Minitest::Test
  def test_berkeley_stdout_empty_input
    parser = BuildLogParser::SizeParser.new()

    logtext = ""
    parser.parseBerkeleyStdout(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 0, parser.data.size()
  end

  def test_berkeley_stdout_no_match
    parser = BuildLogParser::SizeParser.new()

    logtext = "this\nstring\ndoes\nnot\ncontain\nsize\noutput"
    parser.parseBerkeleyStdout(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 0, parser.data.size()
  end

  def test_berkeley_stdout_one_line
    parser = BuildLogParser::SizeParser.new()

    logtext = IO.read(File.expand_path('../size/berkeley_stdout_one_line.txt', __FILE__))
    parser.parseBerkeleyStdout(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 1, parser.data.size()

    assert_equal 4960, parser.data[0][:text]
    assert_equal 72, parser.data[0][:data]
    assert_equal 64, parser.data[0][:bss]
    assert_equal 5096, parser.data[0][:total]
    assert_equal "aes", parser.data[0][:filename]
  end

  def test_berkeley_stdout_garbage_before
    parser = BuildLogParser::SizeParser.new()

    logtext = IO.read(File.expand_path('../size/berkeley_stdout_garbage_before.txt', __FILE__))
    parser.parseBerkeleyStdout(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 1, parser.data.size()

    assert_equal 4960, parser.data[0][:text]
    assert_equal 72, parser.data[0][:data]
    assert_equal 64, parser.data[0][:bss]
    assert_equal 5096, parser.data[0][:total]
    assert_equal "aes", parser.data[0][:filename]
  end

  def test_berkeley_stdout_garbage_behind
    parser = BuildLogParser::SizeParser.new()

    logtext = IO.read(File.expand_path('../size/berkeley_stdout_garbage_behind.txt', __FILE__))
    parser.parseBerkeleyStdout(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 1, parser.data.size()

    assert_equal 4960, parser.data[0][:text]
    assert_equal 72, parser.data[0][:data]
    assert_equal 64, parser.data[0][:bss]
    assert_equal 5096, parser.data[0][:total]
    assert_equal "aes", parser.data[0][:filename]
  end

  def test_berkeley_stdout_multi_line
    parser = BuildLogParser::SizeParser.new()

    logtext = IO.read(File.expand_path('../size/berkeley_stdout_multi_line.txt', __FILE__))
    parser.parseBerkeleyStdout(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 3, parser.data.size()

    assert_equal 4960, parser.data[0][:text]
    assert_equal 72, parser.data[0][:data]
    assert_equal 64, parser.data[0][:bss]
    assert_equal 5096, parser.data[0][:total]
    assert_equal "aes", parser.data[0][:filename]

    assert_equal 12656, parser.data[1][:text]
    assert_equal 72, parser.data[1][:data]
    assert_equal 68, parser.data[1][:bss]
    assert_equal 12796, parser.data[1][:total]
    assert_equal "bigen", parser.data[1][:filename]

    assert_equal 952, parser.data[2][:text]
    assert_equal 72, parser.data[2][:data]
    assert_equal 64, parser.data[2][:bss]
    assert_equal 1088, parser.data[2][:total]
    assert_equal "indcall", parser.data[2][:filename]
  end

  def test_berkeley_stdout_subdirs
    parser = BuildLogParser::SizeParser.new()

    logtext = IO.read(File.expand_path('../size/berkeley_stdout_subdirs.txt', __FILE__))
    parser.parseBerkeleyStdout(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 3, parser.data.size()

    assert_equal 308, parser.data[0][:text]
    assert_equal 76, parser.data[0][:data]
    assert_equal 64, parser.data[0][:bss]
    assert_equal 448, parser.data[0][:total]
    assert_equal "src/simpleadd", parser.data[0][:filename]

    assert_equal 120, parser.data[1][:text]
    assert_equal 64, parser.data[1][:data]
    assert_equal 0, parser.data[1][:bss]
    assert_equal 184, parser.data[1][:total]
    assert_equal "arch/RV32IMXIE/RV32IMXIE_CF_direct_call", parser.data[1][:filename]

    assert_equal 12284, parser.data[2][:text]
    assert_equal 84, parser.data[2][:data]
    assert_equal 2132, parser.data[2][:bss]
    assert_equal 14500, parser.data[2][:total]
    assert_equal "coremark_v1.0/coremark", parser.data[2][:filename]
  end

  def test_berkeley_stdout_multiple
    parser = BuildLogParser::SizeParser.new()

    logtext = IO.read(File.expand_path('../size/berkeley_stdout_multiple.txt', __FILE__))
    parser.parseBerkeleyStdout(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 20, parser.data.size()
  end
end
