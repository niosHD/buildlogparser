require 'helper'

class DhrystoneTest < Minitest::Test
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
