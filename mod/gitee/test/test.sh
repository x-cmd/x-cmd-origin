. gitee
gt.new a
# Section 1: Token & Config management
access_token=c32352471710e3306fd215919d15e034
echo "init : "$(a.token) 
a.token $access_token
a.config.save
echo "set and save token : "$(a.token) 
a.token ""
echo "set token : "$(a.token)
a.config.load
echo "load token : "$(a.token) 

a.current_owner bash-gitee
echo "get current owner"
a.current_owner
echo "get current owner type"
a.current_owner_type bash-gitee

# Section 2: Wrapping std/http module with object naming changing
echo "get response header"
a.resp.header "https://gitee.com/api/v5/user?access_token=2e9de6e435d22da444f67b8a5e5e15d5"
echo "get response body"
a.resp.body "https://gitee.com/api/v5/user?access_token=2e9de6e435d22da444f67b8a5e5e15d5"
echo "gt.get"
# a.get
a.get /v5/user?access_token=2e9de6e435d22da444f67b8a5e5e15d5

# Section 3: Parameter Utilities
echo "gt.get.multi"
a.get.multi "/v5/user?access_token=2e9de6e435d22da444f67b8a5e5e15d5"
echo "gitee repo normalize"
a.param.normalize.repo git-recipes

# Section 4: Info & Org Creation

echo "get owner type"
a.owner_type.query mycw
echo "get user、enterprises、organization info"
a.user.info mycw
a.enterprise.info mycw_yx
a.org.info bash-gitee
echo "create organization"
a.org.create bash-test1


# Section 5: List Repos
echo "get user、enterprise、org repo list"
a.repo.list "mycw"
a.enterprise.repo.list "mycw_yx" --type "all"
a.org.repo.list bash-gitee --type "public"
a.user.repo.list --visibility "private" --affiliation "owner" --direction "desc"

# Section 6: Repo Path & Clone

echo "get repo url"
a.repo.url.http "mycw/cloudTemplat" "strong_task/fx"
a.repo.url "mycw/cloudTemplat"
# TODO results agreement
a.repo.url "mycw/cloudTemplat" "strong_task/fx"
echo "clone repo"
a.repo.clone "mycw/x-bash-test"

# Section 7: Repo - Deletion & Info & Creation
echo "get repo info"
a.repo.info "bash-gitee/x-bash-test"

echo "destroy repo"
a.repo.list mycw
a.repo.destroy "mycw/x-bash-test"
a.repo.list mycw
a.repo.create "x-bash-test" --has_issues true  --has_wiki true --access "public"
a.repo.list mycw

echo "org repo create"
a.repo.list bash-gitee
a.org.repo.create x-bash-test --path "x-bash-test" --description "x-bash gitee test"
a.repo.list bash-gitee

echo "enterprise repo create"
a.repo.list "mycw_yx"
a.enterprise.repo.create "x-bash-test-enter" --owner "mycw_yx"
a.repo.list "mycw_yx"

# Section 8: Repo Member
echo "get repo member list"
a.repo.member.list "mycw_yx/x-bash-test-enter"

# Section 10: Release
echo "get repo release"
a.repo.release.list "mycw/x-bash-test"
# repo no files return error code 400
a.repo.release.create --repo "mycw/x-bash-test" --tag_name "v1.0" --name "tzw-test" --body "test" --prerelease false --target_commitish "master"
a.repo.release.update --repo "mycw/x-bash-test" --tag_name "v1.1" --name "tzw-test" --body "test" --prerelease false --target_commitish "master" --id 11
# id is variable
a.repo.release.delete --repo "mycw/x-bash-test" --id 107822
a.repo.release --repo "bash-gitee/x-bash-test" --tag "v1.0"
a.repo.release.get_or_create --repo "bash-gitee/x-bash-test"  --tag_name "v1.5"  --name "tzw-test" --body "test" --prerelease false --target_commitish "master"
a.repo.release.latest_update --repo "bash-gitee/x-bash-test"

############################
# Section 10: Pull Request
############################
a.repo.pr.create --repo "bash-gitee/x-bash-test" --title "test create pr" --head "issue_tzw" --base "master"
a.users --name Niracle
a.repo.pr.list --repo "bash-gitee/x-bash-test"
a.repo.pr.assign --repo "bash-gitee/x-bash-test" --number 1 --assignees "mycw"
a.repo.pr.assign.delete --repo "bash-gitee/x-bash-test" --number 1 --assignees "mycw"
a.repo.pr.testers.delete --repo "bash-gitee/x-bash-test" --number 1 --testers "mycw"
a.repo.pr.testers --repo "bash-gitee/x-bash-test" --number 1 --testers "mycw"
a.repo.pr.status --repo "bash-gitee/x-bash-test"
a.repo.pr.review-status.reset --repo "bash-gitee/x-bash-test" --number 1
a.repo.pr.test-status.reset --repo "bash-gitee/x-bash-test" --number 1
a.repo.pr.issue.list --repo "bash-gitee/x-bash-test" --number 1
a.repo.pr.comment.list --repo "bash-gitee/x-bash-test"

z