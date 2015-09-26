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

$ git start --filter=icebox
# same as git start, showing contents of icebox

$ git start --filter=me
# shows only own tasks

$ git finish
# pushes branch, finishes task on pt, and opens new pull request
# pressing merge button on github delivers task on pivotal tracker

$ git finish --wip
# pushes branch and submits [WIP] pull request

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
