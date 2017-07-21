require 'minitest/autorun'
require 'buildlogparser'

require 'pp'

class CTestTest < Minitest::Test
  def test_stdout_timeout
    parser = BuildLogParser::CTestParser.new()

    logtext = IO.read(File.expand_path('../ctest/stdout_timeout.txt', __FILE__))
    parser.parseStdout(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 1, parser.errors
    assert_equal 20, parser.test_count
    assert_equal "RV32IMXIE_CF_endless_loop", parser.data[0][:name]
    assert_equal "timeout", parser.data[0][:result]
    assert_equal 5.0, parser.data[0][:time]
  end
end
