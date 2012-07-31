#!/bin/bash

file="$1"
pngcrush="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/pngcrush"

# Proceeding only if the required tool is available
if [ ! -e "$pngcrush" ]; then
    echo "This script requires the tool called ‘pngcrush’ from iOS SDK."
    echo "All you need to do is to install Xcode."

# Checking if the file passed as an argument exists
# and its name ends with `.ipa` (or rather checking the opposite of both)
elif [[ ! -f "$file" || "${file##*.}" != "ipa" ]]; then
    echo "Pass the path to an existing iOS application."

# At this point, everything should be fine
else
    # Retrieving app’s name from the path
    app="${file##*/}"
    app="${app%.*}"

    # Setting the destination directory
    destination="$app Images"
    printf "Extracting %s’s images to ‘%s’\n" "$app" "$destination"

    # If such directory already exists, just remove it
    if [ -d "$destination" ]; then
        rm -drf "$destination"
        printf "(aleady existing ‘%s’ has been removed)\n" "$destination"
    fi

    mkdir "$destination"
    echo # newline

    # A file with `.ipa` extension is just a zipped bundle,
    # unzipping it to the temporary directory
    temp="$destination/Temp"
    unzip -q "$file" -d "$temp"

    # Reverting Xcode’s image optimizations
    # and moving every image to the set destination
    for image in "$temp/Payload"/*.app/*.png; do
        [ -f "$image" ] || continue
        "$pngcrush" -d "$destination" -q -revert-iphone-optimizations "$image" > /dev/null 2>&1
    done;

    # Cleaning up
    rm -drf "$temp"

    open "$destination"
    echo "Done."
fi