# pt-flow

TODO: Write a gem description.

## Installation

Install the gem:

    $ gem install pt-flow

## Usage

### Committer
- flow checkout
- commit, commit
- git commit -m '[fixes] bug for bla bla' or git commit -m '[completed] cropping story'
- git push origin 325325
- flow request
- cap staging deploy:migrations BRANCH=325325

### Reviewer
- git fetch
- git checkout 325325325
- flow merge
- cap production deploy
