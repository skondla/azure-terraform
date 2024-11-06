#!/bin/bash
#Author:skondla@me.com
#Purpose: Find and replace a string recursively in all directories under current directory

find . -type f -name "*.sh" -print0 | xargs -0 sed -i '' -e 's/myDB/newDB/g'
#find -E . -regex '.*\.(py|sh|sql|md)' | xargs -0 sed -i '' -e 's/myDB/newDB/g'
#find -E . -regex '.*\.(py|sh|sql|md)' |xargs egrep -i "(yahoo.com|me.com|gmail.com)"
#find -E . -regex '.*\.(class|git|terraform|pyc|vscode|log|old)' | xargs rm -rf

