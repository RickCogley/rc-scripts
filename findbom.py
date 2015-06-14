"""
A quick utility script I threw together to find some files that had been
committed as `UTF-8 With BOM`. I also had the script open the files in BBEdit
so I could quickly change the files to plain UTF-8 (no byte-order mark).
There may be a way to do this safely within Python, but... meh.
"""
# from __future__ import print_function
 
import codecs
import os
from os.path import join
from subprocess import call
 
basedir = os.getcwd()
bbedit = '/usr/local/bin/bbedit'
 
for root, dirs, files in os.walk(basedir):
    for name in files:
        fullpath = join(basedir, root, name)
        with open(fullpath, 'rb') as f:
            if f.read(3) == codecs.BOM_UTF8:
                print(fullpath)
                call([bbedit, fullpath])

