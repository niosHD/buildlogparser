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

      rule(:event) do
        space? >> integer.as(:nr) >> str('/') >> integer >> space? >> str('Test') >> space? >> str('#') >>
        integer >> str(': ') >> letters.as(:name) >> match['\.*\s'].repeat(1) >> letters.as(:result) >> space? >>
        float.as(:time) >> anyline
      end

      rule(:errors)    { (event | anyline.as(:drop)).repeat.as(:array) }
      root(:errors)
    end # class Parser

    class Transform < Parslet::Transform
      rule(:drop => subtree(:tree)) { }
      rule(:nr => simple(:nr), :name => simple(:name), :result => simple(:result), :time => simple(:time) ) do
        { :nr => Integer(nr), :name => String(name), :result => String(result).downcase!, :time => Float(time) }
      end
      rule(:array => subtree(:tree)) { tree.is_a?(Array) ? tree.compact : [ tree ]  }
    end # class Transform
  end # module CTestStdout


  class CTestParser < BuildLogParser::Parser
    attr_reader :data
    attr_reader :errors
    attr_reader :test_count

    def reset()
      super()
      @data       = []
      @errors     = 0
      @test_count = 0

    end

    def parseStdout(logtext)
      reset()
      @logtext = logtext
      parser = CTestStdout::Parser.new
      tree = parser.parse(logtext)
      @data = CTestStdout::Transform.new.apply(tree)

      @data.each do |event|
        @test_count += 1
        @errors     += 1 unless event[:result].to_sym == :passed
      end
    end
  end # class CTestParser
end # module BuildLogParser
