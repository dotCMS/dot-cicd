#!/bin/bash

############################
# Script: setGithubLabels.sh
# Use Github API to set new Github labels when it is not in dry-run mode

if [[ "${DRY_RUN}" != 'true' ]]; then
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
else
  echo "The following supposed to run then DRY-RUN is disabled:

    curl -u ${GITHUB_USER}:${GITHUB_USER_TOKEN} \\
      --request PATCH https://api.github.com/repos/dotCMS/core/labels/Next%20Release \\
      -d '{
        \"new_name\": \"Release : '$RELEASE_VERSION'\",
        \"color\": \"fbca04\"
      }'

    curl -u ${GITHUB_USER}:${GITHUB_USER_TOKEN} \\
      --request PATCH https://api.github.com/repos/dotCMS/core/labels/Future%20Release \\
      -d '{
        \"new_name\": \"Next Release\",
        \"color\": \"ecf754\"
      }'

    curl -u ${GITHUB_USER}:${GITHUB_USER_TOKEN} \\
    --request POST https://api.github.com/repos/dotCMS/core/labels \\
      -d '{
        \"name\": \"Future Release\",
        \"color\": \"ff7b60\"
      }'
  "
fi

