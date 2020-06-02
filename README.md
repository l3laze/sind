# **sind**
Simple interactive dialog for shells. Developed for Bash 4+ using Ubuntu 18+ through [UserLAnd on Android](https://play.google.com/store/apps/details?id=tech.ula).

[![Build Status](https://travis-ci.org/l3laze/sind.svg?branch=master)](https://travis-ci.org/l3laze/sind)


# Usage

`source ./sind.sh`
`userChoice=$(sind "Choose one..." "  Yes   " "   No   " " Batman " " Cancel ")`
`echo -e "\nSelected $userChoice"`


# Install

`wget https://github.com/l3laze/sind/releases/latest -O sind.sh && chmod u+x ./sind.sh`

`curl https://github.com/l3laze/sind/releases/latest -o sind.sh && chmod u+x ./sind.sh`
