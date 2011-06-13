require './fcs'
require 'json'

FinalCutServer.debug = false

@client = FinalCutServer::Client.new

@client.class.ssh_username = "shouser"
@client.class.ssh_private_key_file = "~/.ssh/id_rsa"
@client.class.ssh_host = "cook.local"

#client.getmd({:xml => true}, ['/asset/1'])
#puts client.list_parent_links({:xml => true}, ['/asset/1'])


# dev = FinalCutServer::Device.new(client, ['/dev/1'])
# dev.load_metadata
# puts dev.metadata


# puts dev.metadata["DB_LAST_FETCHED"].to_s
# puts dev.metadata["DB_LAST_FETCHED"].to_s.to_fcs_style_time

# puts FinalCutServer::Device.search("", {:xml => true})

# search_json = '{"search":{"type":"interesect","criteria":[{"name":"ASSET_NUMBER","op":"eq","data_type":"bigint","value":1,"offset":0},{"name":"FILE_CREATE_DATE","op":"gt","data_type":"atom","value":"now","offset":-6000000}]}}'
# 

project = FinalCutServer::Project.new(@client, ['/project/1'])
project.load_metadata
#puts project.metadata


asset = FinalCutServer::Asset.new(@client, ['/asset/1'])
asset.load_metadata
x = asset.metadata.to_json

# 
# result = FinalCutServer::Asset.search("", {:xml => true, :search_hash => JSON(search_json)})
# # puts result.length
# 
# asset_links = FinalCutServer::MediaFile.new(client, ['/asset/1'])
# asset_links.load_metadata
# puts asset_links.metadata
# 
factory = FinalCutServer::ObjectFactory.instance
#puts factory.all_objects

# def parse_link_types_from_xml(xml)
#   link_types = Hash.new
#   
#   doc = REXML::Document.new xml
#   
#   doc.elements["session/values/value[@id='ENUM_ENTRIES']/valuesList"].each_element do |element|
#     link_types[element.elements["value[@id='ENUM_VALUE']/int"].text] = element.elements["value[@id='ENUM_LABEL']/string"].text
#   end
#   
#   return link_types
# end

# def get_location_for_asset_rep(xml)
#   doc = REXML::Document.new xml
# 
#   asset_reps_array = Array.new
#   
#   doc.elements["session"].each_element do |element|
#     address = element.elements["value[@id='ADDRESS']/string"].first.to_s
#     link_type= element.elements["value[@id='LINK_TYPE']/int"].first.to_s.to_i
#     asset_hash = Hash.new
#     asset_hash["address"] = address unless address =~ /^\/asset\//i
#     asset_hash["link_type"] = link_type unless link_type.nil?
#     asset_reps_array << asset_hash unless asset_hash["address"].nil?
#   end
#   
#   link_types = parse_link_types_from_xml @client.getmd({:xml => true}, ['/enum/LINK_TYPE'])
# 
#   asset_reps_final_array = Array.new
#   
#   asset_reps_array.each do |asset_rep|
#     asset_reps_hash = Hash.new
#     asset_reps_hash["link_type"] = link_types[asset_rep["link_type"].to_s]
#     asset_reps_hash["device"] = asset_rep["address"].scan(/^(\/dev\/\d+).*$/i).flatten.first
#     dev = FinalCutServer::Device.new(@client, [asset_reps_hash["device"]])
#     dev.load_metadata
#     if asset_rep["address"] =~ /^\/dev\/\d+\/\d+_.*/i 
#       asset_reps_hash["filename"] = asset_rep["address"].scan(/^\/dev\/\d+\/\d+_(.*)$/i).flatten.first
#     else
#       asset_reps_hash["filename"] = asset_rep["address"].scan(/^\/dev\/\d+\/(.*)$/i).flatten.first
#     end
#     if asset_rep["address"] =~ /^\/dev\/\d+\/\d+_.*$/i
#       lcb = asset_rep["address"].scan(/^\/dev\/\d+\/(\d+)_.*$/i).flatten.first
#       lcbhex = lcb.to_i.to_s(16).rjust(16,"0")
#       lcbhexarray = lcbhex.scan(/.{2}/).reverse
#       asset_reps_hash["full_path"] = "#{dev.metadata['root_path']}/#{lcbhexarray[1]}/#{lcbhexarray[2]}/#{lcbhex}/#{asset_reps_hash['filename']}"
#     else
#       asset_reps_hash["full_path"] = "#{dev.metadata['root_path']}/#{asset_reps_hash['filename']}"
#     end
#     asset_reps_final_array << asset_reps_hash
#   end
#   
#   return asset_reps_final_array
# end

# asset_rep_xml = @client.list_parent_links({:xml => true}, ['/asset/1'])
# puts get_location_for_asset_rep(asset_rep_xml).to_json

puts asset.get_location_for_asset_rep
# def hash_to_md_xml(md)
#   doc = REXML::Document.new "<session><values/></session>"
#   
#   doc << REXML::XMLDecl.new
# 
#   md.each do |name, item|
#     if name =~ /_node$/
#       value_node = REXML::Element.new "value"
#       value_node.attributes['id'] = name.gsub(/_node$/, '')
#       data_node = REXML::Element.new item["type"]
#       if item['type'] == "timestamp"
#         data_node.text = item['value'].to_s.to_fcs_style_time
#       elsif item['type'] == "string"
#         data_node.text = item['value']
#         data_node.attributes['xml:space'] = "preserve"
#       end
#       value_node.add_element data_node
#       doc.elements["session/values"].add_element value_node
#     end
#   end
#   
#   return doc.to_s
# end

asset_md_hash = JSON(x)
puts FinalCutServer::FCSEntity.hash_to_md_xml(asset_md_hash)

