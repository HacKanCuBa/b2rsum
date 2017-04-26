# b2rsum
Bash script to compute and check BLAKE2 message digest recursively. It's a [`b2sum`](http://www.gnu.org/software/coreutils/b2sum) wrapper that adds the capability of processing an entire directory.

## Requirements

These come by default in most modern distros.

* [Bash](http://www.gnu.org/software/bash/)
* [GNU Getopt](http://www.kernel.org/pub/linux/utils/util-linux/)
* [b2sum](http://www.gnu.org/software/coreutils/b2sum)

## Installing

Clone this repository or download a [release](https://github.com/HacKanCuBa/b2rsum/releases), then run `make install` as privileged user (probably `sudo make install`).

### Verifying

You can optionally do `make lint && make test` to check for errors (it requires [shellcheck](https://github.com/koalaman/shellcheck) for linting), specially if you are cloning the repository.

Tests can also be run individually with `make tests/tXXXX-description.sh` and debugged with `./tests/tXXXX-description.sh -v`. [Sharness](https://github.com/chriscool/sharness) is used as framework.

## Examples of use

By default, if no parameters are passed, or a dot is used, the current directory is checked. Dot files are always included in the check!

```
hackan@dev:/tmp/b2sum$ b2rsum
b2rsum v0.1.0 Copyright (C) 2017 HacKan (https://hackan.net)

87b95c42320170686763b1d06b925df113edbeb2303ec14005cf57b7fa50bd694ed35907d45cd622848d15bf2ec1c2cd48d084199ea32e44625b0465c2837a02  /tmp/b2sum/test4
f3d464f5ce9592d6042e9c56b11db79d62c11bac46e988ebb678129fc8488eedbbd04aa9038308806489964416597d6ad723a9dacfd143bdd58059cf93c79f35  /tmp/b2sum/test5
```

Several files or directories can be specified

```
hackan@dev:~$ b2rsum /tmp/b2sum /tmp/b2sum-2
b2rsum v0.1.0 Copyright (C) 2017 HacKan (https://hackan.net)

bb66fc7524a77ea47fd949f4472f21e1ba87b2a77ffe5fd1c57c5c856f8e2f7f4711e816a00101b23740771dc3d19960c7e2376ca816b32ef708ea45eb69103e  /tmp/b2sum/test2
aea384705e52359b3f4ff4b4f0122b7afa2f7fb5f186d21770c2460ca199710d55e926fb5dd1813baf8725d5e71d15ec35f036781248c358b229eebefcce64d3  /tmp/b2sum/test1
fbab3b736a159baa0c6db12fe95928a7025312ce734ee451272e8b0ea738e5a777cf9e61d93f14fcfefd3f1719f4c4993e8bd9a56a9d405fc83540d8f8f806a2  /tmp/b2sum-2/test1
```

It accepts globs too, and the output can be pipped or redirected easily since the version header is in stderr:

```
hackan@dev:~$ b2rsum /tmp/b2sum* > BLAKE2SUMS
b2rsum v0.1.0 Copyright (C) 2017 HacKan (https://hackan.net)

hackan@dev:~$ cat BLAKE2SUMS 
bb66fc7524a77ea47fd949f4472f21e1ba87b2a77ffe5fd1c57c5c856f8e2f7f4711e816a00101b23740771dc3d19960c7e2376ca816b32ef708ea45eb69103e  /tmp/b2sum/test2
aea384705e52359b3f4ff4b4f0122b7afa2f7fb5f186d21770c2460ca199710d55e926fb5dd1813baf8725d5e71d15ec35f036781248c358b229eebefcce64d3  /tmp/b2sum/test1
fbab3b736a159baa0c6db12fe95928a7025312ce734ee451272e8b0ea738e5a777cf9e61d93f14fcfefd3f1719f4c4993e8bd9a56a9d405fc83540d8f8f806a2  /tmp/b2sum-2/test1
```

The output can be silenced with `--quiet` (show only errors and warnings) or `--status` (show no messages at all). Of course, when in creation mode, checksums are always displayed. Those options have no effect regarding displaying of checksums.
Using `--output`, the output is redirected to a file named BLAKE2SUMS as in the example above:

```
hackan@dev:~$ b2rsum --quiet --output /tmp/b2sum*
hackan@dev:~$ cat BLAKE2SUMS 
bb66fc7524a77ea47fd949f4472f21e1ba87b2a77ffe5fd1c57c5c856f8e2f7f4711e816a00101b23740771dc3d19960c7e2376ca816b32ef708ea45eb69103e  /tmp/b2sum/test2
aea384705e52359b3f4ff4b4f0122b7afa2f7fb5f186d21770c2460ca199710d55e926fb5dd1813baf8725d5e71d15ec35f036781248c358b229eebefcce64d3  /tmp/b2sum/test1
fbab3b736a159baa0c6db12fe95928a7025312ce734ee451272e8b0ea738e5a777cf9e61d93f14fcfefd3f1719f4c4993e8bd9a56a9d405fc83540d8f8f806a2  /tmp/b2sum-2/test1
```

Check the man page (`man b2rsum`) or the help (`b2rsum --help`) for more options.

## License

**b2rsum** is made by [HacKan](https://hackan.net) under GNU GPL v3.0+. Forks, Issues, PRs, etc, are all welcome.

    Copyright (C) 2017 HacKan (https://hackan.net)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

