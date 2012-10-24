# pt-flow

TODO: Write a gem description.

## Installation

Install the gem:

    $ gem install pt-flow

## Usage

- flow start
- flow finish
- flow review

### Committer

```bash
$ flow start
# shows lists of tasks - choosing one starts/assigns the task on pt and checks out a new branch.

$ git pull --rebase origin master/release_branch/whatever
# Make sure your branch is up-to-date

$ flow finish
# pushes branch, finishes task on pt, and opens github new pull request page.
# follow with cap staging deploy:migrations BRANCH=master-325325 etc...
```

### Reviewer

```bash
$ flow review
# selecting a pull request opens github page, comment :+1: to approve
```

### Committer

```bash
# pressing merge button on github delivers task on pivotal tracker
```