# pt-flow

TODO: Write a gem description.

## Installation

Install the gem:

    $ gem install pt-flow

## Usage

- flow start
- flow finish
- flow review
- flow deliver

### Committer

```bash
$ flow start
# shows lists of tasks - choosing one starts/assigns the task on pt and checks out a new branch.

$ flow finish
# pushes branch, finishes task on pt, and opens github new pull request page.
# follow with cap staging deploy:migrations BRANCH=master-325325 etc...
```

### Reviewer

```bash
$ flow review
# checks out branch and opens github page
# run tests, review code etc...

$ flow deliver
# merges and pushes target branch, deletes local/remote branch, and delivers task on pt
# follow with cap production deploy:migrations etc...
