# pt-flow

Our workflow, gemified.

## Installation

Install the gem:

    $ gem install pt-flow

Set up webhook for Pivotal Tracker:

    https://github.com/#{repo}/admin/hooks

## Usage

- flow start
- flow finish
- flow review

### Committer

```bash
$ flow start
# shows lists of tasks - choosing one starts/assigns the task on pt and checks out a new branch.

$ flow finish
# pushes branch, finishes task on pt, and opens github new pull request page.
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
