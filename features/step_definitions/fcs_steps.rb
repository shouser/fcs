Given /^I have initialized a fcs client$/ do
 @client = FinalCutServer::Client.new
end

Given /^I set the client class parameter "([^"]*)" to "([^"]*)"$/ do |param_name, param_value|
	@client.class.class_variable_set(:"@@#{param_name}", param_value)
end

When /^I initialize a new asset with address "([^"]*)"$/ do |fcs_asset_address|
  @asset = FinalCutServer::Asset.new(@client, [fcs_asset_address])
end

When /^I create a new asset with file name "([^"]*)" and the device address is "([^"]*)"$/ do |filename, device_addr|
  Dir.chdir(File.dirname(__FILE__) + "/../support/")
  @client.ssh_scp(Dir.pwd + "/#{filename}", "/tmp/#{filename}") unless @client.test_remote_file("/tmp/#{filename}", '-w')
  @create_asset_addr = @client.create_asset("/tmp/", filename, device_addr)
end

Then /^final cut server should generate an asset address$/ do
  @create_asset_addr =~ /^\/asset\/\d+/
end