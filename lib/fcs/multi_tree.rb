

require 'rexml/document'

module FinalCutServer
  
  #
  # This class implements a node in a multi-inheritance tree.
  # Each node can have multiple parents and multiple children. The build_multi_tree
  # class function implements the action of building an entire tree graph from a given
  # node.
  #
  # == Dynamic find methods
  # 
  # Among its features are some auto-generated methods for searching the tree heirarchy. The
  # rules by which these dynamic functions are matched are as follows:
  #
  # - Format is <tt>find_which_by_what(arg)</tt>.
  # - +which+ can be one of:
  #   * +parent+
  #   * +parents+
  #   * +ancestor+
  #   * +ancestors+
  #   * +child+
  #   * +children+
  #   * +descendant+
  #   * +descendants+
  # - +by+ can be one of the following (which one you use is a purely cosmetic decision):
  #   * +with+
  #   * +by+
  # - +what+ is the name of an attribute to compare.
  # - +arg+ is a regex or a string to match against the named attribute.
  # 
  # At present (version 0.7.0) only one attribute can be matched using these functions.
  #
  # === Search option equivalence
  #
  # The following table shows how the +which+ parameter above affects the optional arguments
  # to the search() function:
  #
  #                   |                 |             |
  #   which           |    direction    | deep_search | limit 
  #   ----------------+-----------------+-------------+-------
  #   parent          | SEARCH_PARENTS  |    false    |   1
  #   parents         | SEARCH_PARENTS  |    false    |   0
  #   ancestor        | SEARCH_PARENTS  |    true     |   1
  #   ancestors       | SEARCH_PARENTS  |    true     |   0
  #   child           | SEARCH_CHILDREN |    false    |   1
  #   children        | SEARCH_CHILDREN |    false    |   0
  #   descendant      | SEARCH_CHILDREN |    true     |   1
  #   descendants     | SEARCH_CHILDREN |    true     |   0
  #
  # The +search_terms+ hash is built using +{what => arg}+
  #
  class MultiTreeNode
    
    attr_accessor :client, :address
    lazy_reader :children, :parents
    
    # yes, this is a bit hacky-- see build_multi_tree for info
    attr_accessor :building_multi_tree
    
    # Options for the +direction+ parameter of the search method
    SEARCH_CHILDREN = :search_children
    SEARCH_PARENTS = :search_parents
    
    #
    # Initializes a tree node.
    # client::  An instance of FinalCutServer::Client
    # address:: A valid address string from Final Cut Server
    #
    # ==== Example
    #   node = MultiTreeNode.new(Client.new, '/asset/352')
    def initialize(client, address)
      self.client = client
      self.address = address
      ObjectFactory.instance.register self
    end
    
    #
    # Check to see whether a given node is one of the receiver's descendants.
    # 
    # node::   The node to compare against the receiver's children.
    # 
    # Returns +true+ if the given node is a descendant of the receiver.
    #
    def has_descendant?(node)
      return true if self.children.include?(node)
      
      self.children.each do |child|
        if child.has_descendant? node
          return true
        end
      end
      false
    end
    
    #
    # Check to see whether a given node is one of the receiver's ancestors.
    # 
    # node::    The node to compare against the receiver's parents.
    #
    # Returns +true+ if the given node is an ancestor of the receiver.
    #
    def has_ancestor?(node)
      return true if self.parents.include?(node)
      
      self.parents.each do |parent|
        if parent.has_ancestor? node
          return true
        end
      end
      false
    end
    
    #
    # Returns +true+ if the receiver has no children.
    #
    def is_leaf?
      self.children.empty?
    end
    
    #
    # Returns +true+ if the receiver has no parents.
    #
    def is_root?
      self.parents.empty?
    end
    
    #
    # Synonym for +children.each+.
    #
    def each_child(&block)
      self.children.each do |child|
        yield child
      end
    end
    
    #
    # Synonym for +parents.each+.
    #
    def each_parent(&block)
      self.parents.each do |parent|
        yield parent
      end
    end
    
    #
    # Core search function used by automagic searchers created via method_missing. This will
    # search the receiving node's parents or children, potentially recursing the call to them,
    # using the hash of search terms provided.
    #
    # ==== Required arguments
    # direction::       must be one of +MultiTreeNode::SEARCH_CHILDREN+ or 
    #                   +MultiTreeNode::SEARCH_PARENTS+.
    # search_terms::    Must be a Hash of +attribute => condition+ pairs used to validate other nodes.
    #                   Each key is expected to be a string or symbol for an attribute whose value to
    #                   check, while each value should be either a string or a regular expression to be
    #                   compared against the value of that attribute.
    #
    # ==== Optional arguments
    # deep_search::     Set to +false+ to perform a shallow search, i.e. only checking the
    #                   receiver's immediate children or parents. The default is +true+.
    # limit::           Set to the maximum number of results the search should return. Its default
    #                   is 0, meaning no limit.
    #
    # ==== Example:
    #   node.search(MultiTreeNode::SEARCH_PARENTS, {:address => /^\/asset/, :name => /Baseball/})
    #
    # Returns FCSEntity[]
    #
    def search(direction, search_terms, deep_search = true, limit = 0)
      list = nil
      
      # figure out which list to use (parents or children)
      case direction
      when SEARCH_PARENTS
        list = self.parents
      when SEARCH_CHILDREN
        list = self.children
      else
        # invalid argument -- raise an exception
        raise ArgumentError.new "'direction' must be one of MultiTreeNode::SEARCH_PARENTS or MultiTreeNode::SEARCH_CHILDREN"
      end
      
      if search_terms.empty?
        # invalid (empty) search terms -- raise an exception
        raise ArgumentError.new "Empty 'search_terms' hash"
      end
      
      # prepare the array to return any matching nodes
      results = []
      
      # for each node in the chosen list...
      list.each do |node|
        # for each attribute we've been asked to compare...
        search_terms.each do |key, value|
          # fetch the value, if possible
          attribute = node.get_attribute key
          puts "attribute for #{key} is #{attribute}" if FinalCutServer.debug
          next if attribute.nil?
          
          # got an attribute value, perform the comparison
          regex = value
          if regex.kind_of? String
            regex = Regexp.new "^#{value}$" # create a regex matching the whole attribute against the string
          end
          
          # if it matches, we'll add the node to the output list
          results << node if attribute =~ regex
          break if limit != 0 and results.size == limit
          
          # if we've been asked to perform a deep search, go do that and append its results here
          if deep_search
            sub_results = node.search(direction, search_terms, deep_search, limit - results.size)
            unless (sub_results.nil? || sub_results.empty?)
              puts "Found #{sub_results.count} items through #{node.address}" if FinalCutServer.debug
              results = results + sub_results
            end
          end
          
          break if limit != 0 and results.size == limit
        end
        
        break if limit != 0 and results.size == limit
      end
      
      # return the resulting list of nodes
      puts results.count if FinalCutServer.debug
      results
    end
    
    #
    # Converts find_* calls into search() calls.
    #
    # For more information, please see the MultiTreeNode class documentation
    #
    def method_missing(name, *args, &block)
      return super unless block.nil?        # we don't handle blocks right now
      return super unless args.size == 1    # only handle single arguments at the moment
      return super unless name.to_s =~ /^find_/  # we're only interested in find_* calls
      
      puts "method_missing: #{name}(#{args})" if FinalCutServer.debug
      puts "#{caller}" if FinalCutServer.debug
      puts "-----------" if FinalCutServer.debug
      
      # split the name up as in the following:
      # find_ancestors_by_address(x)
      # 0    1         2  3
      components = name.to_s.split('_')
      
      # figure out the various search variables
      limit = 0
      deep = true
      direction = nil
      
      # first a basic syntactic/grammatical checks
      return super unless components.size >= 4
      return super unless ['by', 'with'].include? components[2]
      
      case components[1]    # find what?
      when 'ancestors'
        direction = SEARCH_PARENTS
      when 'ancestor'
        direction = SEARCH_PARENTS
        limit = 1
      when 'parents'
        direction = SEARCH_PARENTS
        deep = false
      when 'parent'
        direction = SEARCH_PARENTS
        limit = 1
        deep = false
      when 'descendants'
        direction = SEARCH_CHILDREN
      when 'descendant'
        direction = SEARCH_CHILDREN
        limit = 1
      when 'children'
        direction = SEARCH_CHILDREN
        deep = false
      when 'child'
        direction = SEARCH_CHILDREN
        deep = false
        limit = 1
      else
        return super    # function name doesn't match, so default to superclass' implementation
      end
      
      # now build the search terms
      match_attr_name = components[3..components.count].join('_')
      search_terms = {match_attr_name => args[0]}
      puts "search_terms = #{search_terms}" if FinalCutServer.debug
      
      # finally we're ready to make the call and return the result directly
      search(direction, search_terms, deep, limit)
    end
    
    protected
    
    def lazy_source
      children_xml = REXML::Document.new(@client.list_parent_links({:xml => true}, [address]))
      parents_xml = REXML::Document.new(@client.list_child_links({:xml => true}, [address]))
      
      # if either of those calls failed, return an empty result
      return OpenStruct.new if children_xml.nil? or parents_xml.nil?
      
      children = parse_xml(children_xml)
      parents = parse_xml(parents_xml)
      
      # return a new OpenStruct containing these things
      # works similarly to a hash, but behaves like an object with attributes
      ::OpenStruct.new(:children => children, :parents => parents)
    end
    
    #
    # Parses a get_parent_links- or get_child_links-style XML document,
    # returning an array of FCSEntity objects
    # 
    # xml_doc::   An instance of REXML::Document.
    #
    # Returns FCSEntity[]
    #
    def parse_xml(xml_doc)
      output = []
      xml_doc.root.elements.each do |element|
        next unless element.name == 'values'    # skip ahead if it's not what we expect
        
        count = 1
        puts "element #{count}:" if FinalCutServer.debug
        
        metadata = {}
        link_type = nil
        address = nil
        
        # for each 'value' child element with an 'id' attribute:
        element.each_element_with_attribute('id', nil, 0, 'value') do |value|
          # grab the type (id attribute value)
          type = value.attributes['id']
          next if type.nil?   # skip if the type wasn't there for some reason
          
          # pull out metadata, link type, and address
          case type
          when 'METADATA'
            puts "  metadata:" if FinalCutServer.debug
            value.elements['values'].each_element do |md_value|
              # I broke this out into another function, for cleanliness
              key, obj = data_from_md_value_xml(md_value)
              puts "    #{key} == #{obj}" if FinalCutServer.debug
              metadata[key] = obj
            end
          when 'LINK_TYPE'
            link_type = value.elements['int'].text.to_i
            puts "  link_type == #{link_type}" if FinalCutServer.debug
          when 'ADDRESS'
            address = value.elements['string'].text
            puts "  address == #{address}" if FinalCutServer.debug
          end
        end  
          
        # if we're missing a link type or an address, skip ahead
        if link_type.nil? || address.nil?
          puts "===nil link_type or address, skipping===" if FinalCutServer.debug
          next
        end
        # if we're not interested in this type of link, also skip ahead
        next unless interesting_link_type(link_type)
        
        # get an object representing this FCS entity
        output << ObjectFactory.instance.object_for_address(address, metadata)
        
        count = count + 1
      end
      
      output
    end
    
    def data_from_md_value_xml(element)
      key = element.attributes['id']
      value_element = element.elements.first
      value = value_element.text
      
      return nil if key.nil? or value.nil?
      
      # theoretically we'll have to handle other things, but I only
      # see int, string, and atom (also a string) right now
      case value_element.name
      when 'int'
        value = value.to_i
      end
      
      # return key & value
      return key, value
    end
    
    INTERESTING_LINK_TYPES = [1, 2, 4, 5, 6, 7, 8, 11, 12, 15]
    
    def interesting_link_type(link_type)
      INTERESTING_LINK_TYPES.include? link_type
    end
    
    public
    
    #
    # Takes a single MultiTreeNode object and recursively builds out a full tree from it,
    # in both directions.
    #
    # node:: A MultiTreeNode instance.
    #
    # Returns the input node, or nil if an error occurred.
    #
    def self.build_multi_tree(node)
      return nil unless node.kind_of? MultiTreeNode   # Must be of type MultiTreeNode

      # infinite recursion prevention-- although I'm sure there's a better way to do this...
      node.building_multi_tree = true

      # Recursion-- ain't it grand?
      node.each_child do |child|
        build_multi_tree child unless child.building_multi_tree
      end
      node.each_parent do |parent|
        build_multi_tree parent unless parent.building_multi_tree
      end
      node
    end
    
  end
  
end