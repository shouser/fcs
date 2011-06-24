
$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed

# core
require 'fileutils'
require 'time'
require 'ostruct'
require 'date'
require 'rexml/document'

#stdlib
require 'timeout'
require 'singleton'

#third party
require 'rubygems'
require 'net/ssh'
require 'open4'
require 'socket'
require 'json'
require 'uri'
require 'ERB'
require 'tree'

#project internals
require 'ext/string'

require 'fcs/lazy_reader'
require 'fcs/multi_tree'
require 'fcs/fcs_entity'
require 'fcs/asset'
require 'fcs/client'
require 'fcs/device'
require 'fcs/element'
require 'fcs/factory'
require 'fcs/file'
require 'fcs/project'

module FinalCutServer
  class << self
    attr_accessor :debug, :fcs_version
  end
  
  self.fcs_version = "1.5"
  
  self.debug = false

end