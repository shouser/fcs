
module FinalCutServer
  
  class Project < FCSEntity
    attr_reader :metadata

    md_accessor :title, :job_client, :job_number, :producer, :status
    
    def self.md_key_map
      {
        "CUST_TITLE" => :title,
        "PA_MD_CUST_CLIENT" => :job_client,
        "PA_MD_CUST_JOB_NUMBER" => :job_number,
        "CUST_PROMO_PRODUCER" => :producer,
        "CUST_PROJECT_STATUS" => :status
      }
    end
    
    def self.preferred_metadata_format
      METADATA_FORMAT_XML
    end
    
    def load_metadata
      super
    end
    
  end
  
end