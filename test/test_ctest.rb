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

class CTestTest < Minitest::Test
  def test_stdout_empty_input
    parser = BuildLogParser::CTestParser.new()

    logtext = ""
    parser.parseStdout(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 0, parser.errors
    assert_equal 0, parser.data.size()
  end

  def test_stdout_no_match
    parser = BuildLogParser::CTestParser.new()

    logtext = "this\nstring\ndoes\nnot\ncontain\nctest\noutput"
    parser.parseStdout(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 0, parser.errors
    assert_equal 0, parser.data.size()
  end

  def test_stdout_success
    parser = BuildLogParser::CTestParser.new()

    logtext = IO.read(File.expand_path('../ctest/stdout_success.txt', __FILE__))
    parser.parseStdout(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 0, parser.errors
    assert_equal 6, parser.data.size()

    assert_equal 1, parser.data[0][:nr]
    assert_equal 6, parser.data[0][:total_nr]
    assert_equal "simpleadd", parser.data[0][:name]
    assert_equal :passed, parser.data[0][:result]
    assert_equal 0.0, parser.data[0][:time_sec]

    assert_equal 6, parser.data[5][:nr]
    assert_equal 6, parser.data[5][:total_nr]
    assert_equal "coremark", parser.data[5][:name]
    assert_equal :passed, parser.data[5][:result]
    assert_equal 14.16, parser.data[5][:time_sec]
  end

  def test_stdout_timeout
    parser = BuildLogParser::CTestParser.new()

    logtext = IO.read(File.expand_path('../ctest/stdout_timeout.txt', __FILE__))
    parser.parseStdout(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 1, parser.errors
    assert_equal 20, parser.data.size()

    assert_equal 1, parser.data[0][:nr]
    assert_equal 20, parser.data[0][:total_nr]
    assert_equal "RV32IMXIE_CF_endless_loop", parser.data[0][:name]
    assert_equal :timeout, parser.data[0][:result]
    assert_equal 5.0, parser.data[0][:time_sec]
  end

  def test_stdout_regex_error
    parser = BuildLogParser::CTestParser.new()

    logtext = IO.read(File.expand_path('../ctest/stdout_regex_error.txt', __FILE__))
    parser.parseStdout(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 2, parser.errors
    assert_equal 6, parser.data.size()

    assert_equal 3, parser.data[2][:nr]
    assert_equal 6, parser.data[2][:total_nr]
    assert_equal "dhrystone", parser.data[2][:name]
    assert_equal :timeout, parser.data[2][:result]
    assert_equal 180.01, parser.data[2][:time_sec]

    assert_equal 6, parser.data[5][:nr]
    assert_equal 6, parser.data[5][:total_nr]
    assert_equal "coremark", parser.data[5][:name]
    assert_equal :failed, parser.data[5][:result]
    assert_equal 4.92, parser.data[5][:time_sec]
  end


  def test_log_empty_input
    parser = BuildLogParser::CTestParser.new()

    logtext = ""
    parser.parseLog(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 0, parser.errors
    assert_equal 0, parser.data.size()
  end

  def test_log_no_match
    parser = BuildLogParser::CTestParser.new()

    logtext = "this\nstring\ndoes\nnot\ncontain\nctest\noutput"
    parser.parseLog(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 0, parser.errors
    assert_equal 0, parser.data.size()
  end

  def test_log_success
    parser = BuildLogParser::CTestParser.new()

    logtext = IO.read(File.expand_path('../ctest/log_success.log', __FILE__))
    parser.parseLog(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 0, parser.errors
    assert_equal 2, parser.data.size()

    assert_equal 4, parser.data[0][:nr]
    assert_equal 6, parser.data[0][:total_nr]
    assert_equal "indcall", parser.data[0][:name]
    assert_equal ["/home/mwerner/Projekte/sce/test_programs/_build/src/indcall"], parser.data[0][:command]
    assert_equal "/home/mwerner/Projekte/sce/test_programs/_build/src", parser.data[0][:directory]
    assert_equal "Jul 24 08:41 CEST", parser.data[0][:starttime]
    assert_equal "textA\ntextB", parser.data[0][:output]
    assert_equal 1.12, parser.data[0][:time_sec]
    assert_equal :passed, parser.data[0][:result]
    assert_equal "Jul 24 08:42 CEST", parser.data[0][:endtime]
    assert_equal "00:00:01", parser.data[0][:time]

    assert_equal 5, parser.data[1][:nr]
    assert_equal 6, parser.data[1][:total_nr]
    assert_equal "aes", parser.data[1][:name]
    assert_equal ["/home/mwerner/Projekte/sce/test_programs/_build/src/aes"], parser.data[1][:command]
    assert_equal "/home/mwerner/Projekte/sce/test_programs/_build/src", parser.data[1][:directory]
    assert_equal "Jul 24 08:42 CEST", parser.data[1][:starttime]
    assert_equal 2.34, parser.data[1][:time_sec]
    assert_equal :passed, parser.data[1][:result]
    assert_equal "Jul 24 08:44 CEST", parser.data[1][:endtime]
    assert_equal "00:00:02", parser.data[1][:time]
  end

  def test_log_success_no_output
    parser = BuildLogParser::CTestParser.new()

    logtext = IO.read(File.expand_path('../ctest/log_success_no_output.log', __FILE__))
    parser.parseLog(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 0, parser.errors
    assert_equal 3, parser.data.size()

    assert_equal 1, parser.data[0][:nr]
    assert_equal 6, parser.data[0][:total_nr]
    assert_equal "simpleadd", parser.data[0][:name]
    assert_equal ["/home/mwerner/Projekte/sce/test_programs/_build/src/simpleadd"], parser.data[0][:command]
    assert_equal "/home/mwerner/Projekte/sce/test_programs/_build/src", parser.data[0][:directory]
    assert_equal "Jul 24 08:43 CEST", parser.data[0][:starttime]
    assert_equal "", parser.data[0][:output]
    assert_equal 0.0, parser.data[0][:time_sec]
    assert_equal :passed, parser.data[0][:result]
    assert_equal "Jul 24 08:43 CEST", parser.data[0][:endtime]
    assert_equal "00:00:00", parser.data[0][:time]
  end

  def test_log_success_complex_command
    parser = BuildLogParser::CTestParser.new()

    logtext = IO.read(File.expand_path('../ctest/log_success_complex_command.log', __FILE__))
    parser.parseLog(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 0, parser.errors
    assert_equal 2, parser.data.size()

    assert_equal 18, parser.data[0][:nr]
    assert_equal 20, parser.data[0][:total_nr]
    assert_equal "indcall", parser.data[0][:name]
    assert_equal ["/opt/tmp/install/sce-riscv/bin/spike", "--isa=rv32imxie", "/home/mwerner/Projekte/sce/test_programs/_build/src/indcall"], parser.data[0][:command]
    assert_equal "/home/mwerner/Projekte/sce/test_programs/_build/src", parser.data[0][:directory]
    assert_equal "Jul 24 08:44 CEST", parser.data[0][:starttime]
    assert_equal 0.45, parser.data[0][:time_sec]
    assert_equal :passed, parser.data[0][:result]
    assert_equal "Jul 24 08:44 CEST", parser.data[0][:endtime]
    assert_equal "00:00:00", parser.data[0][:time]

    assert_equal 19, parser.data[1][:nr]
    assert_equal 20, parser.data[1][:total_nr]
    assert_equal "aes", parser.data[1][:name]
    assert_equal ["/opt/tmp/install/sce-riscv/bin/spike", "--isa=rv32imxie", "/home/mwerner/Projekte/sce/test_programs/_build/src/aes"], parser.data[1][:command]
    assert_equal "/home/mwerner/Projekte/sce/test_programs/_build/src", parser.data[1][:directory]
    assert_equal "Jul 24 08:44 CEST", parser.data[1][:starttime]
    assert_equal 11.98, parser.data[1][:time_sec]
    assert_equal :passed, parser.data[1][:result]
    assert_equal "Jul 24 08:45 CEST", parser.data[1][:endtime]
    assert_equal "00:00:11", parser.data[1][:time]
  end

  def test_log_failed_complex_command
    parser = BuildLogParser::CTestParser.new()

    logtext = IO.read(File.expand_path('../ctest/log_failed_complex_command.log', __FILE__))
    parser.parseLog(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 1, parser.errors
    assert_equal 2, parser.data.size()

    assert_equal 1, parser.data[0][:nr]
    assert_equal 20, parser.data[0][:total_nr]
    assert_equal "RV32IMXIE_CF_endless_loop", parser.data[0][:name]
    assert_equal ["/opt/tmp/install/sce-riscv/bin/spike", "--isa=rv32imxie", "/home/mwerner/Projekte/sce/test_programs/_build/arch/RV32IMXIE/RV32IMXIE_CF_endless_loop"], parser.data[0][:command]
    assert_equal "/home/mwerner/Projekte/sce/test_programs/_build/arch/RV32IMXIE", parser.data[0][:directory]
    assert_equal "Jul 24 10:46 CEST", parser.data[0][:starttime]
    assert_equal "", parser.data[0][:output]
    assert_equal 5.0, parser.data[0][:time_sec]
    assert_equal :failed, parser.data[0][:result]
    assert_equal "Jul 24 10:46 CEST", parser.data[0][:endtime]
    assert_equal "00:00:05", parser.data[0][:time]

    assert_equal 3, parser.data[1][:nr]
    assert_equal 20, parser.data[1][:total_nr]
    assert_equal "RV32IMXIE_CF_loop", parser.data[1][:name]
    assert_equal ["/opt/tmp/install/sce-riscv/bin/spike", "--isa=rv32imxie", "/home/mwerner/Projekte/sce/test_programs/_build/arch/RV32IMXIE/RV32IMXIE_CF_loop"], parser.data[1][:command]
    assert_equal "/home/mwerner/Projekte/sce/test_programs/_build/arch/RV32IMXIE", parser.data[1][:directory]
    assert_equal "Jul 24 10:46 CEST", parser.data[1][:starttime]
    assert_equal 0.0, parser.data[1][:time_sec]
    assert_equal :passed, parser.data[1][:result]
    assert_equal "Jul 24 10:46 CEST", parser.data[1][:endtime]
    assert_equal "00:00:00", parser.data[1][:time]
  end

  def test_log_regex_error
    parser = BuildLogParser::CTestParser.new()

    logtext = IO.read(File.expand_path('../ctest/log_regex_error.log', __FILE__))
    parser.parseLog(logtext)
    assert_equal logtext, parser.logtext
    assert_equal 2, parser.errors
    assert_equal 6, parser.data.size()

    assert_equal 3, parser.data[2][:nr]
    assert_equal 6, parser.data[2][:total_nr]
    assert_equal "dhrystone", parser.data[2][:name]
    assert_equal ["/home/mwerner/Projekte/sce/test_programs/scripts/run_remote.rb", "/home/mwerner/Projekte/sce/test_programs/_build/src/dhrystone"], parser.data[2][:command]
    assert_equal "/home/mwerner/Projekte/sce/test_programs/_build/src", parser.data[2][:directory]
    assert_equal "Aug 07 14:26 CEST", parser.data[2][:starttime]
    assert_equal "Uploading Elf '/home/mwerner/Projekte/sce/test_programs/_build/src/dhrystone'\nExecuting commands:\n[\"source /home/mariowe/setup_pulpino.sh\",\n \"/home/mariowe/run_pulpino.py /home/mariowe/dhrystone\"]", parser.data[2][:output]
    assert_equal 180.01, parser.data[2][:time_sec]
    assert_equal :failed, parser.data[2][:result]
    assert_equal "Aug 07 14:29 CEST", parser.data[2][:endtime]
    assert_equal "00:03:00", parser.data[2][:time]

    assert_equal 6, parser.data[5][:nr]
    assert_equal 6, parser.data[5][:total_nr]
    assert_equal "coremark", parser.data[5][:name]
    assert_equal ["/home/mwerner/Projekte/sce/test_programs/scripts/run_remote.rb", "/home/mwerner/Projekte/sce/test_programs/_build/coremark_v1.0/coremark"], parser.data[5][:command]
    assert_equal "/home/mwerner/Projekte/sce/test_programs/_build/coremark_v1.0", parser.data[5][:directory]
    assert_equal "Aug 07 14:29 CEST", parser.data[5][:starttime]
    assert_equal 4.85, parser.data[5][:time_sec]
    assert_equal :failed, parser.data[5][:result]
    assert_equal "Aug 07 14:30 CEST", parser.data[5][:endtime]
    assert_equal "00:00:04", parser.data[5][:time]
  end
end
