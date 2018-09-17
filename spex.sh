#!/bin/bash

####################################################################
# OPTIONAL DEPENDENCIES

# Install Imagemagick for thumnail creation
# https://www.imagemagick.org/script/index.php
# If you use Homebrew / Brew, you can simply install it with the command:
# "brew install imagemagick"

# Install imgur.sh for automatic image uploading
# https://github.com/tremby/imgur.sh

####################################################################
# OPTIONS

# If you want spectrograms to be stored in a subfolder, 
# set this to "true"; otherwise set to "flase"
subfolder="true"

# Set name of optional subfolder. ex: "Spectrograms" or "Extras"
subfolder_title="Spectrograms"

# Customize spectrogram output filenames:
# 1: Full Song spectrogram
# 2: Full Song spectrogram thumbnail
# 3: Last 10 seconds spectrogram
# 4: Last 10 seconds spectrogram thumbnail
song_full="spectro.full.png"
song_full_thumb="spectro.full.thumb.png"
song_10s="spectro.last10s.png"
song_10s_thumb="spectro.last10s.thumb.png"

# Set graph axis dimensions (Wil be larger due to labels)
# I used the -Y flag instead of the -y flag, which will automatically 
# adjust the value to a value that is "one more than a power of two", 
# so the value might be adjusted lower. This optimizes for speed.
# If you want a more exact value, change the script to use "-y".
x_axis=1024
y_axis=550

# Would you like the script to generate thumbnails for your spectrograms?
# "true" for yes "false" for no. This requires Imagemagick as a dependency. 
# Refer to "CREDITS & DEPENDENCIES" above for more information.
thumbnails="true"

# Would you like to upload spectrograms and thumbnails to Imgur?
# This will automatically upload images and copy BBcode to clipboard.
uploadimgur="true"

####################################################################
# SHELL SETUP

# Make sure command line tools are recognized
export PATH=/usr/local/bin:$PATH
shopt -s expand_aliases
source ~/.bash_profile
source ~/.bashrc

####################################################################
# SET VARIABLES

# Save cuurent directory
currentdir="$PWD"

# Set more variables
for file in "$@"
do
	filedir="$(dirname "$file")"
	outfileraw="${file%.*}.png"
	outfile="$(basename "$outfileraw")"
    img_titleraw="${file}"
    img_title="$(basename "$img_titleraw")"
done

# Store Input in Variable
fileinput=( "$@" )

####################################################################
# FUNCTIONS

# Function to Create spectrograms with no subfolder
spect_nofolder () {
	cd "$filedir"
    for fileA in "$fileinput"
	do
		sox "$fileA" -n spectrogram -t "$img_title" -o "$song_full" -x "$x_axis" -Y "$y_axis"
		sox "$fileA" -n trim -10 spectrogram -t "$img_title" -o "$song_10s" -x "$x_axis" -Y "$y_axis"
	done

	cd "$currentdir"
}

# Function to Create spectrograms with no subfolder
spect_withfolder () {
	cd "$filedir"
	mkdir -p "$subfolder_title"
	cd "./$subfolder_title"
	subdir="$PWD"
    for fileB in "$fileinput"
	do
		sox "$fileB" -n spectrogram -t "$img_title" -o "$song_full" -x "$x_axis" -Y "$y_axis"
		sox "$fileB" -n trim -10 spectrogram -t "$img_title" -o "$song_10s" -x "$x_axis" -Y "$y_axis"
	done

	cd "$currentdir"
}

# Function to Notify user of completion
notify_done () {
   # Display notification
	osascript -e 'display notification "Spectrograms Completed." with title "Spex"'
	# Play notification Sound
	afplay /System/Library/Sounds/Hero.aiff
}

####################################################################
# SPECTROGRAM CREATION

# Subfolder Logic
if [ "$subfolder" = "true" ]
then
	spect_withfolder
else
	spect_nofolder
fi

echo
echo "... Spectrograms Generated"

####################################################################
# THUMBNAIL CREATION

if [ "$subfolder" = "true" ]
then
	cd "$subdir"
	magick convert "$song_full" -resize 25% "$song_full_thumb"
	magick convert "$song_10s" -resize 25% "$song_10s_thumb"
	cd "$currentdir"
else
	cd "$filedir"
	magick convert "$song_full" -resize 25% "$song_full_thumb"
	magick convert "$song_10s" -resize 25% "$song_10s_thumb"
	cd "$currentdir"
fi

echo "... Thumbnails Generated"

####################################################################
# IMGUR UPLOAD

if [ "$subfolder" = "true" ]
then
	cd "$subdir"
	echo "... Uploading Images to Imgur"
	imgur "$song_full" "$song_full_thumb" "$song_10s" "$song_10s_thumb"
else
	cd "$filedir"
	echo "... Uploading Images to Imgur"
	imgur "$song_full" "$song_full_thumb" "$song_10s" "$song_10s_thumb"
fi

cd "$currentdir"
echo "... Images Uploaded to Imgur"
echo "... BBcode Copied to Clipboard"

####################################################################
# UNSET VARIABLES

unset subfolder subfolder_title x_axis y_axis fileinput fileinput filedir outfile outfileraw img_title img_titleraw currentdir

####################################################################
# NOTIFY AND EXIT

notify_done
echo
echo "... Finished."
echo

