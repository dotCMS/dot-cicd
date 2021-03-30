#!/bin/bash

cd dotCMS
eval $(cat gradle.properties | grep dotcmsReleaseVersion)
echo "export dotcms_version=\"${dotcmsReleaseVersion}\""
export dotcms_version="${dotcmsReleaseVersion}"
cd ..
