#! /usr/bin/env bash

source json

owner='{
    name: Edwin.Junhao.Lee,
    email: edwin.jh.lee@gmail.com,
    email1: 909xxxxxx@qq.com
}'
developer="{
    Owner: $owner,
    Contributors: [
        Tang Zhiwen,
        Li Tinghui
    ]
}"

function printContributors(){
    echo "------------------"
    echo "Contributors:"
    local IFS=$'\n'
    for employee in $(json_values developer.Contributors ); do
        echo "--- $employee"
    done
    echo "------------------"
}

echo Base assignments

json_put developer.Candidates '[ "YLJ", "Wang Li", "ZLX" ]'

json_values developer.Candidates

newContributor="Zhang Chi"
echo "Pushed a new , $newContributor onto the array"
json_push developer.Contributors "$newContributor"

json_color developer
printContributors

person0=$(json_query developer.Contributors.[0])
echo -e "First Contributor:\t $person0"

json_color developer

json_shift developer.Contributors
printContributors

json_pop developer.Contributors
printContributors
