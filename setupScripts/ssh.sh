#!/usr/bin/env bash

# This script creates public SSH Keys and sends them to Github

if [ -f "../lib/utils.sh" ]; then
  source "../lib/utils.sh"
else
  echo "You must have utils.sh to run.  Exiting."
  exit
fi

header "Running : SSH CONFIG"

success  "Checking for SSH key in ~/.ssh/id_rsa.pub, generating one if it doesn't exist ..."
[[ -f ~/.ssh/id_rsa.pub ]] || ssh-keygen -t rsa

success "Copying public key to clipboard."
[[ -f ~/.ssh/id_rsa.pub ]] && cat ~/.ssh/id_rsa.pub | pbcopy

# Add SSH keys to Github
header  "Github integration"
seek_confirmation "Open https://github.com/account/ssh in your browser?"
if is_confirmed; then
	success "Copying public key to clipboard."

	[[ -f ~/.ssh/id_rsa.pub ]] && cat ~/.ssh/id_rsa.pub | pbcopy

	open https://github.com/account/ssh

	seek_confirmation "Test Github Authentication via ssh?"
		if is_confirmed; then
			notice "Testing..."
			ssh -T git@github.com
		fi
fi

header "Completed : SSH CONFIG"