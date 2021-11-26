function git_bulk_master_tag -d 'Tag master for all repositories in the CWD with a commit matching a filter' -a commitFilter gitlabBaseGroups
    if test -z "$commitFilter"
        echo 'No commit filter given'
        return 1
    end

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

        git fetch

        set -l logTest (git log --grep $commitFilter -1 --pretty=format:"%H")
        if test -z "$logTest"
            echo ' => log does not match commit filter'
            cd ..
            continue
        end

        set latestTagCommit (git rev-list --tags -1)
        if test -z "$latestTagCommit"
            set_color yellow
            echo " => project does not have any tags yet!"
            set_color normal
            cd ..
            continue
        end
        set latestTag (git describe --tags $latestTagCommit)
        git merge-base --is-ancestor $logTest $latestTagCommit
        set isAncestor $status

        echo " => The latest tag is $latestTag ($latestTagCommit)"
        if test $isAncestor -eq 0
            echo "    It already contains commit $logTest"
            cd ..
            continue
        end

        set splitTag (string split '.' $latestTag)
        set splitTagCount (count $splitTag)
        set splitTag[$splitTagCount] (math $splitTag[$splitTagCount] + 1)
        set newTag (string join '.' $splitTag)

        git diff $latestTag origin/$targetBranch
        echo " => Confirm tagging $targetBranch with $newTag"
        if read_confirm
            git checkout $targetBranch
            and git pull
            and git tag $newTag -m $newTag
            and git push origin $newTag
        else
            echo " => Tagging canceled"
        end

        cd ..
    end
end
