#!/bin/bash

# If there’s no proper path passed in the argument,
# the script will list files in the current directory
if [[ -z "$1" || ! -d "$1" ]]; then
    path="."
else
    path="$1"

    # If the path doesn’t end with slash, append one
    if [ ${path#${path%?}} != '/' ]; then
        pathto="$path/"
    else
        pathto="$path"
    fi
fi

# Looping through the list of all files and directories,
# including hidden files (`ls -A` ignores `.` and `..`)
for file in $(ls -A "$path"); do

    # Prepending filename with its path
    # (`$pathto` isn’t set for the current directory)
    file="$pathto$file"

    # If it’s a file, count its size in bytes using simple `wc`
    if [ -f "$file" ]; then

        # Using `tr` to remove all whitespace `wc` produces
        size=$(wc -c < "$file" | tr -d " ")
        unitset="BKMGT"

    # If it’s a directory, use `du` to determine its total size
    # (calculated in kilobytes, not bytes)
    elif [ -d "$file" ]; then

        # Using `cut` to pull out only the number
        size=$(du -sk "$file" | cut -f 1)
        unitset="KMGT"

    # If it’s something else, just skip it
    else
        continue
    fi

    # It will turn into swan, you’ll see
    unit=0

    # Converting units
    while [[ $size -ge 1024 && $unit -lt ${#unitset} ]]; do
        size=$(($size / 1024))
        unit=$(($unit + 1))
    done

    # Setting the corresponding unit (the swan thing)
    if [ $size -gt 0 ]; then
        unit=${unitset:$unit:1}

    # No unit for 0
    else
        unit=""
    fi

    # Human-readable output
    printf "%8.1f %1s  %s\n" "$size" "$unit" "$file"
done;