#!/bin/bash

############################
# Script: setGithubLabels.sh
# Use Github API to set new Github labels

if [[ "${DRY_RUN}" == 'true' ]]; then
  echo "Dry running:
  curl -u ${GITHUB_USER}:${GITHUB_USER_TOKEN} \
      --request PATCH https://api.github.com/repos/dotCMS/core/labels/Next%20Release \
      -d '{
        \"new_name\": \"Release : '$RELEASE_VERSION'\",
        \"color\": \"fbca04\"
      }'

    curl -u ${GITHUB_USER}:${GITHUB_USER_TOKEN} \
      --request PATCH https://api.github.com/repos/dotCMS/core/labels/Future%20Release \
      -d '{
        \"new_name\": \"Next Release\",
        \"color\": \"ecf754\"
      }'

    curl -u ${GITHUB_USER}:${GITHUB_USER_TOKEN} \
      --request POST https://api.github.com/repos/dotCMS/core/labels \
      -d '{
        \"name\": \"Future Release\",
        \"color\": \"ff7b60\"
      }'
  "
else
  # Rename `Next Release` to `Release : X.Y.Z`
  curl -u ${GITHUB_USER}:${GITHUB_USER_TOKEN} \
    --request PATCH https://api.github.com/repos/dotCMS/core/labels/Next%20Release \
    -d '{
      "new_name": "Release : '$RELEASE_VERSION'",
      "color": "fbca04"
    }'

  # Rename `Future Release` to `Next Release`
  curl -u ${GITHUB_USER}:${GITHUB_USER_TOKEN} \
    --request PATCH https://api.github.com/repos/dotCMS/core/labels/Future%20Release \
    -d '{
      "new_name": "Next Release",
      "color": "ecf754"
    }'

  # Re-create `Future Release`
  curl -u ${GITHUB_USER}:${GITHUB_USER_TOKEN} \
    --request POST https://api.github.com/repos/dotCMS/core/labels \
    -d '{
      "name": "Future Release",
      "color": "ff7b60"
    }'
fi
