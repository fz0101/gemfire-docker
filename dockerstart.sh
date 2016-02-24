#!/bin/bash
################################################################################
# Author:   Fernando Zavala
# Company:  Pivotal Software Inc.
# Date:     2/24/2016
# Purpose:  Dockerizing Pivotal Gemfire
#           This is the bash script that either downloads bits, via automation
#           or you can manually download the files and rerun script to dockerize
#           Can dockerize the in the following OS
#           RHEL 5,6,7 and Debian Wheezy, Jessie,
#           Ubuntu is also possible, but not supported, using the debian bits
################################################################################

# To Do regression test the shit out of this script....
# To Do Make sure that the constants are correct. The API docs are here https://network.pivotal.io/docs/file_download_api#how-to-authenticate
# To Do 2.24.2016

# Constants
HEADER_CONTENT_TYPE="Content-Type: application/json"
HEADER_ACCEPT="Accept: application/json"
PIVOTAL_AUTHENTICATION_URI="https://network.pivotal.io/api/v2/authentication"
AUTHORIZATION_TOKEN="Token uP_mWXb1wfQmHBN175VL" # this for testing. Update this with variable passed in
PIVOTAL_GEMFIRE_BASE_URI="https://network.pivotal.io/products/pivotal-gemfire#/releases/478/file_groups/302" # this URI is hardcoded, eventually, there will be a some more sophistication to inlucde other data products.
PIVOTAL_GEMFIRE_EULA_BASE_URI="https://network.pivotal.io/api/v2/eulas/68"
PIVOTAL_GEMFIRE_EULA_ACCEPTANCE_URI="https://network.pivotal.io/api/v2/products/pivotal-gemfire/releases/478/download"
# Pretty self explanatory, we have multiple OS's we can build for gemfire.
LINUX_REDHATE_FIVE="RHEL5"
LINUX_REDHAT_SIX="RHEL6"
LINUX_REDHAT_SEVEN="RHEL7"
LINUX_DEBIAN="DEBIAN"


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# all methods are defined here
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# global sleep method
function sleepytime()
{
  # pass in an arugment for the amount of seconds that you need to sleep.
  seconds=$1
  sleep $1
  echo $! > dockerbash.sleep.pid
  fg
}

# global method for exception exits
function exception_exit()
{
  echo "$1" 1>&2
  exit 1
}

# here we call a function to kill the sleepy time sub process
function kill_sleepytime()
{
  pkill -P $(dockerbash.pid) sleep
}

authenticate_api()
{
  curl -i -H "${HEADER_ACCEPT}" -H "${HEADER_CONTENT_TYPE}" -H "Authorization: Token $1" -X GET "${PIVOTAL_AUTHENTICATION_URI}" --output "${APIResponse}" 2> /dev/null > "${APIResponse}"
  if ["$APIResponse" <> "200"]
    sleepytime 5
    exception_exit
  fi
}

# Main Init!
# lets make sure the user gets to just see the dialog
echo "#################################################################################################"
echo "Welcome to Pivotal Gemfire Docker Image."
echo "Here you have a few options to install Gemfire in a docker container."
echo "You must have Pivotal Network account credentials"
echo "You can either manually download the Gemfire bits, or you can provide a Pivotal Network API Token"
echo "Please note, this process is not officially supported by Pivotal Software"
echo "This process makes a these assumptions"
echo "The Following OS's are supported:"
echo "RedHat Linux 5, 6, and 7"
echo "Debian Jessie"
echo "The Gemfire release 8.2 is installed by default"
echo "The latest version of docker must be installed."
echo "Mac OSX is not supported with this docker file. You may need to edit it, and not use this script! "
echo "#################################################################################################"
sleepytime 5
kill_sleepytime # pid sub process that was created must be taken out to the pasture

# bash does not support docker machine, yet.
if ["$(uname)" == "Darwin"]
  echo "I have detected that you're running a OSX based operating system! This is currently not supported by this process!"
  echo "You will have to manually hack the docker file, manually download the gemfire bits!"
  sleepytime 7
  kill_sleepytime
  exception_exit
fi

# check to see if docker is installed
$ command -v docker >/dev/null 2>&1 ||
{ echo "I require docker, but it's not installed.  See Ya!." >&2; sleepytime 5, kill_sleepytime; exception_exit;}


# Lets ask the question to see if we are doing API validation or manual downloads.
echo "Would you like to use API authentication to the Pivotal Network?"
echo -n "Enter Yes or No:"
read api_authentication_validation

# What OS are we using inside of the docker image....
echo "Which OS are you building this image for?"
echo "IMPORTANT - MAKE SURE YOU USE THE SAME CASE AND FORMATTING FOR THE Operating System Name USED IN THE CHOICES BELOW!" # ToDO add some camel case code to deal with rule breakers.
echo "The Operating System you're selecting below is the Operating System I will use in the docker image, and not your local machine."
echo "RHEL5"
echo "RHEL6"
echo "RHEL7"
echo "DEBIAN"
echo -n "Enter OS Name:"
read docker_os

# 2.24.2016
# To Do add wget stuff to grab the bits. create function to check/create dir to download bits. Call docker file and run the shit.
# Here we have to make sure the user entered something.
case "$api_authentication_validation" in
    [yY] | [yY][Ee][Ss] )
    # enter logic here for api token collection
    echo "Your API token can be found by logging into https://login.run.pivotal.io/login and click on Edit Profile. The token is at the bottom of the page."
    echo -n "Enter Token"
    read api_token
    if [-z "$api_token"] <> ""
    # something was entered, no validation, just try to authenticate
      authenticate_api($api_token)
      if [-z "$APIResponse"] == 200
        # we are authenticated, now, we can go get the product we're looking for.
        case "$docker_os" in
          "RHEL5")  ;; #run wget download for the rhel5 flavor of gemfire # ToDO write method to create dir for gemfire bits, then start docker file
          "RHEL6")  ;; #run wget download for the rhel6 flavor of gemfire # ToDO write method to create dir for gemfire bits, then start docker file
          "RHEL7")  ;; #run wget download for the rhel7 flavor of gemfire # ToDO write method to create dir for gemfire bits, then start docker file
          "DEBIAN") ;; #run wget download for the debian flavor of gemfire # ToDO write method to create dir for gemfire bits, then start docker file
          *) echo "The Operating System that you entered does not match any of my choices. Make sure that your entry exactly matches the choices presented! ABORTING!"
            sleepytime 6
            kill_sleepytime
            exception_exit
          # nothing matched, do the exit thing.
        esac
    fi

    ;;
    [nN] | [n|N][O|o] )
    # enter logic for this scenario
    ;;
    *) echo "You have not entered an answer, please enter Yes or No! Program will close!!!"
      sleepytime 5
      exception_exit
      ;;
  esac
