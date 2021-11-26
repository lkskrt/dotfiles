function git_bulk_master_merge -d 'Merge develop into master for all repositories in the CWD with a commit matching a filter' -a commitFilter gitlabBaseGroups unprotect
    if test -z "$commitFilter"
        echo 'No commit filter given'
        exit 1
    end

    if test "$unprotect" = "unprotect"; and not gitlab_read_config
        return 1
    end

    set sourceBranch develop
    set targetBranch master

    for dir in */
        echo
        echo "Checking $dir"
        cd $dir

        if not test -d .git
            echo ' => not a Git repository'
            cd ..
            continue
        end
        if not test (git branch --show-current) = develop
            echo " => not on $sourceBranch branch"
            cd ..
            continue
        end

        git pull


        set -l logTest (git log --grep $commitFilter -1 --pretty=format:"%H")
        if test -z "$logTest"
            echo ' => log does not match commit filter'
            cd ..
            continue
        end

        git diff "origin/$targetBranch"

        echo " => Confirm merging $sourceBranch into $targetBranch for $dir"
        echo "    Latest commit is: $logTest"
        if read_confirm
            if test "$unprotect" = "unprotect"
                set projectId (echo "$gitlabBaseGroups/"(basename (pwd)) | string escape --style=url | string replace -a '/' '%2F')

                set response (curl --fail-with-body -s --header "PRIVATE-TOKEN: $gitlabToken" "$gitlabBaseUrl/api/v4/groups/$gitlabGroupId")
                set unProtectBranchUrl "$gitlabBaseUrl/api/v4/projects/$projectId/protected_branches/$targetBranch"
                echo "DELETE: $unProtectBranchUrl"
                set response (curl --fail-with-body -s --header "PRIVATE-TOKEN: $gitlabToken" --request DELETE $unProtectBranchUrl)
                if test $status -gt 0
                    echo 'Could not adjust push access level:'
                    echo $response
                    exit 1
                end

                set protectBranchUrl "$gitlabBaseUrl/api/v4/projects/$projectId/protected_branches?name=$targetBranch&push_access_level=40&merge_access_level=30"
                echo "POST: $protectBranchUrl"
                set response (curl --fail-with-body -s --header "PRIVATE-TOKEN: $gitlabToken" --request POST $protectBranchUrl)
                if test $status -gt 0
                    echo 'Could not adjust push access level:'
                    echo $response
                    exit 1
                end
            end

            git status
            and git checkout $targetBranch
            and git pull
            and git merge --no-edit $sourceBranch
            and git push
        else
            echo " => Merge canceled"
        end

        cd ..
    end
end
