import sys
import re

new_version = sys.argv[1]
dep_file = './dependencies.gradle'

with open(dep_file, 'r') as fr:
  content = fr.read()
  new_dep = 'compile fileTree(dir: \'src/main/enterprise/build/libs\', include: [\'ee_' + new_version + '.jar\'])'
  content_new = re.sub('compile group: \'com.dotcms.enterprise\', name: \'ee\', version: dotcmsReleaseVersion \+ eeType, changing: true', new_dep, content, flags = re.M)
  fr.close()

with open(dep_file, 'w') as fw:
  fw.write(content_new)
  fw.close()
