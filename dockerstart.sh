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
# API Headers
HEADER_CONTENT_TYPE="Content-Type: application/json"
HEADER_ACCEPT="Accept: application/json"
PIVOTAL_AUTHENTICATION_URI="https://network.pivotal.io/api/v2/authentication"
AUTHORIZATION_TOKEN="Token uP_mWXb1wfQmHBN175VL" # this for testing. Update this with variable passed in

# CURL Specs
CURL_GREP_SPECS="curl -i -v --silent "
CURL_SPECS="curl -i "

#Pivotal Product URI's
PIVOTAL_GEMFIRE_RHELSIX_URL="https://network.pivotal.io/api/v2/products/pivotal-gemfire/releases/478/product_files/2544/download"
PIVOTAL_GEMFIRE_RHELSEVEN_URL="https://network.pivotal.io/api/v2/products/pivotal-gemfire/releases/478/product_files/2545/download"
PIVOTAL_GEMFIRE_RHELFIVE_URI="https://network.pivotal.io/api/v2/products/pivotal-gemfire/releases/478/product_files/2543/download"
PIVOTAL_GEMFIRE_DEBIAN_URI="https://network.pivotal.io/api/v2/products/pivotal-gemfire/releases/478/product_files/2542/download"

#Linux Distro's
# Pretty self explanatory, we have multiple OS's we can build for gemfire.
LINUX_REDHATE_FIVE="RHEL5"
LINUX_REDHAT_SIX="RHEL6"
LINUX_REDHAT_SEVEN="RHEL7"
LINUX_DEBIAN="DEBIAN"



#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# all methods are defined here
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# global sleep method
function fn_sleepy_time()
{
  # pass in an arugment for the amount of seconds that you need to sleep.
  seconds=$1
  sleep $1
  echo $! > dockerbash.sleep.pid
  fg
}

# global method for exception exits
function fn_exception_exit()
{
  echo "$1" 1>&2
  exit 1
}

# here we call a function to kill the sleepy time sub process
function fn_kill_sleepy_time()
{
  pkill -P $(dockerbash.pid) sleep
}

fn_authenticate_api()
{
  curl -i -H "${HEADER_ACCEPT}" -H "${HEADER_CONTENT_TYPE}" -H "Authorization: Token $1" -X GET "${PIVOTAL_AUTHENTICATION_URI}" --output "${APIResponse}" 2> /dev/null > "${APIResponse}"
  if ["$APIResponse" <> "200"]
    fn_sleepy_time 5
    fn_kill_sleepy_time
    fn_exception_exit
  fi
}

fn_pivotal_fetch_bits()
{

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# The Pivotal File API doesn't expose files locally.
# A post request returns a redirect to a remote cdn that's in Amazon
# That URI will return file
# This method returns the remote CDN
# arguments $1= API security token $2=Gemfire Host OS Flavor - returns message "success"
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

local dir=pwd

case "2$" in
  "RHEL5")
    local fqn_bits="$dir/pivotal-gemfire-8.2.0-17919.el5.noarch.rpm"
    local luri="${CURL_GREP_SPECS}" -H "${HEADER_ACCEPT}" -H "${HEADER_CONTENT_TYPE}" -H "Authorization: Token $1" -X POST "${PIVOTAL_GEMFIRE_RHELFIVE_URI}" 2>&1 | grep Location:
    local lcdnuri="${luri##*: }"
    CURL=$ curl --fail -O '"${lcdnuri}"' 2>&1)
    while inotifywait -e close_write "${fqn_bits}"; do
      echo "I'm downloading your file. Go grab a coffee!"
      if [ $? -ne 0]; then
        echo $CURL | grep --quiet 'Ah Shit, the requested URL returned an error:404'
        fn_sleepy_time 5
        fn_kill_sleepy_time
        fn_exception_exit
        fi
    done ;;
  "RHEL6")
    local fqn_bits="$dir/pivotal-gemfire-8.2.0-17919.el6.noarch.rpm"
    local luri="${CURL_GREP_SPECS}" -H "${HEADER_ACCEPT}" -H "${HEADER_CONTENT_TYPE}" -H "Authorization: Token $1" -X POST "${PIVOTAL_GEMFIRE_RHELSIX_URI}" 2>&1 | grep Location:
    local lcdnuri="${luri##*: }"
    CURL=$ curl --fail -O '"${lcdnuri}"' 2>&1)
    while inotifywait -e close_write "${fqn_bits}"; do
      echo "I'm downloading your file. Go grab a coffee!"
      if [ $? -ne 0]; then
        echo $CURL | grep --quiet 'Ah Shit, the requested URL returned an error:404'
        fn_sleepy_time 5
        fn_kill_sleepy_time
        fn_exception_exit
        fi
    done ;;
  "RHEL7")
    local fqn_bits="$dir/pivotal-gemfire-8.2.0-17919.el7.noarch.rpm"
    local luri="${CURL_GREP_SPECS}" -H "${HEADER_ACCEPT}" -H "${HEADER_CONTENT_TYPE}" -H "Authorization: Token $1" -X POST "${PIVOTAL_GEMFIRE_RHELSEVEN_URI}" 2>&1 | grep Location:
    local lcdnuri="${luri##*: }"
    CURL=$ curl --fail -O '"${lcdnuri}"' 2>&1)
    while inotifywait -e close_write "${fqn_bits}"; do
      echo "I'm downloading your file. Go grab a coffee!"
      if [ $? -ne 0]; then
        echo $CURL | grep --quiet 'Ah Shit, the requested URL returned an error:404'
          fn_sleepy_time 5
          fn_kill_sleepy_time
          fn_exception_exit
        fi
    done ;;
  "DEBIAN")
    local fqn_bits="$dir/pivotal-gemfire_8.2.0-17919_all.deb"
    local luri="${CURL_GREP_SPECS}" -H "${HEADER_ACCEPT}" -H "${HEADER_CONTENT_TYPE}" -H "Authorization: Token $1" -X POST "${PIVOTAL_GEMFIRE_DEBIAN_URI}" 2>&1 | grep Location:
    local lcdnuri="${luri##*: }"
    CURL=$ curl --fail -O '"${lcdnuri}"' 2>&1)
    while inotifywait -e close_write "${fqn_bits}"; do
      echo "I'm downloading your file. Go grab a coffee!"
      if [ $? -ne 0]; then
        echo $CURL | grep --quiet 'Ah Shit, the requested URL returned an error:404'
          fn_sleepy_time 5
          fn_kill_sleepy_time
          fn_exception_exit
        fi
    done ;;
esac

return "success"

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
echo "The Following OSs are supported:"
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
  echo "I have detected that youre running a OSX based operating system! This is currently not supported by this process!"
  echo "You will have to manually hack the docker file, manually download the gemfire bits!"
  fn_sleepy_time 7
  fn_kill_sleepy_time
  fn_exception_exit
fi

# check to see if docker or wget is installed
$ command -v docker >/dev/null 2>&1 ||
{ echo "I require docker, but its not installed.  See Ya!." >&2; fn_sleepy_time 5, fn_kill_sleepy_time; fn_exception_exit;}

#$ command -v wget >/dev/null 2>&1 ||
##{ echo "I require wget, but its not installed.  See Ya!." >&2; fn_sleepy_time 5, fn_kill_sleepy_time; fn_exception_exit;}



# Lets ask the question to see if we are doing API validation or manual downloads.
echo "Would you like to use API authentication to the Pivotal Network?"
echo -n "Enter Yes or No and press [ENTER]: "
read api_authentication_validation

# What OS are we using inside of the docker image....
echo "Which OS are you building this image for?"
echo "IMPORTANT - MAKE SURE YOU USE THE SAME CASE AND FORMATTING FOR THE Operating System Name USED IN THE CHOICES BELOW!" # ToDO add some camel case code to deal with rule breakers.
echo "The Operating System you are selecting below is the Operating System I will use in the docker image, and not your local machine."
echo "RHEL5"
echo "RHEL6"
echo "RHEL7"
echo "DEBIAN"
echo -n "Enter OS Name and press [ENTER]: "
read docker_os

echo "I need to know where you where is the location that you cloned me from GitHub..."
echo "There is a directory inside the repo called bits."
echo -n "Please enter the fully qualified path here and press [ENTER]: "
read path_to_bits


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
      authenticate_api("${api_token}")
      if [-z "$APIResponse"] == 200
        # we are authenticated, now, we can go get the product were looking for.
      then
        case "$docker_os" in
          "RHEL5")
            local msg=(fn_pivotal_fetch_bits("${api_token}", "${docker_os}"))
            if "${msg}" == "success" then
              #go start docker file with the appropriate os distro
            else
              fn_sleepy_time 5
              fn_kill_sleepy_time
              fn_exception_exit
            fi ;;
          "RHEL6")
            local msg=(fn_pivotal_fetch_bits("${api_token}", "${docker_os}"))
            if "${msg}" == "success" then
              #go start docker file with the appropriate os distro
            else
              echo "Something has occured. The return message from the fn_pivotal_fetch_bits function returned ${msg}. Tell someone! Exiting..."
              fn_sleepy_time 5
              fn_kill_sleepy_time
              fn_exception_exit
            fi ;;
          "RHEL7")
            local msg=(fn_pivotal_fetch_bits("${api_token}", "${docker_os}"))
            if "${msg}" == "success" then
              #go start docker file with the appropriate os distro
            else
              echo "Something has occured. The return message from the fn_pivotal_fetch_bits function returned ${msg}. Tell someone! Exiting..."
              fn_sleepy_time 5
              fn_kill_sleepy_time
              fn_exception_exit
            fi ;;

          "DEBIAN")
            local msg=(fn_pivotal_fetch_bits("${api_token}", "${docker_os}"))
            if "${msg}" == "success" then
              #go start docker file with the appropriate os distro
            else
              echo "Something has occured. The return message from the fn_pivotal_fetch_bits function returned ${msg}. Tell someone! Exiting..."
              fn_sleepy_time 5
              fn_kill_sleepy_time
              fn_exception_exit
            fi ;;
          *) echo "The Operating System that you entered does not match any of my choices. Make sure that your entry exactly matches the choices presented! ABORTING!"
            fn_sleepy_time 6
            kill_sleepytime
            fn_exception_exit ;;
          # nothing matched, do the exit thing.
        esac
      else
        echo "I require an API token for API download. Re-run me once you have the API token! ABORTING"
        fn_sleepy_time 5
        fn_kill_sleepy_time
        fn_exception_exit
      fi  ;;
    [nN] | [n|N][O|o] )
    # enter logic for this scenario
    ;;
    *) echo "You have not entered an answer, please enter Yes or No! Program will close!!!"
      fn_sleepy_time 5
      fn_kill_sleepy_time
      fn_exception_exit  ;;
  esac
