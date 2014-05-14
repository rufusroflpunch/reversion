# Reversion
## About

I wanted to design a simple source code revision system as a learning excercise.
Reversion is the product of that experience. It's written in Ruby and has
many of the trappings you've come to expect from source control systems.

## Usage

Using it is as simple as initalizing the repository in your projects folder by typing
`rvn init`. You can add files with `rvn add <filenames>`. Commit with `rvn commit [message]`.
Here is the full list of available commands:

```
Usage: rvn <command> [args]
  
  Commands:
    init:       Create a new repository.
    add:        Adds a file to the repo.
    checkout:   Switch to a previous commit.
    all:        List all currently tracked files.
    modified:   List tracked files that have been modified
                since their last commit.
    rm:         Remove files from being tracked.
    log:        Display the commit log for this repo.
    commit:     Commit the current changes to the repo.
                [args] is the commit message (in quotes).
    help:       Display this message.
```

## Installation

Just clone the repo and add it to your path. Presto change-o!

## Misc

### Q: Why should you use this instead git, subversion, etc.?
A: You probably should not. It does not have remote repos, branches
or any advanced features. However, if you would like to learn, this might be a good
codebase to have a look through. If you have any questions, just shoot me a line.
