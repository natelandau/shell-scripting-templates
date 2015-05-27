This directory contains executable scripts which are run on a day to day basis. To invoke these scripts from anywhere be sure to [add this directory to your PATH][1]

# convertMedia Script
convertMedia automates a number media commands by invoking the correct settings from [ffmpeg][2] and (optionally) [XLD][3].  This script can save a ton of time searching for the correct formats, encoders, and options withinn ffmpeg.  

For Mac users, if you don't have ffmpeg installed, this script will install it with all necessary options using [Homebrew][4]

Brief overview of features:

* Resizing video
* Converting formats (for example: FLAC to ALAC or WMV to MP4)
* Changing bit rates on audio files
* Performing actions on a single file, an entire directory, or only on files which match a certain format.

### Examples of usage
Search for all *.flac files in a directory and convert them to
Apple Lossless (alac).  Once the conversion is complete, original files
will be deleted.

    `$ convertMedia -i flac -o alac --delete`

Search for all 1080p files in a directory and downsize them to 720p.

    `$ convertMedia --downsize720`

Convert a Windows Media file (file.wmv) to h264 (mp4).

    `$ convertMedia -o mp4 file.wmv`

I did my best to write good help documentation so simply run `convertMedia -h` for usage information.




[1]: http://unix.stackexchange.com/questions/26047/how-to-correctly-add-a-path-to-path  
[2]: https://ffmpeg.org
[3]: http://tmkk.undo.jp/xld/index_e.html
[4]: http://brew.sh