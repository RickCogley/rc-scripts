#!/bin/bash 
while read i
do
	$i
	sleep 2
done < <(cat whiletest.txt)
