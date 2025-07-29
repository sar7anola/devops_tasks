#!/bin/bash
adduser a7med
su a7med
sudo su
sudo userdel a7med
mkdir dir1
cd dir1
touch fil1

ls -la
echo "welocome to linux" > fil1
date >> fil1
ls -ltr
cat fil1
chmod 700 fil1
chmod 700 dir1
alias h='history'
h
unalias h
pwd
cp fil1 doc2
mv doc2 copied-version
cd ..
rm -rf anything

vim myscript.sh