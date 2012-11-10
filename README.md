# pt-flow

Our workflow, gemified.

## Installation

Install the gem:

    $ gem install pt-flow

Set up webhook for Pivotal Tracker:

    https://github.com/#{repo}/admin/hooks

### Usage

```bash
$ flow start
# shows lists of tasks - choosing one starts/assigns the task on pt and checks out a new branch.

$ flow finish
# pushes branch, finishes task on pt, and creates a pull request
# reviewer comments :+1: to approve on github
# committer presses merge button on github which delivers task on pivotal tracker

$ flow cleanup
# cleans up local/remote story branches already merged with current release branch
```
