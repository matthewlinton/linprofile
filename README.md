# linprofile

Generate a profile for a linux system.
The goal is to be able to compare system profiles in a meaningful way.

## Install

* Checkout: `git clone https://github.com/matthewlinton/linprofile.git`
* Change into the linconfig directory `cd linprofile`
* run `make` to build the binary tools
* run `systemprofile.sh` to generate a profile of your system

By default, the results of _linprofile_ are stored in `${HOME}/systemprofile`

## Features

TODO : describe output

## Misc Goals

linprofile should be able to run on any linux system. This means that it is necessary to forgo using more usefull tools that may not be present on some systems. This also means keeping binaries very basic, and file sizes to a minimum.
