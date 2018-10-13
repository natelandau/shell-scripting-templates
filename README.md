# Bash Function Libraries
This project is collection of Bourne-again shell functions.

As for almost every function library the idea is to keep scripts readable, collect best practices and keep people from reinventing the wheel. It is developed and tested with Bash 4 (GNU) but most functions should also work in Bash 3 and on MacOS.

## Usage
All libraries are located in `lib/*`. Since we are talking about Bash, all you have to use is to source the library you want to use:
```bash
source ${BFL_PATH}/lib/Log.sh
```

For better transparency all functions, with the exception of the Log library, are intentionally self contained. They do not access variables that are defined outside of their local scope, requiring the user explicitly pass all inputs to them instead of just setting some "magic" variables. The same applies to return values.

Some functions take or return arrays. Since Bash does not support to pass arrays, references and their serialized string representations are used.
Pass an array as to a function:
```bash
declare -a my_array=()
Array::contains_element my_array[@] ${some_element}
```

Read an array returned by a function:
```bash
declare -a kernel_available=$( System::Kernel::get_available )
# The returned string looks like '( [0]="4.16.18-gentoo" [1]="4.17.13-gentoo" [2]="4.17.14-gentoo" )'
# and will be transformed to an array automatically
```


## Libraries

### Array
Functions related to bash arrays

### Http
Functions related to the internet

### Log
Functions related to terminal and file logging
*Note: Logging to files is not yet implemented.*

All available colors and formats are made available as constants that can be used in strings:
* `CLR_GOOD`
* `CLR_INFORM`
* `CLR_WARN`
* `CLR_BAD`
* `CLR_HILITE`
* `CLR_BRACKET`
* `CLR_NORMAL`
* `FMT_BOLD`
* `FMT_UNDERLINE`

The same applies to the available log levels
* `LOG_LVL_OFF`
* `LOG_LVL_ERR`
* `LOG_LVL_WRN`
* `LOG_LVL_INF`
* `LOG_LVL_DBG`

The current log level and whether a timestamp should be added to each entry can be configured:
```bash
LOG_LEVEL=${LOG_LVL_INF}
LOG_SHOW_TIMESTAMP=true
```

### Maven
Functions related to the build tool Apache Maven

### Nexus
Functions related to the software repository manager Sonatype Nexus

### Ssh
Functions related to the Secure Shell

### String
Functions related to Bash Strings

### System
Functions related to Linux Systems

### Util
Library of useful utility functions


## Running the tests
Most functions are covered with tests using the [Bash Automated Testing System (BATS)](https://github.com/sstephenson/bats) by [Sam Stephenson](https://github.com/sstephenson)

Each library has its own test suite that can be run separately:
```
$ bats test/*.bats
```


## Authors

* **Michael Strache** - *Initial work* - [Jarodiv](https://github.com/Jarodiv)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
