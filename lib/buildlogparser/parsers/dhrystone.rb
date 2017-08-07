require 'parslet'

module BuildLogParser
  module Dhrystone
    class Parser < Parslet::Parser
      rule(:space)     { match['\s'] }
      rule(:space?)    { space.repeat }

      rule(:newline)   { str("\r").maybe >> str("\n") }
      rule(:restofline){ ( newline.absent? >> any ).repeat }

      rule(:path)      { match['[:alnum:]0-9=\+\.\-_/'].repeat(1) }
      rule(:integer)   { match['0-9'].repeat(1) }
      rule(:float)     { integer >> (match['\.,'] >> integer).maybe }

      rule(:version) { str('Version') >> space? >> float.as(:version) }
      rule(:run)     { integer.as(:run) >> space? >> str('runs through Dhrystone') }
      rule(:usec_per_run)       { str('Microseconds for one run through Dhrystone:') >> space? >> float.as(:usec_per_run) }
      rule(:dhrystones_per_sec) { str('Dhrystones per Second:')  >> space? >> float.as(:dhrystones_per_sec) }
      rule(:total_ticks)        { str('Total ticks:') >> space? >> integer.as(:total_ticks) }

      rule(:target) do
        str('Dhrystone Benchmark,') >>
        ( version.absent? >> any ).repeat >> version >>
        (( run.absent? >> any ).repeat >> run).repeat(1).as(:runs) >>
          (( usec_per_run.absent? >> any ).repeat >> usec_per_run >> ( dhrystones_per_sec.absent? >> any ).repeat >> dhrystones_per_sec |
           ( total_ticks.absent? >> any ).repeat >> total_ticks)
      end

      rule(:start) { (target | (restofline >> newline | any).as(:drop)).repeat.as(:array) }
      root(:start)
    end # class Parser

    class Transform < Parslet::Transform
      rule(:drop => subtree(:tree)) { }
      rule(:version => simple(:version), :runs => subtree(:runs), :usec_per_run => simple(:usec_per_run), :dhrystones_per_sec => simple(:dhrystones_per_sec)) do
        { :version => String(version), :runs => Integer(runs[-1][:run]), :usec_per_run => Float(usec_per_run), :dhrystones_per_sec => Float(dhrystones_per_sec) }
      end
      rule(:version => simple(:version), :runs => subtree(:runs), :total_ticks => simple(:total_ticks)) do
        { :version => String(version), :runs => Integer(runs[-1][:run]), :total_ticks => Integer(total_ticks) }
      end
      rule(:array => subtree(:tree)) { tree.compact.flatten }
    end # class Transform
  end # module Dhrystone

  class DhrystoneParser < BuildLogParser::Parser
    attr_reader :data

    def reset()
      super()
       @data = []
    end

    def parse(logtext)
      reset()
      @logtext = logtext
      parser = Dhrystone::Parser.new
      tree = parser.parse(logtext)
      @data = Dhrystone::Transform.new.apply(tree)
    end
  end # class CMakeParser
end # module BuildLogParser
