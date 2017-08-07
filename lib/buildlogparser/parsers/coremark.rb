require 'parslet'

module BuildLogParser
  module Coremark
    class Parser < Parslet::Parser
      rule(:space)     { match['\s'] }
      rule(:space?)    { space.repeat }

      rule(:newline)   { str("\r").maybe >> str("\n") }
      rule(:restofline){ ( newline.absent? >> any ).repeat }

      rule(:integer)   { match['0-9'].repeat(1) }
      rule(:float)     { integer >> (match['\.,'] >> integer).maybe }

      rule(:event) do
        str('CoreMark Size') >> space? >> str(':') >> space? >> integer.as(:coremark_size) >> newline >>
        str('Total ticks') >> space? >> str(':') >> space? >> integer.as(:total_ticks) >> newline >>
        str('Total time (secs)') >> space? >> str(':') >> space? >> float.as(:time_sec) >> newline >>
        str('Iterations/Sec') >> space? >> str(':') >> space? >> float.as(:iterations_per_sec) >> newline >>
        str('Iterations') >> space? >> str(':') >> space? >> integer.as(:iterations) >> newline >>
        str('Compiler version') >> space? >> str(':') >> space? >> restofline.as(:compiler_version) >> newline >>
        str('Compiler flags') >> space? >> str(':') >> space? >> restofline.as(:compiler_flags) >> newline >>
        str('Memory location') >> space? >> str(':') >> space? >> restofline.as(:memory_location)
      end

      rule(:start) { (event | (restofline >> newline | any).as(:drop)).repeat.as(:array) }
      root(:start)
    end # class Parser

    class Transform < Parslet::Transform
      rule(:drop => subtree(:tree)) { }
      rule(:coremark_size => simple(:coremark_size), :total_ticks => simple(:total_ticks), :time_sec => simple(:time_sec), :iterations_per_sec => simple(:iterations_per_sec), :iterations => simple(:iterations), :compiler_version => simple(:compiler_version), :compiler_flags => simple(:compiler_flags), :memory_location => simple(:memory_location)) do
        { :coremark_size => Integer(coremark_size), :total_ticks => Integer(total_ticks), :time_sec => Float(time_sec), :iterations_per_sec => Float(iterations_per_sec), :iterations => Integer(iterations), :compiler_version => String(compiler_version), :compiler_flags => String(compiler_flags), :memory_location => String(memory_location) }
      end
      rule(:array => subtree(:tree)) { tree.compact.flatten }
    end # class Transform
  end # module Coremark

  class CoremarkParser < BuildLogParser::Parser
    attr_reader :data

    def reset()
      super()
       @data = []
    end

    def parse(logtext)
      reset()
      @logtext = logtext
      parser = Coremark::Parser.new
      tree = parser.parse(logtext)
      @data = Coremark::Transform.new.apply(tree)
    end
  end # class CMakeParser
end # module BuildLogParser
