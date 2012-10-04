# pt-flow

TODO: Write a gem description.

## Installation

Install the gem:

    $ gem install pt-flow

## Usage

- flow start
- flow finish
- flow deliver

### Committer

```bash
$ flow start
# shows lists of tasks, choosing one starts/assigns the task and checks out a new branch.

$ flow finish
# pushes branch to origin, finishes task on pt and opens github on pull request page.
# follow with cap staging deploy:migrations BRANCH=325325 etc...
```

### Reviewer

```bash
$ git fetch
$ git checkout 325325
# run tests, review code etc...

$ flow deliver
# merges with master, pushes master to origin, deletes local/remote branch, delivers task on pt
# follow with cap production deploy:migrations etc...
