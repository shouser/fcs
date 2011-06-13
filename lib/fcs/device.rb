
module FinalCutServer
  
  class Device < FCSEntity
    attr_reader :metadata
    
    md_accessor :name, :root_path, :show_dot, :device_encoding
    md_accessor :md_sync_policy, :generate_proxy, :mac_eip_uri, :analyse_mode
    
    LAZY_LOOKUP = {
      "DEVICE_NAME" => :name,
      "DEV_ROOT_PATH" => :root_path,
      "DEV_SHOW_DOT" => :show_dot,
      "DEVICE_ENCODING" => :device_encoding,
      "MD_SYNC_POLICY" => :md_sync_policy,
      "GENERATE_PROXY" => :generate_proxy,
      "MAC_EIP_URI" => :mac_eip_uri,
      "ANALYSE_MODE" => :analyse_mode
    }
    
    def self.preferred_metadata_format
      METADATA_FORMAT_XML
    end
    
    def self.md_key_map
      LAZY_LOOKUP
    end
    
    def load_metadata
      super
    end
    
    def self.md_type_coercion_map
      {
        "DEV_SHOW_DOT" => :to_bool,
        "MD_SYNC_POLICY" => :to_i,
        "GENERATE_PROXY" => :to_bool
      }
    end
    
    #
    # Returns a list of Device instances matching the given criteria (see FCSEntity.search_for)
    #
    # ==== Optional arguments
    # criteria::    A string for which to search in the device's data.
    #
    # Returns Array of Device
    #
    def self.search(criteria = nil, options = {})
      search_for ['/dev'], criteria, options
    end
    
  end
  
end