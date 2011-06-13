

module FinalCutServer
  
  class MediaFile < FCSEntity
    attr_reader :metadata
    
    md_accessor :id, :filename, :filesize, :date, :wrapper_format
    md_accessor :unix_userid, :unix_groupid
    
    def self.md_key_map
      {
        "LCB_ID" => :id,
        "LCB_FILENAME" => :filename,
        "LCB_FILESIZE" => :filesize,
        "LCB_DATE" => :date,
        "WRAPPER_FORMAT" => :wrapper_format,
        "UNIX_FILENAME" => :filename,
        "UNIX_FILESIZE" => :filesize,
        "UNIX_MTIME" => :date,
        "UNIX_USERID" => :unix_userid,
        "UNIX_GROUPID" => :unix_groupid
      }
    end
    
    def self.md_type_coercion_map
      {
        "LCB_ID" => :to_i,
        "LCB_FILESIZE" => :to_i,
        "LCB_DATE" => :to_fcs_style_time,
        "UNIX_FILESIZE" => :to_i,
        "UNIX_MTIME" => :to_fcs_style_time,
        "UNIX_USERID" => :to_i,
        "UNIX_GROUPID" => :to_i
      }
    end
    
    def self.preferred_metadata_format
      METADATA_FORMAT_XML
    end
    
    def load_metadata
      super
    end
    
    #
    # Return a list of MediaFile instances matching the given criteria (see FCSEntity.search_for)
    #
    # ==== Optional arguments
    # criteria::    A string for which to search in the files' data.
    #
    # Returns Array of MediaFile
    #
    def self.search(criteria = nil, options = {})
      search_for ['/asset'], criteria, options
    end
    
  end
  
end