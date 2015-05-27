# syncTemplate.sh
This sync script template provides a mechanism to use either [rsync][1] or [unision][2] to keep two directories in sync.  

## Usage

1. Execute the template and follow the prompts to create a new script for your needs
2. Execute the new script to create a new configuration file.
3. Edit the information within that configuration file.
4. Execute the script again. It will optionally encrypt your configuration file to keep your passwords safe, and then sync your directories.

For help and additional options, run the script with the `-h` flag.



[1]: https://rsync.samba.org
[2]: http://www.cis.upenn.edu/~bcpierce/unison/
