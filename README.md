# [ReportHub](http://reporthub.immap.org)
> 
> Reporting Workflow. Decision Support. Real-Time.
> 
> Developer documentation for local project setup

### Requirements

- Dropbox 33.4.xx
- Vagrant v1.9.xx
- VirtualBox v5.1.xx

### Notes
- $ git clone requires GIT CMD
- CMD needs to be run as administrator.
- After installing, update the BIOS setting to enable VT-x. On Windows 10, go to 
		``Settings -> Update & Security -> Recovery -> Advanced startup -> Restart Now -> Troubleshoot -> Advanced Options -> UEFI Firmware Settings`` and change ``Intel VT`` to ``enable``.

# Getting Started
- The first steps will be to establish a local development environment on your machine and establish connection with the DEV server.

### Steps

1. Install Software Requirements listed above on your local machine
2. Unzip [ngm folder](https://www.dropbox.com/s/fg4nqibkiqbr80x/ngm.zip?dl=1) to local machine and unzip
	
### Contributing Code
- Please review the following links in order to understand how to contribute code to ReportHub repositories

### GitHub Fork & Pull Approach

- [Fork & Pull Approach](https://gist.github.com/Chaser324/ce0505fbed06b947d962)
- [Github Flow](https://guides.github.com/introduction/flow/)


# Vagrant Local Server
- Run the following commands to setup the local development environment.

### Steps
  
1. on the cmd line, navigate to ``ngm/ngm-reportShell`` folder

		$ i.e. cd ~/Users/fitzpaddy/Sites/ngm/ngm-reportShell
		
3. Update the GitHub repository locations to your forked version of the code

		# UPDATE TO YOUR FORKED REPO! (lines 146 & 168)
		sudo git clone https://github.com/<your.fork>/ngm-reportHub.git

5. Run [Vagrant Up](https://www.vagrantup.com/docs/cli/up.html) command

		$ vagrant up
		
	> NOTE: This will take some time to fetch the Ubuntu Lts 14.04 VirtualBox image as well as install server software to establish a replica local server environemnt

5. During install, review VirtualBox configurations in 
	- ``ngm-reportShell/Vagrantfile``
	- ``ngm-reportShell/ngm-reporthub.shell.build.sh``


# Running ReportHub
- Once the VirtualBox is completed installation, you can access the configured ReportHub Ubuntu LTS 14.0.4 Virtual Machine via the ``vagrant ssh`` command

### Steps

1. Within the ``ngm-reportShell`` folder, ssh into machine

		$ vagrant ssh
		
2. Within the server, navigate to the ``ngm-reportEngine`` repository

		$ cd /home/ubuntu/nginx/www/ngm-reportEngine
		
3. Start the Sails RestAPI application

		$ sudo sails lift

4. Navigate to [http://192.168.33.16](http://192.168.33.16) and ReportHub is running!


# Admin Import
- Navigate to ``ngm/scripts/admin`` to review import script for Admin levels to the standardized ReportHub db structure


# ReportHub Modules
- Navigate to ``ngm/ngm-reportHub/README.md`` to review implementing ReportHub modules
