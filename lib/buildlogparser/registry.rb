#
# Copyright (C) 2017 Mario Werner <nioshd@gmail.com>
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
module BuildLogParser
  @@parsers = { cmakeMakefileStdout: [CMakeParser,     :parseMakefileStdout],
                coremark:            [CoremarkParser,  :parse],
                ctestStdout:         [CTestParser,     :parseStdout],
                ctestLog:            [CTestParser,     :parseLog],
                dhrystone:           [DhrystoneParser, :parse],
                sizeBerkeleyStdout:  [SizeParser,      :parseBerkeleyStdout]}

  def self.getParserNames
    return @@parsers.keys
  end

  def self.registerParser(parser_name, parser_class, method)
    @@parsers[parser_name] = [parser_class, method]
  end

  def self.getParser(parser_name)
    return nil unless @@parsers.key?(parser_name)
    return @@parsers[parser_name][0].new
  end

  def self.parse(parser_name, parser_obj, logtext)
    return nil unless @@parsers.key?(parser_name)
    return parser_obj.public_send(@@parsers[parser_name][1],logtext)
  end
end # module BuildLogParser
