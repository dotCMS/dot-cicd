import os
import sys
import fileinput

plugins = [
'OSGi/com.dotcms.3rd.party/build.gradle',
'OSGi/com.dotcms.actionlet/build.gradle',
'OSGi/com.dotcms.aop/build.gradle',
'OSGi/com.dotcms.custom.spring/build.gradle',
'OSGi/com.dotcms.dynamic.skeleton/build.gradle',
'OSGi/com.dotcms.fixasset/build.gradle',
'OSGi/com.dotcms.hooks/build.gradle',
'OSGi/com.dotcms.job/build.gradle',
'OSGi/com.dotcms.override/build.gradle',
'OSGi/com.dotcms.portlet/build.gradle',
'OSGi/com.dotcms.pushpublish.listener/build.gradle',
'OSGi/com.dotcms.rest/build.gradle',
'OSGi/com.dotcms.ruleengine.velocityscriptingactionlet/build.gradle',
'OSGi/com.dotcms.ruleengine.visitoripconditionlet/build.gradle',
##'OSGi/com.dotcms.servlet/build.gradle',
'OSGi/com.dotcms.simpleService/build.gradle',
'OSGi/com.dotcms.spring/build.gradle',
'OSGi/com.dotcms.staticpublish.listener/build.gradle',
'OSGi/com.dotcms.tuckey/build.gradle',
'OSGi/com.dotcms.viewtool/build.gradle',
'OSGi/com.dotcms.webinterceptor/build.gradle',
'OSGi/com.dotcms.app.example/build.gradle',
'static/com.dotcms.hook/build.gradle',
'static/com.dotcms.macro/build.gradle',
'static/com.dotcms.portlet/build.gradle',
'static/com.dotcms.servlet/build.gradle',
'static/com.dotcms.skeleton/build.gradle',
'static/com.dotcms.viewtool/build.gradle'
]

textToSearch = sys.argv[1]
textToReplace = sys.argv[2]

for p in plugins:
    fileToSearch = p

    tempFile = open(fileToSearch, 'r+')

    for line in fileinput.input(fileToSearch):
        tempFile.write(line.replace(textToSearch, textToReplace))
    tempFile.close()

print( '\n\n Update process completed... \n\n' )