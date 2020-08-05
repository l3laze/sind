# sind


A semi-magical list-based selection dialog for Bash 4+ with reasonable defaults. Features single and multiple choice modes, and can display the option list on a single line. Developed on Ubuntu 18+ through [UserLAnd on Android](https://play.google.com/store/apps/details?id=tech.ula).


![CI](https://github.com/l3laze/sind/workflows/CI/badge.svg) [![Codacy Badge](https://app.codacy.com/project/badge/Grade/3212c5503ee94a42adb04cd730304493)](https://www.codacy.com/manual/l3laze/sind?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=l3laze/sind&amp;utm_campaign=Badge_Grade) [![codecov](https://codecov.io/gh/l3laze/sind/branch/master/graph/badge.svg)](https://codecov.io/gh/l3laze/sind)


[![Generic badge](https://img.shields.io/badge/Made%20with-Bash-black.svg)](https://shields.io/) [![Only 4 Kb](https://badge-size.herokuapp.com/l3laze/sind/master/sind.sh)](https://github.com/l3laze/sind/blob/master/sind.sh)


----


<details><summary><b>Table of contents</b></summary>

  * [Usage](#Usage)
    - [Options](#Options)
    - [Example](#Example)
    - [Output](#Output)
  * [Installation](#Installation)
    - [Automatic](#Automatic)
    - [Manual](#Manual)
  * [Credits](#Credits)
  * [Contributing](#Contributing)
  * [License](#License)
</details>


----


## Usage


### Options


| Option | What? |
| --- | --- |
| -c, --cancel | Add cancel to end of options. |
| -h, --help | Display this message. |
| -l, --line | Single-line option list. |
| -m, --multiple | Multiple choice. |
| -o, --options | List of options, space-separated. |
| -t, --title | Header to print above prompt. |
| -v, --version | Print version. |


### Example


```sh
echo "$(sind -t Title -o Okay -c)"
```


### Output:


```sh
Title
(up|j, down|k, enter: choose)
----------------------------------
[7mOkay[27m << Color "reversed" on selected item
Cancel
----------------------------------
Okay
```


----


## Installation


### Automatic


```sh
# Download fully and then run:
sh -c "$(curl -sSL https://raw.githubusercontent.com/l3laze/sind/install.sh)"


# Run lines while downloading:
curl -sSL https://raw.githubusercontent.com/l3laze/sind/install.sh | bash
```


This will install to /usr/local/bin.


### Manual


* Download `sind.sh`, optionally rename it to `sind`.
* Move it to a directory that's available from your `$PATH`, or to the project that you're working on.
* Make it executable with `chmod u+x ./sind.sh` (or just sind, if you changed it).


For a single user it can be installed to `$HOME/bin`  (though it may not exist by default). For a system-wide install `/usr/local/bin` is best, based on the [Linux filesystem hierarchy](https://linux.die.net/man/7/hier) and related answers on [StackExchange](https://unix.stackexchange.com/questions/8656/usr-bin-vs-usr-local-bin-on-linux).


----


## Credits


- [Alexander Klimetschek's Stack Exchange answer](https://unix.stackexchange.com/a/415155/310780)
- [mtfurlan's vi keybinding patch](https://github.com/l3laze/sind/issues/1)


----


## Contributing


Please ensure your pull request adheres to the following guidelines:


- **Please [Open an issue](https://github.com/l3laze/sind/issues) before creating any new features**, for discussion.
- Bug fixes & POSIX-friendly changes are more than welcome!
- Check your spelling and grammar (if applicable).
- Try to use a text editor that will remove trailing whitespace (though mine on mobile can't..lol).
- Lint with [shellcheck](https://www.shellcheck.net/). This is done on push, but doing so while developing helps minimize senseless builds which are a waste of resources.


----


## License


This project is distributed under The Unlicense.
