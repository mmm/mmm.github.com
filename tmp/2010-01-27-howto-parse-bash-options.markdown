---
layout:post
title: $i
tags: ["howto"]
---


#!/bin/bash

vsave=0
vrestore=0

function usage()
{
        echo "USAGE:"
        echo "$0 [-s] [-r] [-f installedpackages.txt]"
        echo ""
        echo "-s ... save installed packages"
        echo "-r ... restore installed packages"
        echo ""
        echo "-f file.txt ... file where installed packages are saved"
        echo "                or from which installed packages are taken"
        echo ""
        exit 0;
}

while getopts ":srf:" options
do
   case "$options" in
   s) vsave=1 ;;
   r) vrestore=1 ;;
   f) file="$OPTARG" ;;
   *) usage;;
   esac
done

function doSave()
{
   dpkg --get-selections > $file
}

function doRestore()
{
   dpkg --set-selections < $file
}

if [ "$vsave" == "1" ] && [ "$vrestore" == "1" ] || [ "$file" == "" ]
then
   usage
fi

if [ "$vsave" == "1" ] && [ "$file" != "" ]
then
   doSave
fi

if [ "$vrestore" == "1" ] && [ "$file" != "" ]
then
   doRestore
fi

