#!/bin/bash

set -e 

npm uninstall -g newman newman-reporter-htmlextra
npm install -g newman
npm uninstall -g har-validator
npm install -g newman-reporter-htmlextra
npm install -g highlight.js@10 --save-dev
