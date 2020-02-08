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
require 'parslet'

module BuildLogParser
  module LmbenchLatMemRd
    class Parser < Parslet::Parser
      rule(:space)     { match['\s'] }
      rule(:space?)    { space.repeat }

      rule(:newline)   { str("\r").maybe >> str("\n") }
      rule(:restofline){ ( newline.absent? >> any ).repeat }

      rule(:integer)   { match['0-9'].repeat(1) }
      rule(:float)     { integer >> (match['\.,'] >> integer).maybe }

      rule(:kvpair)    { float.as(:key) >> space? >> float.as(:value) }

      rule(:target) do
        str('"stride=') >> integer.as(:stride) >> newline >>
          (kvpair >> newline.maybe).repeat.as(:numbers)
      end

      rule(:start) { (target | (restofline >> newline | any).as(:drop)).repeat.as(:array) }
      root(:start)
    end # class Parser

    class Transform < Parslet::Transform
      rule(:drop => subtree(:tree)) { }
      rule(:stride => simple(:stride), :numbers => subtree(:numbers)) do
        result = { :stride => Integer(stride) }
        numbers.each { |e| result[Float(e[:key])] = Float(e[:value]) }
        result
      end
      rule(:array => subtree(:tree)) { tree.compact.flatten }
    end # class Transform
  end # module LmbenchLatMemRd

  class LmbenchParser < BuildLogParser::Parser
    attr_reader :data

    def reset()
      super()
      @data = []
    end

    def parseLatMemRd(logtext)
      reset()
      @logtext = logtext
      parser = LmbenchLatMemRd::Parser.new
      tree = parser.parse(logtext)
      @data = LmbenchLatMemRd::Transform.new.apply(tree)
    end
  end # class LmbenchParser

  registerParser(:lmbenchLatMemRd, LmbenchParser, :parseLatMemRd)
end # module BuildLogParser
