require 'minitest/autorun'
require 'buildlogparser'

class SizeTest < Minitest::Test
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
end
