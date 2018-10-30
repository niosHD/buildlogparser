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
  module Scimark2
    class Parser < Parslet::Parser
      rule(:space)     { match['\s'] }
      rule(:space?)    { space.repeat }

      rule(:newline)   { str("\r").maybe >> str("\n") }
      rule(:restofline){ ( newline.absent? >> any ).repeat }

      rule(:path)      { match['[:alnum:]=\+\.\-_/'].repeat(1) }
      rule(:integer)   { match['0-9'].repeat(1) }
      rule(:float)     { integer >> (match['\.,'] >> integer).maybe }

      rule(:target) do
        str('Using') >> space? >> float.as(:time_per_kernel) >> str(' seconds min time per kenel.') >> newline >>
        str('Composite Score:') >> space? >> float.as(:composite) >> newline >>
        str('FFT') >> space? >> str('Mflops:') >> space? >> float.as(:fft) >> space? >>
            str('(N=') >> integer.as(:fft_n) >> str(')') >> newline >>
        str('SOR') >> space? >> str('Mflops:') >> space? >> float.as(:sor) >> space? >>
            str('(') >> integer.as(:sor_1) >> space? >> str('x') >> space? >> integer.as(:sor_2) >> str(')') >> newline >>
        str('MonteCarlo:') >> space? >> str('Mflops:') >> space? >> float.as(:monte_carlo) >> newline >>
        str('Sparse matmult') >> space? >> str('Mflops:') >> space? >> float.as(:sparse_matmult) >> space? >>
            str('(N=') >> integer.as(:sparse_matmult_n) >> str(', nz=') >> integer.as(:sparse_matmult_nz) >> str(')') >> newline >>
        str('LU') >> space? >> str('Mflops:') >> space? >> float.as(:lu) >> space? >>
            str('(M=') >> integer.as(:lu_m) >> str(', N=') >> integer.as(:lu_n) >> str(')')
      end

      rule(:start) { (target | (restofline >> newline | any).as(:drop)).repeat.as(:array) }
      root(:start)
    end # class Parser

    class Transform < Parslet::Transform
      rule(:drop => subtree(:tree)) { }
      rule(:time_per_kernel => simple(:time_per_kernel), :composite => simple(:composite), :fft => simple(:fft), :fft_n => simple(:fft_n),
        :sor => simple(:sor), :sor_1 => simple(:sor_1), :sor_2 => simple(:sor_2), :monte_carlo => simple(:monte_carlo),
        :sparse_matmult => simple(:sparse_matmult), :sparse_matmult_n => simple(:sparse_matmult_n), :sparse_matmult_nz => simple(:sparse_matmult_nz),
        :lu => simple(:lu), :lu_m => simple(:lu_m), :lu_n => simple(:lu_n)) do
          { :time_per_kernel => Float(time_per_kernel), :composite => Float(composite), :fft => Float(fft), :fft_n => Integer(fft_n),
            :sor => Float(sor), :sor_1 => Integer(sor_1), :sor_2 => Integer(sor_2), :monte_carlo => Float(monte_carlo),
            :sparse_matmult => Float(sparse_matmult), :sparse_matmult_n => Integer(sparse_matmult_n), :sparse_matmult_nz => Integer(sparse_matmult_nz),
            :lu => Float(lu), :lu_m => Integer(lu_m), :lu_n => Integer(lu_n) }
      end
      rule(:array => subtree(:tree)) { tree.compact.flatten }
    end # class Transform
  end # module Scimark2

  class Scimark2Parser < BuildLogParser::Parser
    attr_reader :data

    def reset()
      super()
      @data = []
    end

    def parse(logtext)
      reset()
      @logtext = logtext
      parser = Scimark2::Parser.new
      tree = parser.parse(logtext)
      @data = Scimark2::Transform.new.apply(tree)
    end
  end # class Scimark2Parser

  registerParser(:scimark2, Scimark2Parser, :parse)
end # module BuildLogParser
