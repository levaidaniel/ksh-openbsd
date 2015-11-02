#!/bin/sh

git log --format="%ai %h %s" > Changelog.ksh-openbsd
