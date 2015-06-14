#!/bin/bash -x

brewapps=(
    zsh
    zsh-completions
    bash
    git
    vim
    ack
    hg
    mercurial
    fasd
    go
    unrar
    awscli
    wget
    ctags
    the_silver_searcher
    tmux
    hub
    gnu-tar
    gnu-sed
    gawk
    asciidoc
    docbook
    aspell
    fortune
    mtr
    stow
    autoconf
    automake
    chuck
    cowsay
    gdbm
    jenv
    tree
    gettext
    jq
    pcre
    xz
    bazaar
    emacs
    gibo
    readline
    yuicompressor
    openssl
    libgpg-error
    libksba
    enscript
    libyaml			
)

caskapps=(
  1password
  a-better-finder-rename
  acorn
  appcleaner
  asepsis
  atom
  audio-hijack
  audiomate
  balsamiq-mockups
  bartender
  base
  carbon-copy-cloner
  cheatsheet
  cocktail
  coda
  dash
  diffmerge
  drobo-dashboard
  dropbox
  firefox
  fission
  fitbit-connect
  flash-player
  flip4mac
  flowdock
  fontexplorer-x-pro
  garmin-ant-agent
  garmin-express
  garmin-training-center
  github
  gitter
  google-adwords-editor
  google-chrome
  google-drive
  google-earth
  google-earth-web-plugin
  google-hangouts
  google-notifier
  gopro-studio
  handbrake
  hazel
  hipchat
  imageoptim
  ishowu
  istat-menus
  iterm2
  kaleidoscope
  knox
  launchbar
  little-snitch
  macvim
  mail-plugin-manager
  monotype-skyfonts
  mountain
  mplayer-osx-extended
  nvalt
  omnidazzle
  omnifocus
  omnifocus-clip-o-tron
  omnigraffle
  opera
  path-finder
  paw
  qlmarkdown
  qlstephen
  qlvideo
  reflector
  screenflow
  scrivener
  seil
  sizeup
  skype
  slack
  smartgit
  snagit
  sourcetree
  superduper
  transmission
  transmit
  typinator
  vlc
  webpquicklook
  yubikey-personalization-gui
)

req()
{
    command -v $1 >/dev/null 2>&1 || { echo "I require $1 but it's not installed.  Aborting." >&2; exit 1; }
}


echo "***************************"
echo "  Step 1. Installing Brew  "
echo "***************************"

if [ ! -f /usr/local/bin/brew ]
then
  echo "Installing: brew"
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  echo "Found: brew"
fi

req brew
brew update
brew upgrade

echo "*****************************************"
echo "  Step 2. Installing software with brew  "
echo "*****************************************"

for app in $brewapps ; do
    if [ ! -f /usr/local/bin/$app ]
    then
      echo "Installing: $app"
      brew install $app
    else
      echo "Found: $app"
    fi
done

brew install coreutils --with-default-names
brew install findutils --with-default-names
echo "Don’t forget to add $(brew --prefix coreutils)/libexec/gnubin to \$PATH."
brew tap homebrew/dupes
brew install homebrew/dupes/grep
brew install homebrew/dupes/rsync

echo "*********************************************"
echo "  Step 3. Installing NonBrew shell software  "
echo "*********************************************"

echo "spf13-vim"
if [ -d $HOME/.spf13-vim-3 ];
then
    echo "spf13-vim already installed"
else
    curl http://j.mp/spf13-vim3 -L -o - | sh
fi

echo "oh-my-zsh install"
if [ -d $HOME/.oh-my-zsh ];
then
    echo "oh-my-zsh already installed"
else
    curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
fi


echo "***************************************"
echo "  Step 4. Installing desktop software  "
echo "***************************************"

brew install caskroom/cask/brew-cask

echo "Installing Desktop (Cask) Apps"
brew cask install --appdir="/Applications" ${caskapps[@]}
brew cleanup


echo "**********************************"
echo "  Step 5. Installing Go software  "
echo "**********************************"
req go

go get github.com/nsf/gocode
go get github.com/laher/goxc
go get github.com/spf13/hugo
go get golang.org/x/tools/cmd/gorename
go get golang.org/x/tools/cmd/goimports
go get golang.org/x/tools/cmd/oracle
go get github.com/golang/lint/golint
go get golang.org/x/tools/cmd/gotype

echo "*************************"
echo "    Final Instructions"
echo "*************************"

echo "run dropboxSetup.sh"
echo "then run this..."
echo ""
echo "cd $GOPATH/src/github.com/spf13/"
echo 'for x in *; do rm -rf $x; git clone git@github.com:spf13/$x.git; done;'
echo ""
echo 'For vim +lua run `brew install macvim --with-lua --override-system-vim`'
