awk '

{
    jiparse_multiple("---", $0)
}

jnum==1{
    jiparse_raw(jobj1, arr)
}

jnum==2{
    jiparse_raw(jobj2, arr)
}

jnum==3{
    jiparse_raw(jobj3, arr)
}

'