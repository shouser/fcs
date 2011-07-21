Feature: asset is created

  As a user
  I want to create an asset
	So that I can store data and create relationships with that asset
	
	Scenario: good source file not on destination device
		Given I have initialized a fcs client
		And I set the client class parameter "ssh_username" to "shouser"
		And I set the client class parameter "ssh_private_key_file" to "~/.ssh/id_rsa"
		And I set the client class parameter "ssh_host" to "shaithus.chickenkiller.com"
		When I create a new asset with file name "test.mov" and the device address is "/dev/6"
		Then final cut server should generate an asset address