

# It should be application code

function json_get_dict_value(obj, keypath,     _arr, i, _key){
    _l = jdict_keys2arr(obj, keypath, _arr)
    for (i=1; i<=_l; ++i) {
        _key = _arr[i]
        # val = jdict_get(keypath S key)
        val = jstr(obj, keypath S _key)
    }
}

# function json_get_list_value(obj, keypath, key,     _arr, i){
#     l = jlist_len(obj, keypath)
#     for (i=1; i<=l; ++i) {
#         # val = jlist_get(keypath S i)
#         val = jstr(obj, keypath S i)
#     }
# }


# Section: return json list's key value
    # type: return format, compact or machine stringify
function json_get_list_value(obj, keypath, key, type, arr,      _k, _i, _len, _ret, _list_key_arr){
    _k = keypath
    keypath = jpath(keypath)

    if (obj[ keypath ] != T_LIST) {
        exit(0)
        return
    }

    _len = obj[ keypath T_LEN ]
    if (_len <= 0) {
        exit(0)
        return
    }

    for (_i=1; _i<=_len; ++_i) {
        if (type == "format") {
            _list_key_arr = json_stringify_format(obj, _k "." _i key, 4)
        } else if (type == "compact") {
            _list_key_arr = json_stringify_compact(obj, _k "." _i key, 4)
        } else {
            _list_key_arr = json_stringify_machine(obj, _k "." _i key, 4)
        }

        if (_list_key_arr != ""){
            arr[ _i ] = _list_key_arr
            _ret = _ret "\n" _list_key_arr
        }
    }
    _ret = substr(_ret, 2)
    # print _ret
    return _ret

}

# EndSection
