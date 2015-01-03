# iPhotoUnison.sh

# iTunesRsync.sh
This script was written to push the iTunes library on my MacMini named MiniMusic to my ReadyNAS for backup purposes.  

It is run every day by a plist file that was loaded into Launchd.  This file was loaded using a program call **Lingon**.  If you don't have access to that program, here's manual instructions for loading/unloading launchd tasks.

#### Installing launchd tasks
**First**, create a plist XML document.  You can find information on these

* [here][1]
* [here][2]
* and, [here][3]

this document should be named something like `com.mycompanyname.mydepartment.mytaskname.plist`

**Second**, copy the plist files into your LaunchDaemons folder (or LaunchAgents, if you want it to only run when you’re logged in):

`cp com.mycompanyname.mydepartment.mytaskname.plist /Library/LaunchDaemons`

**Third**, so that launchd will pick it up without needing a reboot, we do the following:

`launchctl load -w /Library/LaunchDaemons/com.mycompanyname.mydepartment.mytaskname.plist`

To check it’s all installed, do `launchctl list` and check that your task is in the list.

#### Disabling launchd tasks
When the time comes that you need to disable the task, do the following:

`launchctl unload -w /Library/LaunchDaemons/com.mycompanyname.mydepartment.mytaskname.plist`
`rm /Library/LaunchDaemons/com.mycompanyname.mydepartment.mytaskname.plist`




[1]: http://www.splinter.com.au/using-launchd-to-run-a-script-every-5-mins-on/
[2]: http://alvinalexander.com/mac-os-x/launchd-examples-launchd-plist-file-examples-mac
[3]: https://developer.apple.com/library/mac/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/ScheduledJobs.html