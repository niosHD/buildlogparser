#
# Copyright (C) 2019 Mario Werner <nioshd@gmail.com>
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

# FIXME Currently just parsed as simple table. Extend the parser to extract the hierarchy.
module BuildLogParser
  module EncounterArea
    class Parser < Parslet::Parser
      rule(:space)     { match[' '] }
      rule(:space?)    { space.repeat }

      rule(:newline)   { str("\r").maybe >> str("\n") }
      rule(:restofline){ ( newline.absent? >> any ).repeat }

      rule(:integer)   { match['0-9'].repeat(1) }
      rule(:name)      { match['[:alnum:]=\+\.\-_\:'].repeat(1) }

      rule(:tableentry) do
        name.as(:instance) >> space? >> integer.as(:cells) >> space? >>
        integer.as(:cell_area) >> space? >> integer.as(:net_area) >> space? >>
        integer.as(:total_area)
      end

      rule(:tableheader) do
        space? >> str('Instance') >>  space? >> str('Cells') >> space? >> str('Cell Area') >>
            space? >> str('Net Area') >> space? >> str('Total Area') >> space? >> newline >>
        str("---------------------------------------------------------------------------------------------------") >> newline
      end

      rule(:entries) do
        tableheader >> (space? >> tableentry >> space? >> newline).repeat.as(:numbers)
      end

      rule(:start) { (entries | (restofline >> newline | any).as(:drop)).repeat.as(:array) }
      root(:start)
    end # class Parser

    class Transform < Parslet::Transform
      rule(:drop => subtree(:tree)) { }
      rule(:instance => simple(:instance), :cells => simple(:cells), :cell_area => simple(:cell_area), :net_area => simple(:net_area), :total_area => simple(:total_area)) do
        { :instance => String(instance), :cells => Integer(cells), :cell_area => Integer(cell_area), :net_area => Integer(net_area), :total_area => Integer(total_area) }
      end
      rule(:numbers => subtree(:tree)) { tree }
      rule(:array => subtree(:tree)) { tree.compact.flatten }
    end # class Transform
  end # module EncounterArea

  class EncounterAreaParser < BuildLogParser::Parser
    attr_reader :data

    def reset()
      super()
      @data = []
    end

    def parseStats(logtext)
      reset()
      @logtext = logtext
      parser = EncounterArea::Parser.new
      tree = parser.parse(logtext)
      @data = EncounterArea::Transform.new.apply(tree)
    end
  end # class EncounterAreaParser

  registerParser(:encounterArea, EncounterAreaParser, :parseStats)
end # module BuildLogParser
