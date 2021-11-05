#!/bin/bash
# Check GitLab
GITLABCONT=gitlab-test_web_1
echo "Check Gitlab after the container becomes healthy."
read -p "Check Gitlab? [y/n]: " CHECK
CHECK=${CHECK:-n}
if [ "$CHECK" == "y" ]; then
    docker exec -it ${GITLABCONT} gitlab-rake gitlab:check SANITIZE=true
fi