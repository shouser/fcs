
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
    
    def get_project_heirarchy(project_addr = nil)
      if project_addr.nil? then
        load_metadata
        project_addr = "/project/" + self.metadata["PROJECT_NUMBER"].to_s
      end

      options = Hash.new
      options[:xml] = true

      root_node = Tree::TreeNode.new(project_addr, "project node") if root_node.nil?

      child_links_xml = @client.list_parent_links options, project_addr
      doc = REXML::Document.new child_links_xml

      doc.elements["session"].each_element do |element|
        address = element.elements["value[@id='ADDRESS']/string"].first.to_s
        if address =~ /^\/project\/\d+$/ then
          root_node << get_project_heirarchy(address)
        else
          root_node << Tree::TreeNode.new(address, "non-project node")
        end
      end

      return root_node
    end
    
  end
  
end