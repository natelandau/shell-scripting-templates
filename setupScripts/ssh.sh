#!/usr/bin/env bash

# This script creates public SSH Keys and sends them to Github

if [ -f "../lib/utils.sh" ]; then
  source "../lib/utils.sh"
else
  echo "You must have utils.sh to run.  Exiting."
  exit
fi

e_header "Running : SSH CONFIG"

e_success  "Checking for SSH key in ~/.ssh/id_rsa.pub, generating one if it doesn't exist ..."
[[ -f ~/.ssh/id_rsa.pub ]] || ssh-keygen -t rsa

e_success "Copying public key to clipboard."
[[ -f ~/.ssh/id_rsa.pub ]] && cat ~/.ssh/id_rsa.pub | pbcopy

# Add SSH keys to Github
e_header  "Github integration"
seek_confirmation "Open https://github.com/account/ssh in your browser?"
if is_confirmed; then
	e_success "Copying public key to clipboard."

	[[ -f ~/.ssh/id_rsa.pub ]] && cat ~/.ssh/id_rsa.pub | pbcopy

	open https://github.com/account/ssh

	seek_confirmation "Test Github Authentication via ssh?"
		if is_confirmed; then
			printf "\n Testing..."
			ssh -T git@github.com
		fi
fi

e_header "Completed : SSH CONFIG"