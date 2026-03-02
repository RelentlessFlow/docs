# Git合并多个提交（包括远程仓库的提交）

## Git合并多个提交（包括远程仓库的提交）

### 1.查看提交历史，–oneline -20最近20次提交，每次提交显示一行摘要

```shell
shell

代码解读
复制代码git log --oneline -20
```

### 2.合并提交历史，可合并最近几个历史，也可指定合并某几个历史

```shell
shell

代码解读
复制代码# 合并前5个提交
git rebase -i HEAD~5

# 或者：合并到某个提交
git rebase -i 0b26a0f775
```

### 3.编辑合并规则，根据Commands说明修改合并规则后保存，有冲突解决冲突，没有冲突编辑提交信息

这里主要用s或者f（放弃提交日志）（squash） command就可以

git rebase --abort 撤销

```shell
shell

代码解读
复制代码pick 0b064204 最终修改
s c1ad1218 修改文件2
s e4e4034f 创建文件1
s 6e492400 删除文件3

# Rebase be4a2d33..6e492400 onto 6e492400 (4 commands) 【将be4a2d33..6e492400重新设定为6e492400（4个命令）】

# Commands: 
# p, pick <commit> = use commit【使用commit】
# r, reword <commit> = use commit, but edit the commit message【使用commit，但编辑commit消息】
# e, edit <commit> = use commit, but stop for amending【使用commit，但停止修改】
# s, squash <commit> = use commit, but meld into previous commit【使用commit，但合并到上一个commit中】
# f, fixup <commit> = like "squash", but discard this commit's log message【和squash一样，只是丢弃commit的日志消息】
# x, exec <command> = run command (the rest of the line) using shell【run command（行的其余部分）using shell】
# b, break = stop here (continue rebase later with 'git rebase —continue')【在此处停止（稍后使用“git rebase --continue”继续重新base）】
# d, drop <commit> = remove commit【删除commit】
# l, label <label> = label current HEAD with a name【用名称标记当前头部】
# t, reset <label> = reset HEAD to a label【将头部重置为标签】
# m, merge [-C <commit> | -c <commit>] <label> [# <oneline>] create a merge commit using the original merge commit's message (or the oneline, if no original merge commit was ). Use -c <commit> to reword the commit message.【使用原始合并提交的消息创建合并提交（如果没有原始合并提交，则为oneline）。使用-c<commit>重新编写commit消息。】
# These lines can be re-ordered; they are executed from top to bottom.
# If you remove a line here THAT COMMIT WILL BE LOST.
# However, if you remove everything, the rebase will be aborted.
# Note that empty commits are commented out
#这些行可以重新排序；它们从上到下执行。如果在此处删除一行，则提交操作将丢失。但是，如果删除所有内容，则将中止重新平衡。注意，空提交被注释掉了
```

### 4.如果已经推送到远程仓库，则继续使用强制推送覆盖到远程仓库（*注意覆盖问题*）

```shell
shell

代码解读
复制代码# 强制推送（注意覆盖问题）
git push origin -f
```