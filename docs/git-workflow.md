# Git Workflow

The branch and pull request process our team followed.

## Starting work
```
git remote -v                    # confirm the repo is linked to GitHub
git checkout -b my_branch        # create your own branch
git branch                       # confirm which branch you are on
git config --global user.name    # confirm your name
git config --global user.email   # confirm your email
```

## Saving and sharing changes
```
git status
git add .                        # or: git add filename
git commit -m "Describe the change"
git push -u origin my_branch
```
Then open a pull request on GitHub for that branch with a detailed description, and share the link with the reviewer.

## Staying current
```
git fetch --all
git branch --all
git fetch origin main
git pull origin main
```

## Merge conflicts
Conflicts happen when two people edit the same lines of the same file. Resolve them locally in VS Code before opening the pull request:
```
git merge main
```

## Cleaning up
```
git branch -d my_branch                  # delete locally
git push origin --delete my_branch       # delete on the remote
```
