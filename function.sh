#!/bin/bash


function dir {
mkdir kaizen
}

function file {
echo "I-was-here" > adilet
}



read -p $'Enter your choice:\n\t1-Create directory\n\t2-Create file\n' choice

if [ $choice -eq 1 ]
then
dir
elif [ $choice -eq 2 ]
then
file
else
echo "Please pick the right choice"
fi


