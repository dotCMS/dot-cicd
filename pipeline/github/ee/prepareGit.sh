#!/bin/bash

mkdir -p ~/.ssh
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
echo "${SSH_RSA_KEY}" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
ls -las ~/.ssh

git config --global user.email "dotcmsbuild@dotcms.com"
git config --global user.name "dotcmsbuild"
git config --global pull.rebase false
