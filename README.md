# pt-flow [![Build Status](https://travis-ci.org/balvig/pt-flow.svg?branch=master)](https://travis-ci.org/balvig/pt-flow)

Our workflow, gemified.

## Installation

Install the gem:

    $ gem install pt-flow

Set up webhook for Pivotal Tracker:

    https://github.com/#{repo}/admin/hooks

### Basic Usage

```bash
$ git start
# shows lists of tasks (excluding icebox) - choosing one starts/assigns the task on pt and
# automatically creates and checks out a new branch.

$ git start --include-icebox
# same as git start, including contents of icebox

$ git finish
# pushes branch, finishes task on pt, and creates a pull request
# reviewer comments :+1: to approve on github
# committer presses merge button on github which delivers task on pivotal tracker

$ git cleanup
# cleans up local/remote story branches already merged with current release branch
```

### Other commands

```bash
# creating new stories
$ git create # prompts for name
$ git create 'as an admin I can delete users'

# creating and starting a new story
$ git start 'as an admin I can delete users'
