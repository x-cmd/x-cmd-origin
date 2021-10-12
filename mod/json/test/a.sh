jq . '.[] | { url: .html_url, state: .state }'


json_query "c.*./(html_url)|(id)/"  | json_attrlist id url | json_color 

for i in $(jo c.*); do
    jo url= i.html_url
    jo state= i.state
    json_dict url=$url state=$state
done


for i in $(jo c.*); do
    jo  url=i.html.url \
        state=i.state

    jo <<<'
        a = { 1: 2, 3: 4, c: 5 }
        d = { 
            a: 3
            b: 4
            c: {
                t: 1
            }
        }
        b = [ 1, 2, 3 ]
        url = i.html_url
        state = i.state
    '
done

# jo.start
# jo <<<''
# jo.stop

