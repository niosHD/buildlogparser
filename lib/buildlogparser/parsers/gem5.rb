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
  module Gem5Stats
    class Parser < Parslet::Parser
      rule(:space)     { match['\s'] }
      rule(:space?)    { space.repeat }

      rule(:newline)   { str("\r").maybe >> str("\n") }
      rule(:restofline){ ( newline.absent? >> any ).repeat }

      rule(:integer)   { str("-").maybe >> match['0-9'].repeat(1) }
      rule(:float)     { integer >> match['\.,'] >> integer | str("nan") | str("inf") }

      rule(:key)       { match['[:alnum:]=\+\.\-_\:'].repeat(1) }
      rule(:kvpair)    { key.as(:key) >> space? >> (float.as(:float) | integer.as(:int)) }

      rule(:target) do
        str('---------- Begin Simulation Statistics ----------') >> newline >>
          (kvpair >> restofline >> newline).repeat.as(:numbers)
      end

      rule(:start) { (target | (restofline >> newline | any).as(:drop)).repeat.as(:array) }
      root(:start)
    end # class Parser

    def self.valid_symbol?(str)
      str.match(/^\w+$/) != nil
    end

    def self.valid_symbol_sequence?(str)
      parts = str.split('.').reject { |f| f.empty? }
      parts.each { |e| return false unless Gem5Stats::valid_symbol?(e) }
      return true
    end

    def self.to_symbol_sequence(str)
      parts = str.split('.').reject { |f| f.empty? }
      return parts.map { |e| e.to_sym }
    end

    def self.get_key_sequence(str)
      # split the key string into a sequence of symbols and strings
      keys = []
      fragments = str.split("::").reject { |f| f.empty? }
      fragments.each { |f|
        if Gem5Stats::valid_symbol_sequence?(f)
          keys.concat(Gem5Stats::to_symbol_sequence(f))
        else
          keys.append(f)
        end
      }
      return keys
    end

    def self.insert_into_hash(hash, keys, value)
      ptr = hash
      keys[0..-2].each { |k|
        ptr[k] ||= {}
        ptr = ptr[k]
      }
      ptr[keys[-1]] = value
    end

    class Transform < Parslet::Transform
      rule(:drop => subtree(:tree)) { }
      rule(:numbers => subtree(:numbers)) do
        result = {}
        numbers.each { |e|
          # extract the value with the correct type
          if e.key?(:float)
            str = e[:float]
            if str == "nan"
              value = Float::NAN
            elsif str == "inf"
              value = Float::INFINITY
            else
              value = Float(e[:float])
            end
          else
            value = Integer(e[:int])
          end

          keys = Gem5Stats::get_key_sequence(String(e[:key]))
          Gem5Stats::insert_into_hash(result, keys, value)
        }
        result
      end
      rule(:array => subtree(:tree)) { tree.compact.flatten }
    end # class Transform
  end # module Gem5Stats

  class Gem5Parser < BuildLogParser::Parser
    attr_reader :data

    def reset()
      super()
      @data = []
    end

    def parseStats(logtext)
      reset()
      @logtext = logtext
      parser = Gem5Stats::Parser.new
      tree = parser.parse(logtext)
      @data = Gem5Stats::Transform.new.apply(tree)
    end
  end # class Gem5Parser

  registerParser(:gem5Stats, Gem5Parser, :parseStats)
end # module BuildLogParser
