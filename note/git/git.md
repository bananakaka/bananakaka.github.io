

git log



git reset —hard commit_version



git reflog

查看所有提交过的记录



git push -u origin master

加上-u，不但会把本地的master推送到远程库的master，还会把两者关联起来，以后pull或push就可以简化：git push origin master



git remote -v

显示更详细的信息



git branch —set-upstream dev origin/dev

建立本地dev分支和远程dev分支关联



stash

git stash list

git stash pop

git stash apply stash@{0}

git stash drop















