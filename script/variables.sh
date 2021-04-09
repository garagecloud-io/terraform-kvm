#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR=$(cd "$(dirname "$BASH_SOURCE[0]")" &>/dev/null && pwd -P)
PROJ_DIR="$(dirname "$SCRIPT_DIR")"
VAR_FILE="$PROJ_DIR/variable.tf"

source $SCRIPT_DIR/common.sh

# Add variable definiations to the Terraform variable file
function add_variable () {
    # Exit and return error messages if there is no input arguments or 
    # the number of input arguments is more than 3
    if [[ $# -ne 3 ]]; then
        echo "Please enter three input arguments: <variable name>, <type>, and <default value>"
        exit 1
    fi
    # Exist and return error messages if an input argument is an empty string
    if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
        echo "The input argument cannot be an empty string"
        exit 1
    fi
    
    # Convert variable name to lower case using tr
    local var_name=$(echo $1 | tr '[:upper:]' '[:lower:]')
    # Convert variable type to lower case using awk
    local var_type=$(echo $2 | awk '{print tolower($0)}')

    local var_value=$3
    
    # Add "" around the default value when type = string
    if [[ $var_type == "string" ]]; then 
        var_value='"'$var_value'"'
    fi
    
    # append to the variable file
    { 
        echo "variable \"$var_name\" {"
        echo "    type = $var_type"
        echo "    default = $var_value"
        echo "}" 
    }  >> $VAR_FILE
}

# Rename the existing variable file 
if [[ -f "$VAR_FILE" ]]; then
    mv $VAR_FILE $VAR_FILE.$(date +"%Y%m%d_%H%M%S")
fi

touch $VAR_FILE
add_variable "distro" "string" $DISTRO
add_variable "poolname" "string" $POOL_NAME
add_variable "hostcount" "number" $HOST_COUNT
add_variable "interface" "string" $INTERFACE
add_variable "memory" "string" $MEMORY
add_variable "vcpu" "number" $VCPU
add_variable "hostnames" "list" $HOST_NAMES
add_variable "ips" "list" $HOST_IPS
add_variable "macs" "list" $MAC_ADDRS
