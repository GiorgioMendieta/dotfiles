#!/bin/sh

# Generating a new SSH key with the email address provided as an argument
# https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key
echo "Generating a new SSH key for GitHub..."
ssh-keygen -t ed25519 -C $1 -f ~/.ssh/id_ed25519

# Adding your SSH key to the ssh-agent
# https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#adding-your-ssh-key-to-the-ssh-agent
echo "Starting the ssh-agent..."
eval "$(ssh-agent -s)"

echo "Creating ~/.ssh/config file..."
touch ~/.ssh/config
echo "Host *.github.com\n  AddKeysToAgent yes\n  UseKeychain yes\n  IdentityFile ~/.ssh/id_ed25519" | tee ~/.ssh/config

echo "Adding your SSH key to the ssh-agent..."
ssh-add -K ~/.ssh/id_ed25519

# Adding your SSH key to your GitHub account
# https://docs.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account
pbcopy <~/.ssh/id_ed25519.pub
echo "The public key has been copied to keyboard. (pbcopy < ~/.ssh/id_ed25519.pub)"
echo "Please follow the following steps to add your SSH key to your GitHub account:"
echo ""
steps=1
link=https://github.com/settings/profile
echo "$((steps++)). Go to the following link (cmd + double click): ${link}"
echo "$((steps++)). In the 'Access' section of the sidebar, click SSH and GPG keys."
echo "$((steps++)). Click New SSH key or Add SSH key."
echo "$((steps++)). In the 'Title' field, add a descriptive label for the new key."
echo "$((steps++)). Select the type of key, either authentication or signing."
echo "$((steps++)). In the 'Key' field, paste your public key."
echo "$((steps++)). Click Add SSH key."
echo "$((steps++)). If prompted, confirm access to your account on GitHub. For more information, see Sudo mode."
