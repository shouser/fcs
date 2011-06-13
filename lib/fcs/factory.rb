
module FinalCutServer
  
  #
  # A singleton entity object factory which manages creation and maintenance of objects
  # representing assets, elements, files, etc. This is so that there is only ever
  # one instance of each object in memory, regardless the number of times it would
  # appear in a resource tree. This way we both save on peak commit charge and we can
  # freely change the metadata values for any entity without being concerned that an
  # unmodified version is waiting around to overwrite our changes in Final Cut Server.
  #
  # == Usage
  #
  # Obtain the singleton using the instance() class method:
  #   factory = ObjectFactory.instance
  #
  # When you want a new entity class, call object_for_address():
  #   obj = factory.object_for_address('/asset/352')
  #
  # *Note*:: The object_for_address() method is the preferred way of initializing
  #          entity classes, but instantiating them directly will still register
  #          that instance with the factory. However, calling Asset.new() twice with
  #          the same address will create two separate instances, and the factory will
  #          forget the existence of the first one.
  #
  class ObjectFactory
    include Singleton   # ensure only one instance can ever be created
    
    # This is a hash containing objects indexed by their addresses.
    attr_reader :all_objects
    
    # The singleton factory instance maintains a single Client object to be
    # used by all entities it creates.
    attr_reader :client
    
    def initialize
      @client = Client.new
      @all_objects = {}
    end
    
    #
    # Returns an object corresponding to an address, creating it only if an instance
    # does not already exist.
    #
    # ==== Required arguments
    # address::   The address string for the entity
    #
    # ==== Optional arguments
    # metadata::  A Hash of optional metadata to set in the entity class
    #
    # ==== Example
    #   entity = Factory.instance.object_for_address('/asset/352', :CUST_TITLE => "title")
    #
    def object_for_address(address, metadata = {})
      obj = @all_objects[address]
      return obj unless obj.nil?    # return an existing instance if available
      
      cls = class_for_address(address)
      return nil if cls.nil?
      
      # allocate a new instance, which will in turn register itself with us
      # (the MultiTreeNode's initialize method does this)
      cls.new(@client, address, metadata)
    end
    
    #
    # Registers an object with the factory
    #
    # This is called internally by the base object class, MultiTreeNode, as
    # part of its +initialize+ function.
    #
    # obj::   The object to register
    #
    def register(obj)
      return if obj.address.nil?
      @all_objects[obj.address] = obj
    end
    
    private
    
    #
    # Works out which class should be instantiated for a given FCS entity address.
    # address::    A Final Cut Server entity address, as a String.
    #
    # Returns the appropriate class, or +nil+ if no class was found to match the address.
    def class_for_address(address)
      if address.split('/').size > 3
        return FinalCutServer::MediaFile
      end
      
      type = /^\/([a-zA-Z]+)\//.match(address)[1]
      
      case type
      when 'project'
        return FinalCutServer::Project
      when 'asset'
        return FinalCutServer::Asset
      when 'element'
        return FinalCutServer::Element
      when 'dev'
        return FinalCutServer::Device
      end
      nil
    end
    
  end
  
end