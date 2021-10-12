# shellcheck shell=bash

@src std/http std/param

# Introducing context
gt.make(){
    local O_ORIGINAL=${1:?Provide client name by O environment}

    if [ "$O_ORIGINAL" = "GITEE_DEFAULT" ]; then
        echo "Name 'GITEE_DEFAULT' is reserved for internal use."
        return 1
    fi

    local O="_x_cmd_x_bash_gitee_$O_ORIGINAL"

    http.make "$O" 'https://gitee.com/api'
    http.header.content-type.eq.json+utf8

    local DEFAULT_TOKEN_PATH="$HOME/.x-cmd.com/x-bash/gitee/TOKEN/default"
    if [ -f "$DEFAULT_TOKEN_PATH" ]; then
        O=$O_ORIGINAL gitee.token.set $(cat "$DEFAULT_TOKEN_PATH")
    fi
}

if [ -z "$DO_NOT_INIT_GITEE_DEFAULT" ]; then
    gt.make "GITEE_DEFAULT"
fi

gt.new(){
    oo.create_new_function gt "$@"
}

gt.resp.header(){
    O="_x_cmd_x_bash_gitee_${O:-GITEE_DEFAULT}" http.resp.header "$@"
}

gt.get(){ O="_x_cmd_x_bash_gitee_${O:-GITEE_DEFAULT}" http.get "$@";  }
gt.get.multi(){
    # local O="_x_cmd_x_bash_gitee_${O:-GITEE_DEFAULT}"

    # local first=() second="" flag=0
    # for i in "$@"; do
    #     if [ "$i" == "--" ]; then
    #         flag=1
    #         continue
    #     fi

    #     if [ "$flag" -eq 0 ]; then
    #         first+=("$i")
    #     else
    #         second+=("$i")
    #     fi
    # done

    # if [ "${#second[@]}" -eq 0 ]; then
    #     second=("cat")
    # fi 


    local i=1 total_page=100000
    for (( i=1; i <= total_page; i++ )); do
        echo gt.get "$@" page=$i per_page=100 >&2
        gt.get "$@" page=$i per_page=100
        total_page="$(gt.resp.header "total_page")"
        echo "total_page:$total_page" >&2
    done
}

gt.post(){ O="_x_cmd_x_bash_gitee_${O:-GITEE_DEFAULT}" http.post "$@"; }
gt.post.json(){ O="_x_cmd_x_bash_gitee_${O:-GITEE_DEFAULT}" http.post.json "$@"; }

gt.put(){ O="_x_cmd_x_bash_gitee_${O:-GITEE_DEFAULT}" http.put "$@"; }
gt.put.json(){ O="_x_cmd_x_bash_gitee_${O:-GITEE_DEFAULT}" http.put.json "$@"; }

gt.delete(){ O="_x_cmd_x_bash_gitee_${O:-GITEE_DEFAULT}" http.delete "$@"; }

gt.dict.getput(){
    O="_x_cmd_x_bash_gitee_${O:-GITEE_DEFAULT}" http.dict.getput "$@";
}

gt.dict.get(){
    O="_x_cmd_x_bash_gitee_${O:-GITEE_DEFAULT}" http.dict.get "$@";
}

gt.dict.put(){
    O="_x_cmd_x_bash_gitee_${O:-GITEE_DEFAULT}" http.dict.put "$@";
}


# gt.json(){
#     json.generate "$@"
# }

# gt.json+token() {
#     gt.json access_token "$GITEE_TOKEN" "$@"
# }

###########

gt.token.set(){
    local O="${O:-GITEE_DEFAULT}"
    local GITEE_TOKEN=${1:?"Please provide gitee token"}

    gt.dict.put "access_token" "$GITEE_TOKEN"

    O="_x_cmd_x_bash_gitee_$O"
    http.body.add access_token "$GITEE_TOKEN"
    http.qs.add access_token "$GITEE_TOKEN"

    # TODO: get user information, set current owner is user
}

gt.token.get(){
    gt.dict.get "access_token"
}

gt.token.dump(){
    local current_token="${1:-$(gt.token.get)}" # check GITEE_TOKEN ?
    local name=${2:-"default"}
    
    local TOKEN_PATH="$HOME/.x-cmd.com/x-bash/gitee/TOKEN/$name"
    echo "dumping token to $name. Filepath is: $TOKEN_PATH" >&2
    echo "$current_token" >"$TOKEN_PATH"
}

# gt.owner.set(){
#     local O="_x_cmd_x_bash_gitee_${O:-GITEE_DEFAULT}"

#     local owner="$1"

#     # TODO: If type not given, we should query the api to find out its type
#     local type="$2"
#     gt.current-owner "$owner"
#     gt.current-owner_type "$type"
# }

# gt._owner(){
#     repo=${owner:-$(gt.dict.getput "current-repo")}
#     if [[ "$repo" = */* ]]; then
#         owner=${repo%%/*}
#         repo=${repo##*/}
#     fi

#     echo "${owner}"
# }

# gt._repo(){
#     repo=${owner:-$(gt.dict.getput "current-repo")}
#     if [[ "$repo" = */* ]]; then
#         owner=${repo%%/*}
#         repo=${repo##*/}
#     fi 
# }

gt.parse_owner_repo(){
    local O="${O:-GITEE_DEFAULT}"

    if [ -z "$repo" ]; then
        repo="$(gt.current-repo.get)"
    fi

    if [[ "$repo" = */* ]]; then
        owner=${repo%%/*}
        repo=${repo##*/}
    fi

    if [ -z "$owner" ]; then
        owner="$(gt.current-owner.get)"
    fi
}

# TODO: review
gt.parse_env_owner_type(){
    local O=${O:-GITEE_DEFAULT}

    if [ -z "$owner" ]; then
        owner=$(gt.dict.getput "current-owner")
        owner_type="$(gt.dict.getput "current-owner_type")"
        return 0
    fi

    if [ -z "${owner_type}" ]; then
        owner_type="$(gt.owner_type.query "$owner")"
    fi
}

# TODO: review
gt.parse_env_owner_repo_type(){
    local O="${O:-GITEE_DEFAULT}"

    gt.parse_owner_repo
    if [ -z "$owner" ]; then
        owner=$(gt.dict.getput "current-owner")
        owner_type="$(gt.dict.getput "current-owner_type")"
        repo=$(gt.dict.getput "current-repo")
    fi

    if [ -z "${owner_type}" ]; then
        owner_type="$(gt.owner_type.query "$owner")"
    fi
}

# Providing owner/owner_type

# shellcheck disable=SC2120
gt.current-repo.set(){
    local O="${O:-GITEE_DEFAULT}"

    local repo="$1" owner=""

    gt.parse_owner_repo
    O="_x_cmd_x_bash_gitee_${O:-GITEE_DEFAULT}" gt.dict.getput "current-repo" "$1";

    [ -n "$owner" ] && {
        echo "changing owner: $owner" >&2
        gt.current-owner.set
    }
}

gt.current-repo.get(){
    gt.dict.get "current-repo"
    gt.current-owner.get
    gt.current-owner_type.get
}

gt.current-owner.set(){ 
    local O="_x_cmd_x_bash_gitee_${O:-GITEE_DEFAULT}"

    param '
        owner "Provide owner name"
        type=none "Provide type name" = user enterprise organization none
    '

    if [ "$type" == "none" ]; then
        # get type
        type="$(gt.owner_type.query "$owner")"
    fi

    gt.dict.getput "current-owner" "$owner"
    gt.dict.getput "current-owner_type" "$type"
}

gt.current-owner.get(){
    gt.dict.get "current-owner"
}

gt.current-owner_type.get(){
    gt.dict.get "current-owner_type"
}

gt.eq_str_by_name(){
    for i in "$@"; do
        echo "$i=${!i}"
    done
}

# It is very rare
gt.org.create(){
    @env org "organization name"
    gt.post "/v5/users/organization" name="$org" org="$org"
}

# TODO: better solution?
gt.owner_type.query(){
    local owner="${1:?Provide owner name}"
    
    gt.org.info "$owner" 1>/dev/null 2>&1 && echo "org" && return 0
    gt.enterprise.info "$owner" 1>/dev/null 2>&1 && echo "enterprise" && return 0
    gt.user.info "$owner" 1>/dev/null 2>&1 && echo "user" && return 0
}

gt.user.info(){
    gt.get "/v5/user"
}

gt.enterprise.info(){
    gt.get "/v5/enterprises/${1:?Provide enterprise}"
}

gt.org.info(){
    gt.get "/v5/orgs/${1:?Provide organization}"
}

gt.repo.list(){
    param '
        owner="" "Provide owner"
        owner_type="" "Provide type"
    '

    gt.parse_env_owner_type
    "gt.${owner_type}.repo.list" "$@"
    # gt.get.multi "/v5/${owner_type}s/$owner/repos" type=all | jq -r ".[] | .full_name"
}

# https://gitee.com/api/v5/swagger#/getV5EnterprisesEnterpriseRepos
gt.enterprise.repo.list(){
    param '
        owner "Provide enterprise"
        type=all "repo type" = all public internal private
        direct=true "" = true false
    '

    gt.get.multi "/v5/enterprises/$owner/repos" type=all | jq -r ".[] | .full_name"
}

# https://gitee.com/api/v5/swagger#/getV5OrgsOrgRepos
gt.org.repo.list(){
    param '
        owner "Provide enterprise"
        type=all "repo type" = all public private
    '

    gt.get.multi "/v5/orgs/$owner/repos" type=all | jq -r ".[] | .full_name"
}

# https://gitee.com/api/v5/swagger#/getV5UserRepos
gt.user.repo.list(){
    # TODO: afiiliation could be combination
    # TODO: add split,
    param '
        visibility=all "" = public private all
        affiliation=owner "" =~ ^(owner|collaborator|organization_member|enterprise_member|admin)(,(owner|collaborator|organization_member|enterprise_member|admin))+$
        sort=created "" = created updated pushed full_name
        direction="" = asc desc ""
    '

    gt.get.multi "/v5/user/repos" visibility affiliation sort direction\
        | jq -r ".[] | .full_name"
}

gt.repo.url.http(){
    param '
        owner="" "Provide owner"
        repo "provide repo"
    '

    [ $# -ne 0 ] && repo="$1"
    gt.parse_owner_repo
    echo "https://gitee.com/${owner}/${repo}.git"
}

gt.repo.url(){
    gt.repo.url.ssh "$@"
}

gt.repo.url.ssh(){
    # TODO: bug repo could be ""
    param '
        owner="" "Provide owner"
        repo="" "provide repo"
    '

    [ $# -ne 0 ] && repo="$1"
    gt.parse_owner_repo
    echo "git@gitee.com:${owner}/${repo}.git"
}

gt.repo.clone(){
    gt.repo.clone.ssh "$@" && return 0
    gt.repo.clone.https "$@" && return 0
    return $?
}

# shellcheck disable=SC2120
gt.repo.clone.ssh(){
    git clone "$(gt.repo.url.ssh "$@")"
}

# shellcheck disable=SC2120
gt.repo.clone.https(){
    git clone "$(gt.repo.url.http "$@")"
}

# https://gitee.com/api/v5/swagger#/postV5ReposOwnerRepoForks
gt.repo.fork(){
    param '
        owner="" "Repo Owner"
        repo="" "Repo name"
        organization="" "Provide organization"
    '

    gt.parse_owner_repo
    gt.post.json "https://gitee.com/api/v5/repos/${owner}/${repo}/forks" organization
}

#################
# Owner Operators
#################

# <<A
# How to use:
# gt.current-owner lteam18
# gt.repo.create "new" "abc" "cde"
# A
# gt.repo.create(){
#     local repo owner owner_type
#     for repo in "$@"; do
#         gt.parse_env_owner_repo_type
#         "gt.$owner_type.repo.create"
#     done
# }

gt.org.new(){
    local owner="${1:?Provide organization name}"
    local instance_name="${2:-$owner}"
    eval "
        $instance_name.info(){ gt.org.info $owner; }
        $instance_name.repo.create(){ gt.org.repo.create --owner $owner \"\$@\"; }
        $instance_name.repo.list(){ gt.org.repo.list --owner $owner \"\$@\"; }
    "
}

gt.enterprise.new(){
    local owner="${1:?Provide enterprise name}"
    local instance_name="${2:-$owner}"
    eval "
        $instance_name.info(){ gt.enterprise.info $owner; }
        $instance_name.repo.create(){ gt.enterprise.repo.create --owner $owner \"\$@\"; }
        $instance_name.repo.list(){ gt.enterprise.repo.list  --owner $owner \"\$@\"; }
    "
}

# https://gitee.com/api/v5/swagger#/deleteV5ReposOwnerRepo
gt.repo.destroy(){
    local repo owner
    for repo in "$@"; do
        gt.parse_owner_repo
        gt.delete "/v5/repos/${owner}/${repo}"
    done
}

# arguments NAME
gt.repo.create(){
    param '
        has_issues=true     = true false
        has_wiki=true       = true false
        access=private      = public private innerSource
    '

    local private
    case "$access" in
        public)  private=false;;
        private) private=true;;
    esac

    local name
    for name in "$@"; do
        gt.post.json "/v5/user/repos" name has_issues has_wiki private | jq .full_name
    done
}

# ORGANIZATION NAME
# shellcheck disable=SC2154,SC2034

# https://gitee.com/api/v5/swagger#/postV5OrgsOrgRepos
gt.org.repo.create(){
    # TODO: I don't know what does path means for an organization repo
    param '
        owner   "organization name"
        path "provide path"
        description "repo description"
        homepage "repo home page"
        has_issues=true     = true false
        has_wiki=true       = true false
        can_comment=true    = true false
        access=private      = public private innerSource
        auto_init=false     = true false
        gitignore_template
        license_template
    '

    local public
    case "$access" in
        private)  public=0;;
        public) public=1;;
        innerSource) public=2;;
    esac

    local name
    for name in "$@"; do
        gt.post.json "/v5/orgs/$owner/repos" \
            name path description homepage has_issues has_wiki public\
            can_comment auto_init gitignore_template license_template
    done
}

# ENTERPRISE NAME

# https://gitee.com/api/v5/swagger#/postV5EnterprisesEnterpriseRepos
# shellcheck disable=SC2154
gt.enterprise.repo.create(){
    param '
        owner   "enterprise name"
        has_issues=true     = true false
        has_wiki=true       = true false
        access=private      = public private innerSource
        outsourced=false    = true false
    '

    local private
    # shellcheck disable=SC2034
    case "$access" in
        public)  private=0;;
        private) private=1;;
        innerSource) private=2;;
    esac

    local name
    for name in "$@"; do
        gt.post.json "/v5/enterprises/$owner/repos" name has_issues has_wiki private
    done
    return 0
}

#################
# Repo Operators
#################

gt.repo.new(){
    local owner repo="${1:?Provide enterprise name}"
    gt.parse_owner_repo
    local instance_name="${2:-$repo}"

    eval "
        $instance_name.member.list(){ gt.repo.member.list \"\$@\"; }
        $instance_name.member.add(){ gt.repo.member.add \"\$@\"; }
        $instance_name.member.remove(){ gt.repo.member.remove \"\$@\"; }
    "
}

# shellcheck disable=SC2142
alias gt.repo.read.args='
    param '\''
        owner="" "Repo Owner"
        repo="" "Repo name"
    '\''
    repo="${1:-$repo}"
    if ! gt.parse_owner_repo; then
        return 1
    fi
'

# https://gitee.com/api/v5/swagger#/getV5ReposOwnerRepoPages
gt.repo.page.info(){
    gt.repo.read.args
    gt.get "/v5/repos/${owner}/${repo}/pages"
    
}

# https://gitee.com/api/v5/swagger#/postV5ReposOwnerRepoPagesBuilds
gt.repo.page.build(){
    gt.repo.read.args
    gt.post.json "/v5/repos/${owner}/${repo}/pages/builds"
}

# https://gitee.com/api/v5/swagger#/getV5ReposOwnerRepoCollaborators
gt.repo.member.list(){
    :
    # TODO: page?
    # gt.multiget "/v5/repos/$owner/$repo/collaborators" -- ""
    # gt.get "/v5/repos/$owner/$repo/collaborators"
}

# gt.repo.member.add pull:edwinjhlee,work,adf push:work,adf admin:edwinjhlee

# https://gitee.com/api/v5/swagger#/putV5ReposOwnerRepoCollaboratorsUsername
gt.repo.member.add(){
    if [ "$1" == "-h" ]; then
        echo "Example: owner=d-y-innovations repo=demo-repo username=user1 permission=pull gt.repo.member.add"
        echo "Example: repo=d-y-innovations/demo-repo gt.repo.member.add pull:user1,user2 push:user3,user4 admin:user5"
        echo "Example: repo=d-y-innovations/demo-repo gt.repo.member.add pull:user1,user2 push:user3,user2 admin:user5"
    fi

    param '
        owner "repo owner"
        repo="" "Repo name"
        permission=pull "Repo permission" = push push admin
    '

    gt.parse_owner_repo

    local username
    for username in "$@"; do
        gt.put.json "/v5/repos/$owner/$repo/collaborators/$username" permission
    done
}


# repo=lteam/vscode gt.repo.collaborators.remove chanchan hsn
# vscode.collaborators.remove chanchan hsn
<<A
gt.current-repo lteam/vscode
gt.repo.member.remove chanchan hsn

gt.repo.new lteam18/vscode
lteam18/vscode.member.add chanchan hsn
lteam18/vscode.member.remove hsn

gt.repo.new vscode
vscode.member.edit => with one list
vscode.member.add
vscode.member.remove hsn
A

# https://gitee.com/api/v5/swagger#/deleteV5ReposOwnerRepoCollaboratorsUsername
gt.repo.member.remove(){
    param '
        owner="" "Repo Owner"
        repo="" "Repo name"
    '
    gt.parse_owner_repo

    local username
    for username in "$@"; do
        gt.delete "/v5/repos/$owner/$repo/collaborators/$username"
    done
}

gt.repo.info(){
    local repo=${1:?Provide repo name} owner
    gt.parse_owner_repo
    echo "hi $owner $repo"
    gt.get "/v5/repos/${owner}/${repo}"
}

# https://gitee.com/api/v5/swagger#/getV5ReposOwnerRepoReleases
gt.repo.release.list(){
    param '
        owner="" "Repo Owner"
        repo="" "Repo name"
    '
    gt.parse_owner_repo
}

# https://gitee.com/api/v5/swagger#/postV5ReposOwnerRepoReleases
gt.repo.release.create(){
    param '
        owner="" "Repo Owner"
        repo="" "Repo name"
    '
    gt.parse_owner_repo
}

# https://gitee.com/api/v5/swagger#/patchV5ReposOwnerRepoReleasesId
gt.repo.release.update(){
    param '
        owner="" "Repo Owner"
        repo="" "Repo name"
    '
    gt.parse_owner_repo
}

gt.repo.release.get_or_create(){
    param '
        owner="" "Repo Owner"
        repo="" "Repo name"
    '
    gt.parse_owner_repo
}

# https://gitee.com/api/v5/swagger#/deleteV5ReposOwnerRepoReleasesId
gt.repo.release.delete(){
    param '
        owner="" "Repo Owner"
        repo="" "Repo name"
    '
    gt.parse_owner_repo
}

gt.repo.release.attachment(){
    param '
        owner="" "Repo Owner"
        repo="" "Repo name"
    '
    gt.parse_owner_repo
}

gt.repo.release.attachment.list(){
    param '
        owner="" "Repo Owner"
        repo="" "Repo name"
    '
    gt.parse_owner_repo
}

# Provide multiple files
gt.repo.release.attachment.upload(){
    param '
        owner="" "Repo Owner"
        repo="" "Repo name"
    '
    gt.parse_owner_repo
}

# Delete the file in attachment list
gt.repo.release.attachment.remove(){
    param '
        owner="" "Repo Owner"
        repo="" "Repo name"
    '
    gt.parse_owner_repo
}


# https://gitee.com/api/v5/swagger#/postV5ReposOwnerRepoPulls
gt.repo.pr.create(){
    param '
        owner="" "Repo Owner"
        repo="" "Repo name"
        title "pr title"
        head "source branch. Format: [username:]<branch>"
        base "target branch. Format: [username:]<branch>"
        body="" "pull request content"
        milestone_number="" "milestone id"
        labels=""
        assignees="" "reviewer username list. Format: <username>[,<username>]"
        testers="" "tester username list. Format: <username>[,<username>]"
        prune_source_branch=false = true false
    '

}

# https://gitee.com/api/v5/swagger#/postV5ReposOwnerRepoPullsNumberAssignees
gt.repo.pr.assign(){
    param '
        owner="" "Repo Owner"
        repo="" "Repo name"
        number "pull request id"
        labels=""
        assignees="" "reviewer username list. Format: <username>[,<username>]"
    '

    gt.parse_owner_repo
    gt.post.json "/v5/repos/${owner}/${repo}/pulls/${number}/assignees"
}

# https://gitee.com/api/v5/swagger#/postV5ReposOwnerRepoPullsNumberTesters
gt.repo.pr.assign.testers(){
    param '
        owner "Repo Owner"
        repo="" "Repo name"
        number "pull request id"
        labels=""
        testers="" "testers username list. Format: <username>[,<username>]"
    '

    gt.parse_owner_repo
    gt.post.json "/v5/repos/${owner}/${repo}/pulls/${number}/testers" labels testers
}

# https://gitee.com/api/v5/swagger#/getV5ReposOwnerRepoPulls
gt.repo.pr.list(){
    param '
        owner "Repo Owner"
        repo="" "Repo name"
        state=open = open closed merged all
    '

    gt.parse_owner_repo
    gt.get.multi "/v5/repos/${owner}/${repo}/pulls" state
}

# https://gitee.com/api/v5/swagger#/getV5ReposOwnerRepoPullsNumber
gt.repo.pr.open(){
    param '
        owner="" "Repo Owner"
        repo="" "Repo name"
    '
    gt.parse_owner_repo
}

# https://gitee.com/api/v5/swagger#/getV5ReposOwnerRepoPullsNumber
gt.repo.pr.status(){
    state=all gt.repo.pr.list
}

# https://gitee.com/api/v5/swagger#/patchV5ReposOwnerRepoPullsNumberAssignees
gt.repo.pr.review-status.reset(){
    param '
        owner="" "Repo Owner"
        repo="" "Repo name"
    '
    gt.parse_owner_repo
}

# https://gitee.com/api/v5/swagger#/patchV5ReposOwnerRepoPullsNumberTesters
gt.repo.pr.test-status.reset(){
    param '
        owner="" "Repo Owner"
        repo="" "Repo name"
    '
    gt.parse_owner_repo
}

# open navigator, using the viewer
# https://gitee.com/api/v5/swagger#/getV5ReposOwnerRepoPullsNumber
gt.repo.pr.view(){
    param '
        owner="" "Repo Owner"
        repo="" "Repo name"
        id  "pull request id"
    '
    gt.parse_owner_repo
    http.browse "https://gitee.com/${owner}/${repo}/pulls/${id}"
}

gt.repo.pr.checkout.http(){
    param '
        owner="" "Repo Owner"
        repo="" "Repo name"
    '
    gt.parse_owner_repo
}

# git clone to local disk to compare
gt.repo.pr.merge.http(){
    local source_branch="${1:?Provide source branch}"
    local target_branch="${1:?Provide target branch}"

    local repo_name=${repo_url##*/}
    repo_name=${repo_name%.git}

    if ! git branch; then
        git clone "$repo_url"
        cd repo_name || return 1
    fi

    git checkout "$target_branch"
    git pull "$repo_url" "$source_branch"
    echo "Please open the current folder to merge the code" >&2
    # git push origin issue_I1N19D_ljh_using-java-10
}

# https://gitee.com/api/v5/swagger#/getV5ReposOwnerRepoPullsNumberIssues
gt.repo.pr.issue.list(){
    param '
        owner="" "Repo Owner"
        repo="" "Repo name"
    '
    gt.parse_owner_repo
}

# https://gitee.com/api/v5/swagger#/getV5ReposOwnerRepoPullsNumberComments
gt.repo.pr.comment.list(){
    : TODO: assitance
    : list all of the comment in the terminal

    param '
        owner="" "Repo Owner"
        repo="" "Repo name"
    '
    gt.parse_owner_repo
}
