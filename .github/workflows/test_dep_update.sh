#!/usr/bin/env nix-shell
#!nix-shell -i bash -p gh jq
set -e
echo "$GITHUB_API_TOKEN" | gh auth login --with-token
git branch -D depupdate || true
git branch depupdate
git checkout depupdate
git reset --hard origin/master
json="$(gh pr list --search "author:app/github-actions" --json headRefName,number)"
# If there's no updates then the CI action will fail without this, which is more common if we reduce the schedule from 24 hours.
if [[ $json == "[]" ]]; then
    echo "No Dependency update PRs to merge"
    exit
fi

echo "$json" | jq '.[] | .headRefName | @text' | xargs -L1 -- git pull origin
if nix build .#checks.x86_64-linux.init-example-el; then
    prs=$(echo "$json" | jq ".[] | .number")
    for pr in $prs; do
        # Whenever there's a bunch of PRs to merge at the same time
        # the GitHub API needs some time to update its internal
        # state before allowing another PR to be merged.
        sleep 5

        gh pr merge --squash --delete-branch "$pr"
    done
else
    gh issue create \
        --title "Recent Dependency update PRs failing tests" \
        --body "I tried to combine these PRs and they failed the test: $(echo "$json" | jq ".[] | .number | @text" | xargs echo '#')"
fi
