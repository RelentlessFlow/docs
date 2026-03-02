# git pull无法在偏离的分支上进行快进操作

因为之前强制把最新的commitg覆盖掉了，就导致了这个问题

 git reset --soft HEAD~1  1就是撤销最近一次的commit

git pull