import sys
import re


# Python script to replace a given text by a provided one
#
# $1: file: file to do replacing
# $2: replace_text: text to replace
# $3: replacing_text: new text

file = sys.argv[1]
replace_text = sys.argv[2]
replacing_text = sys.argv[3]

with open(file, 'r') as fr:
  content = fr.read()
  content_new = re.sub(replace_text, replacing_text, content, flags = re.M)
  fr.close()

with open(file, 'w') as fw:
  fw.write(content_new)
  fw.close()
