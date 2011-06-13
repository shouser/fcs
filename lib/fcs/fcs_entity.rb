

require 'rexml/document'
require 'rexml/xpath'
require 'time'

module FinalCutServer
  #
  # Exception thrown when an FCSEntity subclass fails to implement required lazy-binding
  # methods properly.
  #
  class EmptyMetadataImplementation < RuntimeError
    # The name of the class which failed to implement the abstract method(s).
    attr_reader :class_name
    
    def initialize(class_name)
      @class_name = class_name
    end
  end
  
  #
  # This class is a base class for classes which expose data output from fcsvr_client's
  # getmd command. It implements a lazy accessor algorithm for defining local variables
  # based on values fetched using fcsvr_client, and it requires only that the subclass
  # implement a particular class method returning a hash of keys to variable names.
  #
  # Subclasses can use the +md_accessor+, +md_reader+ and +md_writer+ methods to define
  # lazily-loaded metadata accessors similarly to the +attr_*+ versions of the above.
  #
  class FCSEntity < MultiTreeNode
    
    attr_reader :metadata
    protected :metadata
    
    METADATA_FORMAT_TEXT = :text
    METADATA_FORMAT_XML  = :xml
    
    # ==== Required arguments
    # client::         An instance of FinalCutServer::Client.
    # address::        The FCS address of the entity, i.e. +'/asset/352'
    #
    # ==== Optional arguments
    # other_metadata:: A hash of key-value pairs for metadata to pre-populate.
    def initialize(client, address, other_metadata = {})
      super(client, address)
      @written_md_vars = {}
      @metadata_loaded = false
      @metadata = {}
      
      key_lookup = self.class.md_key_map
      type_lookup = self.class.md_type_coercion_map
      other_metadata.each do |key, value|
        insert_metadata key, value, key_lookup, type_lookup
      end
    end
    
    #
    # Subclasses should implement this to return a hash of FCS metadata keys
    # to local variable names. This is used for +md_*+ lazy variable initialization.
    #
    def self.md_key_map
      raise EmptyMetadataImplementation.new(self.class.name)
    end
    
    def self.hash_to_md_xml(md)
      doc = REXML::Document.new "<session><values/></session>"

      doc << REXML::XMLDecl.new

      md.each do |name, item|
        if name =~ /_node$/
          value_node = REXML::Element.new "value"
          value_node.attributes['id'] = name.gsub(/_node$/, '')
          data_node = REXML::Element.new item["type"]
          if item['type'] == "timestamp"
            data_node.text = item['value'].to_s.to_fcs_style_time
          elsif item['type'] == "string"
            data_node.text = item['value']
            data_node.attributes['xml:space'] = "preserve"
          end
          value_node.add_element data_node
          doc.elements["session/values"].add_element value_node
        end
      end

      return doc.to_s
    end
    
    def parse_link_types_from_xml(xml)
      link_types = Hash.new

      doc = REXML::Document.new xml

      doc.elements["session/values/value[@id='ENUM_ENTRIES']/valuesList"].each_element do |element|
        link_types[element.elements["value[@id='ENUM_VALUE']/int"].text] = element.elements["value[@id='ENUM_LABEL']/string"].text
      end

      return link_types
    end
    
    #
    # Subclasses can implement this to return a hash of FCS metadata keys
    # to conversion functions, used to coerce the local variables into the correct
    # type using +send()+.
    # 
    # The default version here just returns an empty hash (i.e. all variables are strings).
    #
    # ==== Example
    #   hash = { "IGNORE" => :to_bool, "TYPE" => :to_i }
    #
    def self.md_type_coercion_map
      {}
    end
    
    #
    # Subclasses can implement this to return the preferred type of metadata
    # format to fetch. Those which would like to use values only returned via
    # XML can return FCSEntity::METADATA_FORMAT_XML.
    #
    # The default value is FCSEntity::METADATA_FORMAT_TEXT
    #
    def self.preferred_metadata_format
      METADATA_FORMAT_TEXT
    end
    
    #
    # A simple method to return a named attribute by passing in its name.
    # This is designed to be more idiomatic in search routines than using *send()*. It
    # also performs a few more checks in an attempt to match all possible names for a
    # member variable (i.e. you can supply the variable name or the metadata attribute name).
    #
    # ==== Required arguments
    # name::    The name of the attribute you want to retrieve; it can be a string or symbol.
    #
    # ==== Example
    #   node.get_attribute :address
    #
    def get_attribute(name)
      str = name.to_s
      
      # try fetching an instance variable first
      value = instance_variable_get("@#{str}")
      return value unless value.nil?
      
      # not an instance variable -- try fetching from @metadata
      load_metadata unless @metadata_loaded
      value = @metadata[str]
      return value unless value.nil?
       
       # not in metadata under that name -- is there another variant?
      alternate_name = nil
      self.class.md_key_map.each do |md_name, var_name|
        if str == md_name.to_s
          alternate_name = var_name.to_s
          break
        end
      end
      
      # if we couldn't find anything, return nil
      return nil if alternate_name.nil?
      
      # otherwise, try looking in metadata using the alternate name
      # if this doesn't work, we'll just let the method return nil
      @metadata[alternate_name]
    end
    
    # implementation of method_missing to dynamically create new member variables
    #  as appropriate. This is based on MyOpenStruct in the Ruby 1.9 book.
    def method_missing(name, *args, &block)
      return super unless block.nil?     # don't do anything if handed a block
      return super if name =~ /^find_$/  # superclass wants to handle these itself
      
      str = name.to_s
      if str.end_with?('=')  # setter method?
        return super unless args.size == 1   # don't do anything unless we have a single argument
        
        # create a new instance method
        base_name = str[0..-2].intern
        _singleton_class.instance_exec(name) do |name|
          define_method(name) do |value|
            @written_md_vars[base_name.to_sym] = (value.nil? ? false : true)
            @metadata[base_name.to_s] = value
          end
        end
        
        # manually set the value now
        @written_md_vars[base_name.to_sym] = (args[0].nil? ? false : true)
        @metadata[base_name.to_s] = args[0]
      else  # getter method
        return super unless args.size == 0   # don't override if there are args
        return super unless @metadata.has_key? str
        
        # create a new instance method ready for next time
        _singleton_class.instance_exec(name) do |name|
          define_method(name) do
            @metadata[str]
          end
        end  
          
        # return the value from metadata now
        @metadata[str]
      end
    end

    #
    # Fetch a hash of all variable/metadata names which were assigned at any point. For each
    # symbol in the hash, the value will be +true+ if that value was set to something worth
    # assigning.
    #
    # Returns Hash{Symbol, Boolean}
    #
    def all_updates
      hash = {}
      @written_md_vars.each do |key, value|
        hash[key] = @metadata[key] ||= self.send(key)
      end

      hash  # return the hash
    end
    
    #
    # Stores all modified metadata values (and ONLY those which have been set/modified) into
    # Final Cut Server via the 'setmd' command.
    #
    def save_metadata
      updates = all_updates
      return if updates.empty?
      
      # build an array of strings to be passed directly into the command
      # we do this because of the funny quoting we have to do for the shell
      # since FCS will include any quotes wrapping a value as part of that value
      arguments = [self.address]
      
      updates.each do |key, value|
        name = metadata_version_of key
        quoted_value = value.gsub(' ', "\\ ")
        arguments << "#{name}=#{quoted_value}"
      end
      
      self.client.sudo.setmd({}, arguments)
    end
    
    protected
    
    ##
    # Used by method_missing: the singleton class hack, used to add methods ONLY
    # to the receiving instance.
    def _singleton_class
      class << self
        self
      end
    end
    
    #
    # Performs a reverse-lookup of a variable name to a metadata name, returning
    # the input value if no match was found.
    #
    # === Required Arguments
    # name::  A metadata variable name to convert.
    #
    # Returns String
    #
    def metadata_version_of(name)
      self.class.md_key_map.each do |md_name, var_name|
        return md_name if var_name.to_s == name
      end
      name  # return input if no mapping was discovered
    end
    
    #
    # This function reads the metadata values into the +@metadata+ hash,
    # by calling either load_text_metadata() or load_xml_metadata() as
    # appropriate to the subclass in question.
    #
    # The common metadata values are matched to the lazy variables specified by
    # the subclass, while custom ones can be accessed via their FCS keys.
    #
    def load_metadata
      case self.class.preferred_metadata_format
      when METADATA_FORMAT_XML
        load_xml_metadata
      else
        load_text_metadata
      end
    end
    
    # Loads metadata using the standard text format. This doesn't return as many
    # variables as the XML format.
    def load_text_metadata
      str = self.client.getmd({}, @address)
      keymap = self.class.md_key_map    # subclasses implement this function
      types = self.class.md_type_coercion_map     # subclasses might implement this function
      
      # regular expression: matches lines with:
      #   4 whitespace characters at start of line
      #   word containing uppercase characters and/or underscores (captured as var 1)
      #   colon character immediately after that word
      #   one or more whitespace characters
      #   any characters following that whitespace, up to end of line (captured as var 2)
      # So, if the string matches, it gets the key as var 1, value as var 2
      re = /^\W{4}([A-Z_]+):\s+(.+)$/
      str.each_line do |line|
        md = re.match(line)
        next if md.nil?
        next if md.size < 3      # skip if we didn't get a value for a key (or didn't match)
        
        # insert the metadata value into the @metadata hash
        insert_metadata md[1], md[2], keymap, types
      end
      
      # note that we don't need to run this again
      @metadata_loaded = true
    end
    
    # Loads metadata using the XML output format. This format returns more variables
    # than the text-based stdout format, so is potentially more useful. It is not
    # (currently) the default, however.
    def load_xml_metadata
      str = self.client.getmd({:xml => true}, @address)
      return if str.empty?
      
      keymap = self.class.md_key_map
      types = self.class.md_type_coercion_map
      
      doc = REXML::Document.new(str)
      return if doc.nil?
      
      # <session><values>...</values></session>
      values = doc.root.elements[1, 'values']
      values.each_element do |element|
        key = element.attributes['id']
        value_element = element.elements.first
        value = value_element.text
        nodetype = value_element.name
        
        next if key.nil? or value.nil?
        
        case value_element.name
        when 'int'
          value = value.to_i
        when 'bigint'
          value = value.to_i
        when 'timestamp'
          value = Time.parse(value)
        else
          if types.has_key?(key)
            value = value.send(types[key])
          end
        end
        
        insert_metadata key, value, keymap, {}, nodetype
      end
      
      @metadata_loaded = true
    end
    
    #
    # Performs the internals of inserting a metadata value into the metadata hash.
    # This takes the key/value pair for the metadata item along with two hashes
    # used to look up a custom variable name and a custom value type.
    #
    # ==== Required arguments
    # key::           The key, as output by Final Cut Server.
    # value::         The value, as a string, output by Final Cut Server.
    # key_lookup::    A lookup hash for changing metadata keys into nicer variable names,
    #                 such as the one returned from +self.md_key_map+.
    #
    # ==== Optional arguments
    # type_lookup::   A hash of FCS key names to String instance functions, used
    #                 to coerce the string into a different class. Note that this is indexed
    #                 using the non-transformed key names.
    #
    # Normally used internally by the load_metadata() and initialize() functions, but
    # can be used with manually-obtained metadata like so:
    #   obj.insert_metadata(key, value, my_key_map, my_type_coercion_map)
    #
    def insert_metadata(key, value, key_lookup, type_lookup = {}, nodetype = nil)
      name = key_lookup[key]
      name ||= key
      coercion = type_lookup[key]
      unless coercion.nil?
        value = value.send(coercion)
      end
      @metadata[name.to_s] = value
      @metadata[key + "_node"] = {"value" => value, "type" => nodetype} unless nodetype.nil?
    end
    
    #
    # Used by superclasses to implement searches to return FCSEntity classes as results.
    #
    # Note that the criteria is passed to fcsvr_client using the +--crit+ option; at present not
    # much is understood about the working of this option. If it transpires to accept some form
    # of expression syntax, you can pass such an expression here directly. Be aware, however, that
    # this argument will be double-quoted automatically by this library.
    #
    # ==== Required arguments
    # address::       An address substring, for instance '/asset' or '/dev'
    #
    # ==== Optional arguments
    # criteria::      Some value to search for. Only results containing this value in a text field somewhere
    #                 will be returned.
    #
    # Returns Array of FCSEntity
    #
    def self.search_for(address, criteria = nil, options = {})
      unless criteria.nil?
        options.merge({:crit => criteria})
      end
      
      str = Client.new.search(options, address)
      return nil if str.nil? or str.empty?
      
      result = []
      addr_re = /^(#{address}\/\d+)\s/
      str.each_line do |line|
        md = line.match(addr_re)
        next if md.nil?
        next unless md.length > 1
        
        result << ObjectFactory.instance.object_for_address(md[1])
      end
      
      # return an array with any nil elements removed
      result.compact
    end
    
  end
  
  #
  # This module implements the +md_reader+, +md_writer+ and +md_accessor+ autogenerated
  # methods.
  module FCSEntityGuts
    ##
    # Pulling data from a reader will first load metadata if necessary.
    def md_reader(*accessors)
      accessors.each do |m|
        
        # build a definition (as text) to be added to the class as a whole
        class_eval <<-EOS
          def #{m}
            val = instance_variable_get("@#{m.to_s}")
            return val unless val.nil?
            # lazily load metadata and set instance var from that if applicable
            load_metadata unless @metadata_loaded
            instance_variable_set("@#{m.to_s}", @metadata["#{m.to_s}"])
          end
        EOS
      end
    end
    
    ##
    # Writers keep track of which values have been set, for the benefit of +all_updates()+.
    def md_writer(*accessors)
      accessors.each do |m|
        
        # build a definition (as above)
        class_eval <<-EOS
          def #{m}=(val)
            @written_md_vars["#{m}".to_sym] = (value.nil? ? false : true)
            instance_variable_set("@#{m}", val)
          end
        EOS
      end
    end
    
    ##
    # Accessor creates both the reader and writer methods.
    def md_accessor(*accessors)
      md_reader(*accessors)
      md_writer(*accessors)
    end
  end
  
  FCSEntity.extend FCSEntityGuts
  
end
