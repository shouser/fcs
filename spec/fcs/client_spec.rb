require File.join(File.dirname(__FILE__), "/../spec_helper" )

module FinalCutServer
  describe Client do
    before(:all) do
      @client = FinalCutServer::Client.new()
      @client.class.ssh_username = "shouser"
      @client.class.ssh_private_key_file = "~/.ssh/id_rsa"
      @client.class.ssh_host = "Cook.local"
    end
    
    describe :class do
      subject { @client.class }
    
      it { should respond_to :ssh_username          }
      it { should respond_to :ssh_private_key_file  }
      it { should respond_to :ssh_host              }
    end
    
    subject { @client }
    
    it { should respond_to :bytes_read            }
    it { should respond_to :last_call             }
    it { should respond_to :last_search_xml       }
    it { should respond_to :last_raw_response     }

    context "username, key, and host are valid" do
      
      subject { @client.getmd({}, "/field/CUST_TITLE") }
      
      it "should connect, run getmd, and get a response that starts with an Address: line" do
        @client.getmd({}, '/field/CUST_TITLE').split("\n").first.should eql("Address:       /field/CUST_TITLE")
      end
    end
  end
end