#
# Copyright (C) 2017-2018 Mario Werner <nioshd@gmail.com>
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
require_relative "buildlogparser/registry"
require_relative "buildlogparser/version"

require_relative "buildlogparser/parser"
require_relative "buildlogparser/parsers/cmake"
require_relative "buildlogparser/parsers/coremark"
require_relative "buildlogparser/parsers/ctest"
require_relative "buildlogparser/parsers/dhrystone"
require_relative "buildlogparser/parsers/encounter"
require_relative "buildlogparser/parsers/gem5"
require_relative "buildlogparser/parsers/lld"
require_relative "buildlogparser/parsers/lmbench"
require_relative "buildlogparser/parsers/scimark2"
require_relative "buildlogparser/parsers/size"
