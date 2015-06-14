#!/bin/sh

grep $1 *.CSV | mail -s $1 rick.cogley@me.com


