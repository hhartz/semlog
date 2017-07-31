# semlog
Command-line tool that splits a git shortlog with semantic commit messages to groups of changes

Can be used as a build step to get changes since last tag (remember to check `☑︎ Run script only when installing`)

    git shortlog `git describe --tags --abbrev=0`..HEAD | semlog | open -t -f

This will commit an incremented version in your .plist and add an annotated tag like e.g.

    semlog 0.3.0-5

    Fix:
      - support piping / interactive again
      - reset lower-order numbers when bumping semantic version
      - bail if Info.plist is not found

    Feat:
      - open changelog in default text editor
