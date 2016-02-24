#!/bin/bash

# Display intro dialog
# Author: Fernando Zavala
# Purpose: Building Dockerized GemFire image
# Date 2/23/2016

#Constants
HEADER_CONTENT_TYPE="Content-Type: application/json"
HEADER_ACCEPT="Accept: application/json"
PIVOTAL_AUTHENTICATION_URI="https://network.pivotal.io/api/v2/authentication"

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

# lets make sure the user gets to just see the dialog
echo "#################################################################################################"
echo "Welcome to Pivotal Gemfire Docker Image."
echo "Here you have a few options to install Gemfire in a docker container."
echo "You must have Pivotal Network account credentials"
echo "You can either manually download the Gemfire bits, or you can provide a Pivotal Network API Token"
echo "Please note, this process is not officially supported by Pivotal Software"
echo "#################################################################################################"
sleepytime 5


# At this time, this bash script only supports OSX. We need to do a quick check, and if it's not OSX, we bail
#if ["$(uname)" <> "Darwin"]
#  echo "You are running an unsupported OS at this moment! Program will now exit"
#  sleepytime 5
#  exception_exit
#fi



# Building all functions up here, so we can ref them below.
# Here we authenticate the API based on the credentials that are passed into the script.
authenticate_api()
{
  curl -i -H "${HEADER_ACCEPT}" -H "${HEADER_CONTENT_TYPE}" -H "Authorization: Token $1" -X GET "${PIVOTAL_AUTHENTICATION_URI}" --output "${APIResponse}" 2> /dev/null > "${APIResponse}"
  if ["$APIResponse" <> "200"]
    sleepytime 5
    exception_exit
  fi
}


#main_initialization()
#
#show main dialog
#echo "Would you like to use API authentication to the Pivotal Network?"
#echo -n "Enter Yes or No:"
#read api_authentication_validation
#}

# Lets ask the question to see if we are doing API validation or manual downloads.
echo "Would you like to use API authentication to the Pivotal Network?"
echo -n "Enter Yes or No:"
read api_authentication_validation

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
