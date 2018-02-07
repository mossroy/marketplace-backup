# marketplace-backup
Script to make a backup of https://marketplace.firefox.com/

This quick-and-dirty shell script downloads all the publicly-available apps from the Firefox Marketplace.

As the Marketplace will be shut down by Mozilla at the end of March 2018, it's a way to have a local copy of its content.

The result is a list of directories (one for each app), containing the zip package (installable manually through WebIDE), with the screenshots, icon, and JSON data.

I asked Mozilla if I could host these apps : they did not agree, as their developer agreement only allows Mozilla to distribute the apps. They also refused to host this by themselves, or to let me do it on one of their servers.

To run this script, you need wget, curl and jq.

CAUTION : it looks like the Marketplace API I use does not always give the same result. So I'm not 100% sure I get all the apps in one run of the script.
But the script can be ran several times, and will incrementally add new apps if needed.
I ran it a few times in order to (hopefully) download everything.
