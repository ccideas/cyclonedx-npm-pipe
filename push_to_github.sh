#!/usr/bin/env bash

# Check if no arguments are provided
if [ -z "$1" ]; then
    echo "Error: Add the name of the branch to push to Github."
    echo "Usage: $0 BRANCH_TO_PUSH_TO_GITHUB"
    exit 1
fi

BRANCH_TO_PUSH_TO_GITHUB=$1

echo -e "\nPushing code to github. Verify you merged github into the local branch" \
"via the following commands \
\n # git remote add github \"git@github.com:ccideas/cyclonedx-npm-pipe\" \
\n # git fetch github \
\n # git merge github\main (resolve any merge conflicts)
"

echo "Are you sure you want to continue (Y/n)"

read -r answer

if [[ "${answer}" =~ ^[Yy]$ ]]; then
    echo "Continuing..."
    export GIT_SSH_COMMAND="ssh -i ${GITHUB_DEPLOY_KEY_CYCLONEDX_NPM_PIPE}"
    git remote add github "git@github.com:ccideas/cyclonedx-npm-pipe.git" || echo "already added remote"
    git push github "${BRANCH_TO_PUSH_TO_GITHUB}"
else
    echo "Exiting..."
    exit 1
fi

echo -e "Pushing ${BRANCH_TO_PUSH_TO_GITHUB} to github complete." \
"You can push a tag to github to by running:" \
"\n# git push github TAG_NAME"
