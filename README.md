# sind


Simple interactive dialog for shells. Developed for Bash 4+ using Ubuntu 18+ through [UserLAnd on Android](https://play.google.com/store/apps/details?id=tech.ula).

[![Build Status](https://travis-ci.org/l3laze/sind.svg?branch=master)](https://travis-ci.org/l3laze/sind)


## Usage

`source ./sind.sh`

`userChoice=$(sind "Choose one..." "  Yes   " "   No   " " Batman " " Cancel ")`

`echo -e "\nSelected $userChoice"`


----


## Install

`wget https://github.com/l3laze/sind/releases/latest -O /usr/local/bin/sind.sh && chmod u+x /usr/local/bin/sind.sh`

`curl https://github.com/l3laze/sind/releases/latest -o /usr/local/bin/sind.sh && chmod u+x ./usr/local/bin/sind.sh`


[https://github.com/l3laze/sind/install.sh](https://github.com/l3laze/sind/install.sh)


----


## Credits


- [Alexander Klimetschek and his Stack Exchange answer](https://unix.stackexchange.com/a/415155/310780)
-


----


## Contributing


Please ensure your pull request adheres to the following guidelines:


- **Please [open an issue](https://github.com/l3laze/sind/issues) before creating any new features**.
- Bug fixes are more than welcome.
- Check your spelling and grammar (if applicable).
- Make sure your text editor is set to remove trailing whitespace.


----


## License

This project is distributed under the MIT License.