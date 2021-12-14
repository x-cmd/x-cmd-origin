awk '

{
    jiter_multiple("---", $0)
}

jnum==1{
    jiter_raw(jobj1, arr)
}

jnum==2{
    jiter_raw(jobj2, arr)
}

jnum==3{
    jiter_raw(jobj3, arr)
}

'