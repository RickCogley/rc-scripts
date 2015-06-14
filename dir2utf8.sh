#!/bin/bash
# converting all files in a dir to utf8 

for f in *
do
    if [ test -f $f ]; then
        echo -e "\nConverting $f"
        CHARSET="$( file -bi "$f"|awk -F "=" '{print $2}')"
        if [ "$CHARSET" != utf-8 ]; then
                iconv -f "$CHARSET" -t utf8 "$f" -o "$f"
        fi
    else
        echo -e "\nSkipping $f - it's a regular file";
    fi
done
