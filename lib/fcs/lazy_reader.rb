#
# Author::      Tom Preston-Warner & Jim Dovey
# Description:: Implements a lazy loading version of attr_reader().
# Origin::      Based on lazy_reader.rb from the +grit+ project
#               (http://github.com/mojombo/grit).
# License::     (The MIT License)
#               
#               Copyright (c) 2007 Tom Preston-Werner
#               
#               Permission is hereby granted, free of charge, to any person obtaining
#               a copy of this software and associated documentation files (the
#               'Software'), to deal in the Software without restriction, including
#               without limitation the rights to use, copy, modify, merge, publish,
#               distribute, sublicense, and/or sell copies of the Software, and to
#               permit persons to whom the Software is furnished to do so, subject to
#               the following conditions:
#               
#               The above copyright notice and this permission notice shall be
#               included in all copies or substantial portions of the Software.
#               
#               THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
#               EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#               MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#               IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
#               CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
#               TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
#               SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

#
# Allows attributes to be declared as lazy, meaning that they won't be
# computed until they are asked for. 
#
# Works by delegating each lazy_reader to a cached lazy_source method.
#
# === Example:
#
#  class Person
#    lazy_reader :eyes
#  
#    def lazy_source
#      OpenStruct.new(:eyes => 2)
#    end
#  end
#
#  >> Person.new.eyes
#  => 2
#
module Lazy
  def lazy_reader(*args)
    args.each do |arg|
      class_eval <<-EOS
        def #{arg}
          val = instance_variable_get("@#{arg}")
          return val if val
          instance_variable_set("@#{arg}", (@lazy_source ||= lazy_source).send("#{arg}"))
        end
      EOS
    end
  end
end

Object.extend Lazy unless Object.ancestors.include? Lazy