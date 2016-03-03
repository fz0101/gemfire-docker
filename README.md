# gemfire-docker

Pretty Simple -
Must have a user login into https://login.run.pivotal.io/login
Scenario is you can either download the gemfire bits manually, or you can download the binary via the Pivotal Network API.
You must have the token.

Workflow
Bash script will drive this process.

Manual download ---> download bits to git repo root --> download files --> rerun script and say manually downloaded
API Download ---> Grab your token from https://login.run.pivotal.io/login --> enter yes, on API download on bash --> enter token --> script will download bits --> Run DockerFile

Made an adjustment, there's no need to run all the silly logic I added for different OS install.
The automated File API will download the tar file for Linux.
The Docker file will extract, set up Java runtime, and configure all gemfire shenanigans.

This is still in early engineering. Features that are coming:

Ability to select other pivotal products
Other product DockerFiles
Support Docker-Machine in Mac
Better logging
Support for Debian-Ubuntu-CentOS
pOc based images that contain example data sets, etc. -- This is way far down the list.
