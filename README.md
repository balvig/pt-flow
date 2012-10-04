# pt-flow

TODO: Write a gem description.

## Installation

Install the gem:

    $ gem install pt-flow

## Usage

### Committer

```
$ flow start
# work, work, work
$ flow finish
$ cap staging deploy:migrations BRANCH=325325
```

### Reviewer
```
$ git fetch
$ git checkout 325325
# run tests, review code etc...
$ flow deliver
```
