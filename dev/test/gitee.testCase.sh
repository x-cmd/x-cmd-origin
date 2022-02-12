# shellcheck shell=sh
# shellcheck disable=SC2039,3043
source ./v0
xrc  param/latest json/latest str/latest http/latest assert/latest

test_gitee() {
    echo "gitee开始测试"
    test_get_token() {
        # TODO:换成真实token
        gt_token "$(gitee)"
        assert "$(gt_token)" = "$(gitee)"
    }
    test_gt_current() {
        assert "$(gt_current owner)" = "mycw"
        assert "$(gt_current type)" = "user"
    }
    test_get_token
    test_gt_current
    echo "gitee测试结束"
}
# user_key
test_user_key_id(){
    local user_key="$(gt_user_key ls)"
    if [ $? -eq 1 ]; then
        echo "ERROR:user_key ls"
        return 1
    fi
    local i=0
    local user_key_id
    for (( i=0;i<$(json_length user_key);i++)) 
    do
        if [ "$(json_query user_key.[$i].title)" == "\"x_bash_test"\" ]; then
            user_key_id="$(json_query user_key.[$i].id)"
            echo $user_key_id
            return 0
        fi
    done
}
test_user_key(){
    local id="$(test_user_key_id)"
    local get_key="$(gt_user_key get --id $id)"
    assert "$(json_query get_key.key)" = "\"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAxf6zWYFTpqAbMCrcbJZf5owaJUkiFWWulC8oRR+TOuQbnXJJW9OtItmk19kB3rKZKZerUSYNs82sud2vCBnY8yATBG4NkBOw0zkROl6FvehOuB9jeUJTMDJ4e1N203ar/mK2aSmku9QyPDdCy/yjzcqooPTnEHI6z40s0TdxoEkTxuPE4WkVLf2wBJsTvBCKGLroS1biX3kyQkMz6nhbLogv8EENfmJl1ibUpl1HL4fG2fMQbxrmfOdChSFw+qQEzKeQHwESEfgBBpdUt8fGHEqH0ijVU1aPuZlruvQhbHz+6ggK8Ri36HZ3IAWjHSkLnKf/VxeNF4W1Lbsm4sY5 tzw@tzw-G3-3579"\"
}
gt user key del --id "$(test_user_key_id)"
gt user key add --key "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAxf6zWYFTpqAbMCrcbJZf5owaJUkiFWWulC8oRR+TOuQbnXJJW9OtItmk19kB3rKZKZerUSYNs82sud2vCBnY8yATBG4NkBOw0zkROl6FvehOuB9jeUJTMDJ4e1N203ar/mK2aSmku9QyPDdCy/yjzcqooPTnEHI6z40s0TdxoEkTxuPE4WkVLf2wBJsTvBCKGLroS1biX3kyQkMz6nhbLogv8EENfmJl1ibUpl1HL4fG2fMQbxrmfOdChSFw+qQEzKeQHwESEfgBBpdUt8fGHEqH0ijVU1aPuZlruvQhbHz+6ggK8Ri36HZ3IAWjHSkLnKf/VxeNF4W1Lbsm4sY5 tzw@tzw-G3-3579" --title "x_bash_test" 1> /dev/null 2>&1
[ $? -ne 0 ] && gt_log error "gt member ls ERROR"

## repo member
gt member ls typeshell/dev 1> /dev/null 2>&1 1> /dev/null 2>&1
[ $? -ne 0 ] && gt_log error "gt member ls ERROR"
gt member del -r typeshell/dev zhengqbbb 
gt member add -r typeshell/dev -p push zhengqbbb niracler  1> /dev/null 2>&1
niracler 1> /dev/null 2>&1
[ $? -ne 0 ] && gt_log error "gt member del ERROR"[ $? -ne 0 ] && gt_log error "gt member add ERROR"


## enterprise
gt_enterprise_test(){
    gt enterprise info  --admin 1> /dev/null 2>&1
    [ $? -ne 0 ] && gt_log error "gt enterprise info ERROR"
    gt enterprise info  mycw_yx 1> /dev/null 2>&1
    [ $? -ne 0 ] && gt_log error "gt enterprise info ERROR"
    gt enterprise repo ls  mycw_yx 1> /dev/null 2>&1
    [ $? -ne 0 ] && gt_log error "gt enterprise repo  ERROR"
    gt enterprise member ls --enterprise lteam18 1> /dev/null 2>&1
    [ $? -ne 0 ] && gt_log error "enterprise member ls  ERROR"
    gt enterprise member user mycw_yx zhengqbbb 1> /dev/null 2>&1
    [ $? -ne 0 ] && gt_log error "enterprise member user ERROR"
    gt enterprise member del --enterprise mycw_yx zhengqbbb 1> /dev/null 2>&1
    [ $? -ne 0 ] && gt_log error "enterprise member del ERROR"
    gt enterprise member add -e mycw_yx --role member  zhengqbbb 1> /dev/null 2>&1
    [ $? -ne 0 ] && gt_log error "enterprise member add ERROR"
    gt enterprise member access  -e mycw_yx --username zhengqbbb --role admin --name 秋彬 1> /dev/null 2>&1
    [ $? -ne 0 ] && gt_log error "enterprise member access ERROR"
    gt_log info "enterprise 测试完成"
    return 0
}

gt_org_test(){
    gt org info 1> /dev/null 2>&1
    [ $? -ne 0 ] && gt_log error "org info ERROR"
    gt org info strong_task 1> /dev/null 2>&1
    [ $? -ne 0 ] && gt_log error "org info ERROR"
    gt org create x-bash-test 1> /dev/null 2>&1
    [ $? -ne 0 ] && gt_log error "org create ERROR" 
    gt org repo ls bash-gitee 1> /dev/null 2>&1
    [ $? -ne 0 ] && gt_log error "org repo ls ERROR" 
    gt org member ls bash-gitee 1> /dev/null 2>&1
    [ $? -ne 0 ] && gt_log error "org member ls ERROR" 
    gt org member user --username mycw bash-gitee 1> /dev/null 2>&1
    [ $? -ne 0 ] && gt_log error "org repo ls ERROR" 
    gt org member del --org bash-gitee zhengqbbb 1> /dev/null 2>&1
    [ $? -ne 0 ] && gt_log error "org member user ERROR" 
    gt org member add --org bash-gitee zhengqbbb 1> /dev/null 2>&1
    [ $? -ne 0 ] && gt_log error "org member add ERROR" 
    gt_log info "org 测试完成"
    return 0
}

gt_issue_test(){
    gt issue create --owner mycw_yx --repo x-bash --title "test" \
        --assignee "mycw" --collaborators "zhengqbbb,niracler"
    gt issue update --owner mycw_yx --number I436Q2 --collaborators mycw \
        --state open --body "gfhdfsdfgfhdbubwadbihx"  --assignee "mycw" \
        --collaborators "zhengqbbb,niracler"

    gt repo issue --repo mycw_yx/x-bash
    gt repo issue --repo mycw_yx/x-bash  --number I48EVG
}

gt_repo_test(){
    gt repo create  bash-test
    gt org repo create --org bash_gitee bash-test
    gt enterprise repo create --enterprise mycw_yx bash_gitee
    gt repo ls
    gt repo info mycw_yx/x-bash
    gt repo clear mycw_yx/bash_gitee
    gt repo review  --assignees zhengqbbb --testers zhengqbbb mycw_yx/x-bash
}

gt_member_test(){
    gt member ls mycw_yx/x-bash
    gt member add -r mycw_yx/x-bash -p push zhengqbbb
    gt member del -r mycw_yx/x-bash zhengqbbb
}

gt_pr_test(){
    gt pr ls --repo mycw_yx/x-bash
    gt pr info mycw_yx/x-bash/1
    gt pr log mycw_yx/x-bash/1
    gt pr commit mycw_yx/x-bash/2
    gt pr view mycw_yx/x-bash/2 
    gt pr create --repo mycw_yx/x-bash --title "test1" --head pr --base master --body "..."
    gt pr update --repo mycw_yx/x-bash/4 --title "....."
    gt pr assign add --pr mycw_yx/x-bash/4 --assignees mycw
    gt pr assign del --pr mycw_yx/x-bash/4 --assignees mycw
    gt pr assign review --pr mycw_yx/x-bash/4
    gt pr assign reset  --pr mycw_yx/x-bash/4 --reset_all

}

gt_tag_test(){
    gt tag_releases --owner mycw_yx --repo x-bash --tag v1.0.0
}
# gt_repo_issue --owner mycw_yx --repo x-bash
# gt_issue_info --owner mycw_yx --repo x-bash --number I436Q2
# gt_issue_comments --owner mycw_yx --repo x-bash --number I436Q2
# gt_issue_logs --owner mycw_yx --number I436Q2
# gt_issue_comments_create --owner mycw_yx --repo x-bash --number I436Q2 --body "test 评论"
# gt_issue_comments_update --owner mycw_yx --repo x-bash --id 6079740 --body "test 评论1"
# gt_issue_comments_del --owner mycw_yx --repo x-bash --id 6079740

# gt_repo_release_create  --owner mycw_yx --repo x-bash --name test-release --body ... --tag_name v1.0.0
# gt_repo_release_update  --owner mycw_yx --repo x-bash --tag_name v1.0.0 --name test-update1 --body ... --id 151755
# gt_repo_release_latest --owner mycw_yx --repo x-bash
# gt_repo_release_delete --owner mycw_yx --repo x-bash  --id 151755
