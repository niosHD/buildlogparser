require 'parslet'

module BuildLogParser
  module SizeBerkeleyStdout
    class Parser < Parslet::Parser
      rule(:space)     { match['\s'] }
      rule(:space?)    { space.repeat }

      rule(:newline)   { str("\r").maybe >> str("\n") }
      rule(:restofline){ ( newline.absent? >> any ).repeat }

      rule(:path)      { match['[:alnum:]0-9=\+\.\-_/'].repeat(1) }
      rule(:integer)   { match['0-9'].repeat(1) }
      rule(:hexnumber) { match['a-fA-F0-9'].repeat(1) }

      rule(:header) do
        space? >> str('text') >> space? >> str('data') >> space? >>
        str('bss') >> space? >> str('dec') >> space? >> str('hex') >>
        space? >> str('filename') >> newline
      end

      rule(:event) do
        space? >> integer.as(:text) >> space? >> integer.as(:data) >> space? >>
        integer.as(:bss)  >> space? >> integer.as(:dec) >> space? >>
        hexnumber.as(:hex) >> space? >> path.as(:filename) >> newline
      end

      rule(:start) { ((header >> event.repeat(1)).as(:array) | (restofline >> newline | any).as(:drop)).repeat.as(:array) }
      root(:start)
    end # class Parser

    class Transform < Parslet::Transform
      rule(:drop => subtree(:tree)) { }
      rule(:text => simple(:text), :data => simple(:data), :bss => simple(:bss), :dec => simple(:dec), :hex => simple(:hex), :filename => simple(:filename)) do
        { :text => Integer(text), :data => Integer(data), :bss => Integer(bss), :total => Integer(dec), :filename => String(filename) }
      end
      rule(:array => subtree(:tree)) { tree.compact.flatten }
    end # class Transform
  end # module SizeBerkeleyStdout

  class SizeParser < BuildLogParser::Parser
    attr_reader :data

    def reset()
      super()
      @data       = []
    end

    def parseBerkeleyStdout(logtext)
      reset()
      @logtext = logtext
      parser = SizeBerkeleyStdout::Parser.new
      tree = parser.parse(logtext)
      @data = SizeBerkeleyStdout::Transform.new.apply(tree)
    end
  end # class SizeParser
end # module BuildLogParser
