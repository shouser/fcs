
module FinalCutServer
  
  class Asset < FCSEntity
    attr_reader :metadata
    
    md_accessor :title, :user_name, :size, :device, :location, :asset_number, :filename, :asset_type
    md_accessor :created_at, :entity_created_at, :modified_at, :last_accessed, :wrapper_format
    
    # maps keys in getmd output to our standard variables
    LAZY_LOOKUP = {
      "CUST_TITLE" => :title,
      "ENTITY_CREATE_USER_NAME" => :user_name,
      "CUST_SIZE" => :size,
      "CUST_DEVICE" => :device,
      "CUST_LOCATION" => :location,
      "ASSET_NUMBER" => :asset_number,
      "PA_MD_CUST_FILENAME" => :filename,
      "CUST_CREATED" => :created_at,
      "ENTITY_CREATED" => :entity_created_at,
      "MD_LAST_MODIFIED" => :last_modified,
      "LAST_ACCESSED" => :last_accessed,
      "ASSET_WRAPPER_FORMAT" => :wrapper_format,
      "ASSET_TYPE" => :asset_type
    }
    
    ##
    # Overridden from superclass to return the hash defined above
    def self.md_key_map
      LAZY_LOOKUP
    end
    
    def self.preferred_metadata_format
      METADATA_FORMAT_XML
    end
    
    def load_metadata
      super
    end
    
    ##
    # Overridden to return coercion functions for certain variables
    def self.md_type_coercion_map
      {
        "CUST_SIZE" => :to_i,
        "ASSET_NUMBER" => :to_i,
        "CUST_CREATED" => :to_fcs_style_time,
        "ENTITY_CREATED" => :to_fcs_style_time,
        "MD_LAST_MODIFIED" => :to_fcs_style_time,
        "LAST_ACCESSED" => :to_fcs_style_time
      }
    end
    
    def self.convert_asset_with_reps_json_to_xml(asset_json)
      asset_hash = JSON(asset_json)

      doc = REXML::Document.new "<session><values/></session>"
      doc << REXML::XMLDecl.new

      metadata_node = REXML::Element.new "value"
      metadata_node.attributes['id'] = "METADATA"

      metadata_node.add_element REXML::Element.new "values"

      asset_type_node = REXML::Element.new "value"
      asset_type_node.attributes['id'] = "ASSET_TYPE"
      asset_type_data = REXML::Element.new "atom"
      asset_type_data.text = asset_hash["asset_type"]
      asset_type_node.add_element asset_type_data

      version_asset_node = REXML::Element.new "value"
      version_asset_node.attributes['id'] = "VERSION_ASSET"
      version_asset_data = REXML::Element.new "bool"
      version_asset_data.text = asset_hash["version_asset"]
      version_asset_node.add_element version_asset_data

      cust_title_node = REXML::Element.new "value"
      cust_title_node.attributes['id'] = "CUST_TITLE"
      cust_title_data = REXML::Element.new "string"
      cust_title_data.text = asset_hash["cust_title"]
      cust_title_data.attributes['xml:space'] = "preserve"
      cust_title_node.add_element cust_title_data

      metadata_node.elements["values"].add_element asset_type_node
      metadata_node.elements["values"].add_element version_asset_node
      metadata_node.elements["values"].add_element cust_title_node

      doc.elements["session/values"].add_element metadata_node

      representations_node = REXML::Element.new "value"
      representations_node.attributes['id'] = "REPRESENTATIONS"
      representations_node.add_element REXML::Element.new "valuesList"

      asset_hash["representations"].each do | rep |
        values_node = REXML::Element.new "values"

        uri_node = REXML::Element.new "value"
        uri_node.attributes['id'] = "URI"
        uri_data = REXML::Element.new "string"
        uri_data.attributes['xml:space'] = "preserve"
        uri_data.text = ERB::Util::url_encode(rep["uri"]).gsub(/%2F/, "/").gsub(/%3A/, ":")
        uri_node.add_element uri_data

        device_name_node = REXML::Element.new "value"
        device_name_node.attributes['id'] = "DEVICE_NAME"
        device_name_data = REXML::Element.new "string"
        device_name_data.attributes['xml:space'] = "preserve"
        device_name_data.text = rep["device_name"]
        device_name_node.add_element device_name_data

        rep_link_type_node = REXML::Element.new "value"
        rep_link_type_node.attributes['id'] = "REP_LINK_TYPE"
        rep_link_type_data = REXML::Element.new "atom"
        rep_link_type_data.text = rep["rep_link_type"]
        rep_link_type_node.add_element rep_link_type_data

        values_node.add_element device_name_node
        values_node.add_element rep_link_type_node
        values_node.add_element uri_node

        unless rep['proxy_persistence'].nil? then
          proxy_persistence_node = REXML::Element.new "value"
          proxy_persistence_node.attributes['id'] = "PROXY_PREFERENCE"
          proxy_persistence_data = REXML::Element.new "atom"
          proxy_persistence_data.text = rep['proxy_persistence']
          proxy_persistence_node.add_element proxy_persistence_data

          values_node.add_element proxy_persistence_node
        end

        representations_node.elements["valuesList"].add_element values_node
      end

      doc.elements["session/values"].add_element representations_node

      # doc.write( $stdout, 2 )
      return doc
    end
    
    def get_location_for_asset_rep
      xml = @client.list_parent_links({:xml => true}, ['/asset/' + self.asset_number.to_s])
      
      doc = REXML::Document.new xml

      asset_reps_array = Array.new

      doc.elements["session"].each_element do |element|
        address = element.elements["value[@id='ADDRESS']/string"].first.to_s
        link_type= element.elements["value[@id='LINK_TYPE']/int"].first.to_s.to_i
        asset_hash = Hash.new
        asset_hash["address"] = address unless address =~ /^\/asset\//i
        asset_hash["link_type"] = link_type unless link_type.nil?
        asset_reps_array << asset_hash unless asset_hash["address"].nil?
      end

      link_types = parse_link_types_from_xml @client.getmd({:xml => true}, ['/enum/LINK_TYPE'])

      asset_reps_final_array = Array.new

      asset_reps_array.each do |asset_rep|
        asset_reps_hash = Hash.new
        asset_reps_hash["link_type"] = link_types[asset_rep["link_type"].to_s]
        asset_reps_hash["device"] = asset_rep["address"].scan(/^(\/dev\/\d+).*$/i).flatten.first
        dev = FinalCutServer::Device.new(@client, [asset_reps_hash["device"]])
        dev.load_metadata
        if asset_rep["address"] =~ /^\/dev\/\d+\/\d+_.*/i 
          asset_reps_hash["filename"] = asset_rep["address"].scan(/^\/dev\/\d+\/\d+_(.*)$/i).flatten.first
        else
          asset_reps_hash["filename"] = asset_rep["address"].scan(/^\/dev\/\d+\/(.*)$/i).flatten.first
        end
        if asset_rep["address"] =~ /^\/dev\/\d+\/\d+_.*$/i
          lcb = asset_rep["address"].scan(/^\/dev\/\d+\/(\d+)_.*$/i).flatten.first
          lcbhex = lcb.to_i.to_s(16).rjust(16,"0")
          lcbhexarray = lcbhex.scan(/.{2}/).reverse
          asset_reps_hash["full_path"] = "#{dev.metadata['root_path']}/#{lcbhexarray[1]}/#{lcbhexarray[2]}/#{lcbhex}/#{asset_reps_hash['filename']}"
        else
          asset_reps_hash["full_path"] = "#{dev.metadata['root_path']}/#{asset_reps_hash['filename']}"
        end
        asset_reps_final_array << asset_reps_hash
      end

      return asset_reps_final_array
    end
    
    #
    # Return a list of Asset instances matching the given criteria (see FCSEntity.search_for)
    #
    # ==== Optional arguments
    # criteria::    A string for which to search in the assets' data.
    #
    # Returns Array of Asset
    #
    def self.search(criteria = nil, options = {})
      search_for ['/asset'], criteria, options
    end
    
  end
  
end