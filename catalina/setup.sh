#!/bin/bash

# homebrew
if command -v brew &> /dev/null
then
  echo "==> Brew already installed; skipping"
else
  echo "==> Installing Homebrew"
  CI=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  brew update
  brew upgrade
  brew upgrade --cask
  brew doctor
fi

# python3
if command -v python3 &> /dev/null
then
  echo "==> Python already installed; skipping"
else
  echo "==> Installing Python3"
  brew install python
fi

# change default python to v3
cat >~/.zprofile <<EOL
# override path
export PATH="/usr/local/bin:\$PATH"
# make python3 the default python
alias python=$(which python3)
alias pip=$(which pip3)
EOL