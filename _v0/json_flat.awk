# Using it to convert the json
BEGIN{
    JSON_INPUT_MODE = true
}

JSON_INPUT_MODE==true{
    if ($0 != "---") {
        printf("%s", json_to_machine_friendly($0))
    } else {
        JSON_INPUT_MODE = false
    }
}

JSON_INPUT_MODE==false{

}
