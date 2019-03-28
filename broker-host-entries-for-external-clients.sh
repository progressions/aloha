#!/usr/bin/env bash
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Specifically, this script is intended SOLELY to support the Confluent
# Quick Start offering in Amazon Web Services. It is not recommended
# for use in any other production environment.
#
#
# Script for gathering the Public IPv4 Address, PrivateDnsName, and tagged
# Name of EC2 instances within a CloudFormation stack and adding corresponding
# entries in /etc/hosts file such that the Public IPv4 Addresses are associated
# with the respective PrivateDnsName. This allows external Kafka clients to
# communicate with the brokers using their Public IPv4 addresses successfully,
# whereas without these additions to /etc/hosts, errors would occur.

# See these issues / pull requests for why this is necessary:
#   https://github.com/aws-quickstart/quickstart-confluent-kafka/issues/63
#   https://github.com/aws-quickstart/quickstart-confluent-kafka/pull/64 


# This function takes 1 argument: the cloud formation stack which contains your
# brokers.
#
# e.g. Confluent-Platform-ConfluentStack-3XIX5P0XLJLZ-BrokerStack-10ETGHDQ2QSG4
#
# It outputs the entries that should be added to /etc/hosts file on your
# external Kafka clients (with respect to brokers running in AWS EC2).
#
get_and_print_broker_etc_host_entries() {

    if ! [ -x "$(command -v aws)" ] ; then
        echo 'Error: aws is not installed. Please install and configure the AWS Command Line Interface.' >&2
        exit 1
    fi
    
    if [ -z "${1}" ]; then
        printf "ERROR: usage: ${0} <broker_cloud_formation_stack_name>\n" >&2
        exit 2
    fi
    
    printf "\n# Workaround for AWS Quickstart Confluent Kafka - external Client Support\n"
    
    aws ec2 describe-instances \
        --output text \
        --filters \
            "Name=tag:aws:cloudformation:stack-name,Values=${1}" \
            "Name=instance-state-name,Values=running" \
        --query 'Reservations[].Instances[].[PublicIpAddress,PrivateDnsName,Tags[?Key==`Name`] | [0].Value ]' |
    sort -k 3 |
    while read pub_ip priv_fqdn node_name; do
        if [ "$pub_ip" = "None" ]; then
            pub_ip=${priv_fqdn%%.*}
            pub_ip=${pub_ip//ip-/}
            pub_ip=${pub_ip//-/.}
        fi
        printf "%-14s %-16s %s %s\n" ${pub_ip} ${priv_fqdn%%.*} ${priv_fqdn} ${node_name}
    done
    
    echo
}

# You may pipe the output of this script to your /etc/hosts file as follows:
#
# broker-host-entries-for-external-clients.sh <broker_cloud_formation_stack_name> | sudo tee -a /etc/hosts
#
get_and_print_broker_etc_host_entries ${1}