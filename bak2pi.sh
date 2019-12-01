#!/usr/bin/env bash

echo "rsynch scripts, pentest & other tools to pi"

## check for a new month
ssh pi@pluto '/backup/backups.sh newMonth'

## now rsynch the files we want to the remote host
## -a :: archive
## -z :: compress
## -W :: whole-file
## -v :: verbose on file(s) being transferred
## -e :: remote shell command(s) to use
rsync -azWv -e "ssh -i ~/.ssh/todd" --stats --delete ~/scripts pi@pluto:/backup/current
rsync -azWv -e "ssh -i ~/.ssh/todd" --stats --delete ~/pentest pi@pluto:/backup/current
rsync -azWv -e "ssh -i ~/.ssh/todd" --stats --delete ~/tools pi@pluto:/backup/current
rsync -azWv -e "ssh -i ~/.ssh/todd" --stats --delete ~/.ssh pi@pluto:/backup/current

## individual key files we want
rsync -azWv -e "ssh -i ~/.ssh/todd" --stats --delete ~/.bashrc pi@pluto:/backup/current/
rsync -azWv -e "ssh -i ~/.ssh/todd" --stats --delete ~/.bash_history pi@pluto:/backup/current/
rsync -azWv -e "ssh -i ~/.ssh/todd" --stats --delete ~/.vimrc pi@pluto:/backup/current/
rsync -azWv -e "ssh -i ~/.ssh/todd" --stats --delete ~/.tmux.conf pi@pluto:/backup/current/
#rsync -azWv -e "ssh -i ~/.ssh/todd" --stats --delete ~/.git* pi@pluto:/backup/current/

# make backup and check
ssh pi@pluto '/backup/backups.sh hardLink'
