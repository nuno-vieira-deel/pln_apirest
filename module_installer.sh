#!/bin/bash

for a in modules/intermediate/*;
do 
	cd $a 
	cpanm -S -v .
	cd ../../..
done

for a in modules/*;
do 
	cd $a
	cpanm -S -v .
	cd ../..
done
