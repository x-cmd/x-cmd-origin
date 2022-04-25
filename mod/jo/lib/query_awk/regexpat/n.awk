INPUT==1{
    if ( jiter_target_rmatch( obj, $0, patarrl ) == false )    next
    for (i=1; i<=argvl; ++i) {
        if (obj[ argv[i] ] != "" ) {
            handle_output( i, jstr1(obj, argv[i]) )
        }
    }
}
