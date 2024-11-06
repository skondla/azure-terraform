#!/bin/sh

#for file in `ls -l | awk '{print $9}'|sed '/^$/d'` ; do echo "File: ${file}"; git-crypt export-key $file; done
for file in `find data/secrets -name "*.*"|sed '/^$/d'` ; do echo "File: ${file}"; git-crypt export-key $file; done
