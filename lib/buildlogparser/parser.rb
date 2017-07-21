module BuildLogParser
  class Parser
    attr_reader :logtext

    def initialize()
      reset()
    end

    def reset()
      @logtext   = nil
    end
  end # class Parser
end # module BuildLogParser
