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
  module CMakeMakefileStdout
    class Parser < Parslet::Parser
      rule(:space)     { match['\s'] }
      rule(:space?)    { space.repeat }

      rule(:newline)   { str("\r").maybe >> str("\n") }
      rule(:restofline){ ( newline.absent? >> any ).repeat }

      rule(:path)      { match['[:alnum:]=\+\.\-_/'].repeat(1) }
      rule(:integer)   { match['0-9'].repeat(1) }

      rule(:percentage) { str("[") >> space? >> integer.as(:percentage) >> str("%]") }
      rule(:language)   { match['[:alnum:]'].repeat(1).as(:language) }
      rule(:targettype) do
        str("executable").as(:targettype) |
        (str("static").as(:targettype) >> str(" library")) |
        (str("shared").as(:targettype) >> str(" library")) |
        str("object").as(:targettype)
      end
      rule(:operation)  { (str("Building") | str("Linking")).as(:operation) }

      rule(:progressline) do
        percentage >> space?  >> operation >> space? >> language >> space? >> targettype >> space? >> path.as(:path) >> newline
      end
      rule(:scanningline) do
        str('Scanning dependencies of target ') >> path >> newline
      end
      rule(:targetendline) do
        percentage >> space?  >> str("Built target") >> space? >> path.as(:target) >> newline
      end

      rule(:outputend) {  progressline | targetendline }
      rule(:output)  { ( outputend.absent? >> any ).repeat.as(:output) }

      rule(:target) do
        scanningline.maybe >>
        (progressline >> output).repeat.as(:events) >>
        targetendline.as(:targetend)
      end

      rule(:start) { (target | (restofline >> newline | any).as(:drop)).repeat.as(:array) }
      root(:start)
    end # class Parser

    class Transform < Parslet::Transform
      rule(:drop => subtree(:tree)) { }
      rule(:events => subtree(:events), :targetend => subtree(:targetend)) do
        { :events => events, :name => String(targetend[:target])}
      end
      rule(:percentage => simple(:percentage), :operation => simple(:operation), :language => simple(:language), :targettype => simple(:targettype), :path => simple(:path), :output => subtree(:output)) do
        op   = String(operation).downcase.to_sym
        lang = String(language).downcase.to_sym
        outputstr = String(output)
        outputstr = "" if output.is_a?(Array) and output.size() == 0
        {:percentage => Integer(percentage), :operation => op, :language => lang, :targettype => targettype.to_sym, :path => String(path), :output => outputstr}
      end
      rule(:array => subtree(:tree)) { tree.compact.flatten }
    end # class Transform
  end # module CMakeMakefileStdout

  class CMakeParser < BuildLogParser::Parser
    attr_reader :targets

    def reset()
      super()
      @targets = []
    end

    def parseMakefileStdout(logtext)
      reset()
      @logtext = logtext
      parser = CMakeMakefileStdout::Parser.new
      tree = parser.parse(logtext)
      @targets = CMakeMakefileStdout::Transform.new.apply(tree)
    end
  end # class CMakeParser

  registerParser(:cmakeMakefileStdout, CMakeParser, :parseMakefileStdout)
end # module BuildLogParser
