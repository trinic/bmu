```
# bmu
bmu or Back Me Up is a script for backing up files based on filename extension. There are
two versions - the more universal bmu.sh (a Bash shell script for Linux) and an Ansible
version (abmu.yml). If you don't know what Ansible is, just ignore that file or delete it.
If you DO know what Ansible is, I'll assume you know enough about the shell to modify the
crontab entry below appropriately. ;)

Installation:
Place both bmu.sh and bmu.conf in the same folder. The log file will be created in the same
location automatically. I put them in the top of my user folder, or ~/.

If you want to run this script nightly, you can create a cron entry like this:

1. Open Terminal and type 
crontab -e

If this is your first time editing crontab, you may be prompted to choose an editor. Nano is 
pretty user-friendly, so I use that.

2. Make an entry at the bottom of the file like this one:

00 3      * * *     bash ~/bmu.sh   # copy and paste this line only!

^  ^      ^ ^ ^     ^
m  h   dom/mon/dow  command

Key:
m = the minute, set to 00/on the hour
h = the hour (in military time), set to 0300 / 3am
dom = day of month; * means every day
mon = calendar month; * means every month
dow = day of week; * means every day
command = 'bash ~/bmu.sh' means start a new bash shell and run the commands stored in bmu.sh,
          which is located in the current user's home directory (~/).
```
