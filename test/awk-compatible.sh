#! /usr/bin/env bash

function work(){

    # busybox
    docker run -it -w /awk -v "$(pwd)":/awk busybox time awk -f json_walk test-data/b.json

    # mawk
    docker run -it -w /awk -v "$(pwd)":/awk debian time awk -f json_walk test-data/b.json
    
    # gawk
    docker run -it -w /awk -v "$(pwd)":/awk centos time awk -f json_walk test-data/b.json

    # Mac BSD awk # Run in mac native environment
    
}

