function gitlab_read_config
    set -l GITLAB_CONFIG_FILE_NAME .gitlab-config

    if test -f $GITLAB_CONFIG_FILE_NAME
        while read -l line
            set -l kv (string split -m 1 = -- $line)
            if test (count $kv) != 2
                continue
            end
            set -g $kv
        end <$GITLAB_CONFIG_FILE_NAME
    end

    if test -z "$gitlabGroupId"; or test -z "$gitlabBaseUrl"
        echo "Missing gitlabGroupId or gitlabBaseUrl, create a $GITLAB_CONFIG_FILE_NAME file:"
        echo "echo 'gitlabBaseUrl=https://...' >> $GITLAB_CONFIG_FILE_NAME"
        echo "echo 'gitlabGroupId=...' >> $GITLAB_CONFIG_FILE_NAME"
        return 1
    end

    set -g gitlabToken (secret-tool lookup gitlab $gitlabBaseUrl)
    if test -z "$gitlabToken";
        echo "Missing gitlabToken, create it by executing \"secret-tool store --label='GitLab Token' gitlab $gitlabBaseUrl\""
        return 1
    end
end
