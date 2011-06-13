
module FinalCutServer
  
  class Element < FCSEntity
    
    # Element metadata
    md_accessor :title, :created_at, :last_modified, :last_accessed, :entity_create_user_name
    md_accessor :element_id, :element_guid, :element_type, :entity_is_local, :asset_address, :resolved
    
    # FCP metadata
    md_accessor :name, :uuid, :duration, :framerate, :in, :out
    md_accessor :master_clip_id, :master_clip, :good, :timecode, :anamorphic
    md_accessor :fcp_element_id, :fcp_media_type, :fcp_pathurl, :fcp_original_pathurl
    md_accessor :fcp_update_op, :fcp_element_type
    
    def self.md_key_map
      {
        "CUST_TITLE" => :title,
        "ENTITY_CREATED" => :created_at,
        "MD_LAST_MODIFIED" => :last_modified,
        "LAST_ACCESSED" => :last_accessed,
        "ENTITY_CREATE_USER_NAME" => :entity_create_user_name,
        "ELEMENT_ID" => :element_id,
        "ELEMENT_GUID" => :element_guid,
        "ELEMENT_TYPE" => :element_type,
        "ENTITY_IS_LOCAL" => :entity_is_local,
        "ASSET_ADDRESS" => :asset_address,
        "RESOLVED_ELEMENT" => :resolved,
        
        "PA_MD_FCP_NAME" => :name,
        "PA_MD_FCP_UUID" => :uuid,
        "PA_MD_FCP_DURATION" => :duration,
        "PA_MD_FCP_FRAMERATE" => :framerate,
        "PA_MD_FCP_IN" => :in,
        "PA_MD_FCP_OUT" => :out,
        "PA_MD_FCP_MASTER_CLIP_ID" => :master_clip_id,
        "PA_MD_FCP_MASTER_CLIP" => :master_clip,
        "PA_MD_FCP_GOOD" => :good,
        "PA_MD_FCP_TIMECODE" => :timecode,
        "PA_MD_FCP_ANAMORPHIC" => :anamorphic,
        
        "FCP_ELEMENT_ID" => :fcp_element_id,
        "FCP_MEDIA_TYPE" => :fcp_media_type,
        "FCP_PATHURL" => :fcp_pathurl,
        "FCP_ORIGINAL_PATHURL" => :fcp_original_pathurl,
        "FCP_UPDATE_OP" => :fcp_update_op,
        "FCP_ELEMENT_TYPE" => :fcp_element_type
      }
    end
    
    def self.md_type_coercion_map
      {
        "ENTITY_CREATED" => :to_fcs_style_time,
        "MD_LAST_MODIFIED" => :to_fcs_style_time,
        "LAST_ACCESSED" => :to_fcs_style_time,
        "ENTITY_IS_LOCAL" => :to_bool,
        "ELEMENT_ID" => :to_i,
        "RESOLVED_ELEMENT" => :to_bool,
        
        "PA_MD_FCP_DURATION" => :to_i,
        "PA_MD_FCP_IN" => :to_i,
        "PA_MD_FCP_OUT" => :to_i,
        "PA_MD_FCP_MASTER_CLIP" => :to_bool,
        "PA_MD_FCP_GOOD" => :to_bool,
        "PA_MD_FCP_ANAMORPHIC" => :to_bool,
        
        "FCP_MEDIA_TYPE" => :to_i,
        "FCP_UPDATE_OP" => :to_i,
        "FCP_ELEMENT_TYPE" => :to_i
      }
    end
    
    def self.preferred_metadata_format
      METADATA_FORMAT_XML
    end
    
    #
    # Returns a list of Element instances matching the given criteria (see FCSEntity.search_for)
    #
    # ==== Optional arguments
    # criteria::    A string for which to search in the elements' data.
    #
    # Returns Array of Element
    #
    def self.search(criteria = nil)
      search_for '/element', criteria
    end
    
  end
  
end