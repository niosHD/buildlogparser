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
require 'parslet'

module BuildLogParser
  module CTestStdout
    class Parser < Parslet::Parser
      rule(:space)     { match['\s'] }
      rule(:space?)    { space.repeat }

      rule(:newline)   { str("\r").maybe >> str("\n") }
      rule(:anyline) do
        ( newline.absent? >> any ).repeat >> newline |
        ( newline.absent? >> any ).repeat(1)
      end

      rule(:letters)   { match['[:alnum:]\+\.\-_'].repeat(1) }
      rule(:integer)   { match['0-9'].repeat(1) }
      rule(:float)     { integer >> (match['\.,'] >> integer).maybe }

      rule(:regexError) { str('Required regular expression not found.Regex=[') >> match['^\]'].repeat(1) >> str(']') >> space? }

      rule(:event) do
        space? >> integer.as(:nr) >> str('/') >> integer.as(:total_nr) >> space? >> str('Test') >> space? >> str('#') >>
        integer >> str(': ') >> letters.as(:name) >> match['\.*\s'].repeat(1) >> letters.as(:result) >> space? >> regexError.maybe >>
        float.as(:time_sec) >> anyline
      end

      rule(:start)    { (event | anyline.as(:drop)).repeat.as(:array) }
      root(:start)
    end # class Parser

    class Transform < Parslet::Transform
      rule(:drop => subtree(:tree)) { }
      rule(:nr => simple(:nr), :total_nr => simple(:total_nr), :name => simple(:name), :result => simple(:result), :time_sec => simple(:time_sec) ) do
        { :nr => Integer(nr), :total_nr => Integer(total_nr), :name => String(name), :result => String(result).downcase!.to_sym, :time_sec => Float(time_sec) }
      end
      rule(:array => subtree(:tree)) { tree.is_a?(Array) ? tree.compact : [ tree ]  }
    end # class Transform
  end # module CTestStdout

  module CTestLog
    class Parser < Parslet::Parser
      rule(:space)     { match('\s').repeat(1) }
      rule(:space?)    { space.maybe }

      rule(:newline)   { str("\r").maybe >> str("\n") }
      rule(:restofline){ ( newline.absent? >> any ).repeat }
      rule(:anyline) do
        restofline >> newline |
        ( newline.absent? >> any ).repeat(1)
      end

      rule(:letters)   { match['[:alnum:]'].repeat(1) }
      rule(:path)      { match['[:alnum:]=\+\.\-_/'].repeat(1) }
      rule(:integer)   { match['0-9'].repeat(1) }
      rule(:float)     { integer >> (match['\.,'] >> integer).maybe }

      rule(:endofoutput) { newline.maybe >> str('<end of output>') >> newline }
      rule(:output)      { ( endofoutput.absent? >> any ).repeat }
      rule(:endtime) { str('end time: ') >> restofline.as(:endtime) }

      rule(:quotedcommand) { str('"') >> path.as(:commandstring) >> str('"') }
      rule(:commandlist) { quotedcommand >> (space >> quotedcommand).repeat }

      rule(:event) do
        integer.as(:nr) >> str('/') >> integer.as(:total_nr) >> str(' Test: ') >> path.as(:name) >> newline >>
        str('Command: ')  >> commandlist.as(:command) >> newline >>
        str('Directory: ') >> path.as(:directory) >> newline >>
        str('"') >> path >> str('" start time: ') >> restofline.as(:starttime) >> newline >>
        str('Output:') >> newline >>
        str('----------------------------------------------------------') >> newline >>
        output.as(:output) >>
        endofoutput >>
        str('Test time =')>> space? >> float.as(:time_sec) >> str(' sec') >> newline >>
        str('----------------------------------------------------------') >> newline >>
        str('Test ') >> letters.as(:result) >>
        ( endtime.absent? >> any ).repeat >> endtime >> newline >>
        str('"') >> path >> str('" time elapsed: ') >> restofline.as(:time) >> newline >>
        str('----------------------------------------------------------') >> newline
      end

      rule(:start) { (event | anyline.as(:drop)).repeat.as(:array) }
      root(:start)
    end # class Parser

    class Transform < Parslet::Transform
      rule(:drop => subtree(:tree)) { }
      rule(:nr => simple(:nr), :total_nr => simple(:total_nr), :name => simple(:name), :command => subtree(:command), :directory => simple(:directory), :starttime => simple(:starttime), :output => subtree(:output), :time_sec => simple(:time_sec), :result => simple(:result), :endtime => simple(:endtime), :time => simple(:time) ) do
        result_symb = :failed
        result_symb = :passed if result == 'Pass' || result == 'Passed'
        outputstr =  String(output)
        outputstr = "" if output.is_a?(Array) and output.size() == 0
        commandarray = command
        commandarray = [ command ] if not command.is_a?(Array)
        { :nr => Integer(nr), :total_nr => Integer(total_nr), :name => String(name), :command => commandarray, :directory => String(directory), :starttime => String(starttime), :output => outputstr, :time_sec => Float(time_sec), :result => result_symb, :endtime => String(endtime), :time => String(time) }
      end
      rule(:commandstring => simple(:commandstring)) { String(commandstring) }
      rule(:array => subtree(:tree)) { tree.is_a?(Array) ? tree.compact : [ tree ]  }
    end # class Transform
  end # module CTestLog

  class CTestParser < BuildLogParser::Parser
    attr_reader :data
    attr_reader :errors

    def reset()
      super()
      @data       = []
      @errors     = 0
    end

    def parseStdout(logtext)
      reset()
      @logtext = logtext
      parser = CTestStdout::Parser.new
      tree = parser.parse(logtext)
      @data = CTestStdout::Transform.new.apply(tree)

      @data.each do |event|
        @errors += 1 unless event[:result] == :passed
      end
      return @data
    end

    def parseLog(logtext)
      reset()
      @logtext = logtext
      parser = CTestLog::Parser.new
      tree = parser.parse(logtext)
      @data = CTestLog::Transform.new.apply(tree)

      @data.each do |event|
        @errors += 1 unless event[:result] == :passed
      end
      return @data
    end
  end # class CTestParser

  registerParser(:ctestStdout, CTestParser, :parseStdout)
  registerParser(:ctestLog, CTestParser, :parseLog)
end # module BuildLogParser
