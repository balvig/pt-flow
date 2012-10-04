# pt-flow

TODO: Write a gem description.

## Installation

Install the gem:

    $ gem install pt-flow

## Usage

### Committer

```
$ flow checkout
$ git commit -a -m '[completed] cropping story'
$ flow request
$ cap staging deploy:migrations BRANCH=325325
```

### Reviewer
```
$ git fetch
$ git checkout 325325 
# run tests, review code etc...
$ flow merge
$ cap production deploy
```