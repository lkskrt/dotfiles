function gitlab_group_clone_pull -d 'Clone or pull all repositories of a GitLab group in the CWD' -a inputGroupId inputBaseUrl
    if test -n "$inputGroupId"; and test -n "$inputBaseUrl"
        set gitlabGroupId $inputGroupId
        set gitlabBaseUrl $inputBaseUrl
    else if not gitlab_read_config
        return 1
    end

    echo "Using group id $gitlabGroupId with the GitLab instance at $gitlabBaseUrl"

    set response (curl --fail-with-body -s --header "PRIVATE-TOKEN: $gitlabToken" "$gitlabBaseUrl/api/v4/groups/$gitlabGroupId")
    if test $status -gt 0
        echo 'Could not get projects:'
        echo $response
        return 1
    end
    set repos (echo $response | jq -c '.projects[]')

    for repo in $repos
        #echo $repo | jq
        set sshUrl (echo $repo | jq -r '.ssh_url_to_repo')
        set name (echo $repo | jq -r '.path')

        if test -d "$name"
            echo "$name exists, pulling"
            cd $name
            git pull
            cd ..
            continue
        end

        echo "$name does not exists yet, cloning $sshUrl"
        git clone $sshUrl
    end
end
