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

## FAQs

### Q: Why should you use this instead git, subversion, etc.?
A: You probably should not. It does not have remote repos, branches
or any advanced features. However, if you would like to learn, this might be a good
codebase to have a look through. If you have any questions, just shoot me a line.

### Q: Why did you do this?
A: The simple answer is to learn. Specifically, I wanted to get my really good and
wet with test-driven development. I created a full sweet of tests along with (and before)
I wrote code. I also wanted to make a genuinely useful application. Even though
it's not feature-rich compared to other source code revision systems, it's still
got enough features that someone might find it useful.

### Q: What about dependencies?
A: Nothing really. It's dependency free, other than Ruby. It's coded in Ruby 2.1.1, but
it will likely work in earlier versions.


## Changelog

### 0.1.1 - 5/22/2014
Added MD5 hashing support to guard against commit corruption.

### 0.1.0 - 5/15/2014
Initial release.
