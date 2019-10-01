## AWS Windows Userdata

A simple Powershell script that:
* Queries metadata for region, environment and other metadata information to create tags
* Assigns unique hostname based on instance ID
* Joins the specified domain
* Pulls down Powershell script to enable Ansible's ability to configure the machine
* Tags the instance with an extended name derived from the stack and IP address
* Reboots the machine
