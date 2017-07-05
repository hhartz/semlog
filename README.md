# semlog
Command-line tool that splits a git shortlog with semantic commit messages to groups of changes

Can be used as a build step to get changes since last tag (remember to check `☑︎ Run script only when installing`)

    git shortlog `git describe --tags --abbrev=0`..HEAD | semlog | open -t -f
