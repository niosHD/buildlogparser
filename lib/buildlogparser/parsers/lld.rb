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
  module LLDMap
    class Parser < Parslet::Parser
      rule(:space)     { match['\s'] }
      rule(:space?)    { space.repeat }

      rule(:newline)   { str("\r").maybe >> str("\n") }
      rule(:restofline){ ( newline.absent? >> any ).repeat }

      rule(:path)      { match['[:alnum:]=\+\.\-_/<>'].repeat(1) }
      rule(:integer)   { match['0-9'].repeat(1) }
      rule(:hexnumber) { match['a-fA-F0-9'].repeat(1) }

      rule(:section)   { match['[:alnum:]\-_\.'].repeat(1) }
      rule(:symbol)    { match['[:alnum:]_'] >> match['[:alnum:]\-_\.'].repeat }
      rule(:infile)    {  }

      rule(:header) do
        str('Address') >> space? >> str('Size') >> space? >>
        str('Align') >> space? >> str('Out') >> space? >> str('In') >>
        space? >> str('Symbol') >> newline
      end

      rule(:line_prefix) do
        hexnumber.as(:address) >> space? >> hexnumber.as(:size) >> space? >>
        integer.as(:align)
      end

      rule(:sym_entry) do
        line_prefix >> space? >> symbol.as(:name) >> newline
      end

      rule(:in_section_entry) do
        line_prefix >> space? >> path.as(:source_file) >> (  str("(") >>
        path.as(:source_sub_file) >> str(")") ).maybe  >> str(":(") >>
        section.as(:source_section) >> str(")") >> newline >> sym_entry.repeat.as(:symbols)
      end

      rule(:out_section_entry) do
        line_prefix >> match['\s'] >> section.as(:out) >> newline >> in_section_entry.repeat.as(:inputs)
      end

      rule(:start) { ((header >> out_section_entry.repeat(1)).as(:array) | (restofline >> newline | any).as(:drop)).repeat.as(:array) }
      root(:start)
    end # class Parser

    class Transform < Parslet::Transform
      rule(:drop => subtree(:tree)) { }
      rule(:address => simple(:address), :size => simple(:size), :align => simple(:align), :name => simple(:name)) do
        { :address => String(address).to_i(16), :size => String(size).to_i(16), :align => Integer(align), :name => String(name) }
      end
      rule(:address => simple(:address), :size => simple(:size), :align => simple(:align), :source_file => simple(:source_file), :source_section => simple(:source_section), :symbols => subtree(:symbols)) do
        { :address => String(address).to_i(16), :size => String(size).to_i(16), :align => Integer(align), :source_file => String(source_file), :source_section => String(source_section), :symbols => symbols }
      end
      rule(:address => simple(:address), :size => simple(:size), :align => simple(:align), :source_file => simple(:source_file), :source_sub_file => simple(:source_sub_file), :source_section => simple(:source_section), :symbols => subtree(:symbols)) do
        { :address => String(address).to_i(16), :size => String(size).to_i(16), :align => Integer(align), :source_file => String(source_file), :source_sub_file => String(source_sub_file), :source_section => String(source_section), :symbols => symbols }
      end
      rule(:address => simple(:address), :size => simple(:size), :align => simple(:align), :out => simple(:out), :inputs => subtree(:inputs)) do
        { :address => String(address).to_i(16), :size => String(size).to_i(16), :align => Integer(align), :out => String(out), :inputs => inputs }
      end
      rule(:array => subtree(:tree)) { tree.compact.flatten }
    end # class Transform
  end # module LLDMap

  class LLDParser < BuildLogParser::Parser
    attr_reader :data

    def reset()
      super()
      @data       = []
    end

    def parseMap(logtext)
      reset()
      @logtext = logtext
      parser = LLDMap::Parser.new
      tree = parser.parse(logtext)
      @data = LLDMap::Transform.new.apply(tree)
    end
  end # class LLDParser

  registerParser(:lldMap, LLDParser, :parseMap)
end # module BuildLogParser
