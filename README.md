# b3rsum

**b3rsum** is a Bash script to compute and check BLAKE3 message digest recursively. It's a [`b3sum`](https://github.com/BLAKE3-team/BLAKE3) wrapper that adds the capability of processing an entire directory.

It accepts all of *b3sum* options plus new ones. Files generated with it are 100% compatible with *b3sum* and vice versa. See more at the [examples](#examples-of-use).

This is free (as in freedom and beer) software under GNU GPL v3.0+.

## Requirements

These come by default in most modern distros.

* [Bash](http://www.gnu.org/software/bash/)
* [GNU Getopt](http://www.kernel.org/pub/linux/utils/util-linux/)
* [b3sum](https://github.com/BLAKE3-team/BLAKE3)

## Installing

Clone this repository or download a [release](https://github.com/HacKanCuBa/b3rsum/releases), then run `make install` as privileged user (probably `sudo make install`).

### Verifying

You can optionally do `make lint && make test` to check for errors (it requires [shellcheck](https://github.com/koalaman/shellcheck) for linting), specially if you are cloning the repository.

Tests can also be run individually with `make tests/tXXXX-description.sh` and debugged with `./tests/tXXXX-description.sh -v`. [Sharness](https://github.com/chriscool/sharness) is used as framework.

## Examples of use

### Complete use case: b3rsum to verify a backup

Store the checksums of every file in the current directory, copy every file to a backup destination then check if the copy succeeded.

```
hackan@dev:/var/lib/mongodb$ b3rsum -o
b3rsum v0.1.3 Copyright (C) 2020 HacKan (https://hackan.net)

Saving results in BLAKE3SUMS
hackan@dev:/var/lib/mongodb$ rsync -raP . /mnt/backup/
sending incremental file list
...
hackan@dev:/var/lib/mongodb$ cd /mnt/backup/
hackan@dev:/mnt/backup/$ b3rsum -oRESULTS -wc BLAKE3SUMS && echo "ALL FILES OK" || echo "SOME FILE FAILED!"
b3rsum v0.1.3 Copyright (C) 2020 HacKan (https://hackan.net)

Saving results in RESULTS
ALL FILES OK
```

In this example, the *BLAKE3SUMS* file was copied the same way as the rest of the files, so in case of a transfer failure, the posibility of ending with a corrupted file exists. Maybe using other transfer method would be preferred, or calculating the BLAKE3 of that file, or even signing the file with GPG.

The last line sums it all up: `-o` stores the results in the given file *RESULTS* so it can be analized later; `-wc` executes the checking, reading from *BLAKE3SUMS* file, and throws warning about improperly formatted checksum lines (helps detecting corruption of itself, but previously mentioned methods are better). Finally, a simple `echo` is used for better visual feedback.

### Complete use case: b3rsum to verify Github releases

Github can generate a release from a tag, like the [ones here](https://github.com/HacKanCuBa/b3rsum/releases). When you create a release, Github grabs every file in the repository and creates two packages: a zip and a tar.gz. However, even though tags can be signed, those automatically generated packages can not! An advance user can `git clone` the repository, then `git verify-tag` the tag, to finally `git checkout` that tag; but a non-git user (most users) rely on those releases. So, there's a real need to also sign those packages!.

Another option is to omit the usage of those packages but there'll be always a distracted user that might use them, so the following aproach is better.

What to do then? Verify those packages, sign them and upload the signatures to the release (releases can be easily edited to uplad files). The process of verifying those packages consist in two main steps: check that files from the local repo hasn't been modified in the package, and check that there are no extraneous foreign files.

1. Use *b3rsum* to create a hash file of the local repo, download packages from the release and check the files in there:

```
hackan@dev:~/workspace/my-repo$ b3rsum -o
b3rsum v0.1.3 Copyright (C) 2020 HacKan (https://hackan.net)

Saving results in BLAKE3SUMS
hackan@dev:~/workspace/my-repo$ cd /tmp
hackan@dev:/tmp$ wget https://github.com/my-username/my-repo/archive/tag-name.tar.gz
hackan@dev:/tmp$ tar -xf tag-name.tar.gz
hackan@dev:/tmp$ cd tag-name
hackan@dev:/tmp/tag-name$ cp ~/workspace/my-repo/BLAKE3SUMS ./
hackan@dev:/tmp/tag-name$ b3rsum -oRESULTS -c --ignore-missing BLAKE3SUMS && echo "ALL OK" || echo "WOW! Something fishy's going on"
b3rsum v0.1.3 Copyright (C) 2020 HacKan (https://hackan.net)

Saving results in RESULTS
ALL OK
```

Since *b3rsum* will hash *every* file in the local repo, which include dot files and dirs, like *.git* dir, that are not included in the packages (obviously), `--ignore-missing` is necessary or warnings will be raised. Once again `echo` is used for quick visual feedback, but checking the *RESULT* file is convenient.

2. Use *b3rsum* to create a hash file from the package and compare it with the local repo, to ensure there're no foreign files:

```
hackan@dev:/tmp/tag-name$ b3rsum -o
b3rsum v0.1.3 Copyright (C) 2020 HacKan (https://hackan.net)

Saving results in BLAKE3SUMS
hackan@dev:/tmp/tag-name$ cd ~/workspace/my-repo
hackan@dev:~/workspace/my-repo$ cp /tmp/tag-name/BLAKE3SUMS ./
hackan@dev:~/workspace/my-repo$ b3rsum -oRESULTS -c BLAKE3SUMS && echo "ALL OK" || echo "WOW! Something fishy's going on"
b3rsum v0.1.3 Copyright (C) 2020 HacKan (https://hackan.net)

Saving results in RESULTS
ALL OK
```

Now, we are interested in any file that is missing, or left, so full check with *b3rsum*. If everything goes ok, now the package can be signed:

```
hackan@dev:/tmp$ gpg --sign tag-name.tar.gz
```

The same operation must be done for the zip package, and that's it! Upload signature files to Github. Trully verified releases :)

### In deep

By default, if no parameters are passed, or a dot is used, the current directory is checked. Dot files are always included in the check!

```
hackan@dev:/tmp/b3sum$ b3rsum
b3rsum v0.1.3 Copyright (C) 2020 HacKan (https://hackan.net)

87b95c42320170686763b1d06b925df113edbeb2303ec14005cf57b7fa50bd694ed35907d45cd622848d15bf2ec1c2cd48d084199ea32e44625b0465c2837a02  /tmp/b3sum/test4
f3d464f5ce9592d6042e9c56b11db79d62c11bac46e988ebb678129fc8488eedbbd04aa9038308806489964416597d6ad723a9dacfd143bdd58059cf93c79f35  /tmp/b3sum/test5
```

Several files or directories can be specified

```
hackan@dev:~$ b3rsum /tmp/b3sum /tmp/b3sum-2
b3rsum v0.1.3 Copyright (C) 2020 HacKan (https://hackan.net)

bb66fc7524a77ea47fd949f4472f21e1ba87b2a77ffe5fd1c57c5c856f8e2f7f4711e816a00101b23740771dc3d19960c7e2376ca816b32ef708ea45eb69103e  /tmp/b3sum/test2
aea384705e52359b3f4ff4b4f0122b7afa2f7fb5f186d21770c2460ca199710d55e926fb5dd1813baf8725d5e71d15ec35f036781248c358b229eebefcce64d3  /tmp/b3sum/test1
fbab3b736a159baa0c6db12fe95928a7025312ce734ee451272e8b0ea738e5a777cf9e61d93f14fcfefd3f1719f4c4993e8bd9a56a9d405fc83540d8f8f806a2  /tmp/b3sum-2/test1
```

It accepts globs too, and the output can be pipped or redirected easily since the version header is in stderr:

```
hackan@dev:~$ b3rsum /tmp/b3sum* > BLAKE3SUMS
b3rsum v0.1.3 Copyright (C) 2020 HacKan (https://hackan.net)

hackan@dev:~$ cat BLAKE3SUMS 
bb66fc7524a77ea47fd949f4472f21e1ba87b2a77ffe5fd1c57c5c856f8e2f7f4711e816a00101b23740771dc3d19960c7e2376ca816b32ef708ea45eb69103e  /tmp/b3sum/test2
aea384705e52359b3f4ff4b4f0122b7afa2f7fb5f186d21770c2460ca199710d55e926fb5dd1813baf8725d5e71d15ec35f036781248c358b229eebefcce64d3  /tmp/b3sum/test1
fbab3b736a159baa0c6db12fe95928a7025312ce734ee451272e8b0ea738e5a777cf9e61d93f14fcfefd3f1719f4c4993e8bd9a56a9d405fc83540d8f8f806a2  /tmp/b3sum-2/test1
```

The output can be silenced with `--quiet` (it shows only errors and warnings) or `--status` (it shows no messages at all). Of course, when in creation mode, checksums are always displayed. Those options have no effect regarding displaying of checksums.
Using `--output`, or the short `-o`, the output is redirected to a file named *BLAKE3SUMS* as in the example above (note that the destination file is overwritten w/o question):

```
hackan@dev:~$ b3rsum --quiet --output /tmp/b3sum*
hackan@dev:~$ cat BLAKE3SUMS 
bb66fc7524a77ea47fd949f4472f21e1ba87b2a77ffe5fd1c57c5c856f8e2f7f4711e816a00101b23740771dc3d19960c7e2376ca816b32ef708ea45eb69103e  /tmp/b3sum/test2
aea384705e52359b3f4ff4b4f0122b7afa2f7fb5f186d21770c2460ca199710d55e926fb5dd1813baf8725d5e71d15ec35f036781248c358b229eebefcce64d3  /tmp/b3sum/test1
fbab3b736a159baa0c6db12fe95928a7025312ce734ee451272e8b0ea738e5a777cf9e61d93f14fcfefd3f1719f4c4993e8bd9a56a9d405fc83540d8f8f806a2  /tmp/b3sum-2/test1
```

During a check routine (`--check`), those options causes the output to be silenced, thus appending the `--output` option will result in an empty file.

To use a file different than *BLAKE3SUMS* as output, use `--output=FILE` or the short version `-oFILE`. Using spaces isn't allowed (it's a *getopt* limitation).

Check the man page (`man b3rsum`) or the help (`b3rsum --help`) for more options.

## Help

```
b3rsum v0.1.3 Copyright (C) 2020 HacKan (https://hackan.net)

Usage: b3rsum [OPTION]... [FILE or DIRECTORY]...

Print or check BLAKE3 checksums recursively.
If no FILE or DIRECTORY is indicated, or it's a dot (.), then the current
directory is processed.
The default mode is to compute checksums. Check mode is indicated with --check.

Options:
  -c, --check                read BLAKE3 sums from the FILEs and check them
  -o[FILE], --output[=FILE]  output to FILE instead of standard output, or a
                             file named BLAKE3SUMS in the current
                             directory if FILE is not specified
  -q, --quiet                quiet mode: don't print messages, only hashes;
                             during check mode, don't print OK for each
                             successfully verified file
  -s, --status               very quiet mode: output only hashes, no messages;
                             status code shows success
  --license                  show license and exit
  --version                  show version information and exit
  -h, --help                 show this text and exit

The following four options are useful only when computing checksums:
  -t, --text                 read in text mode (default)
  -b, --binary               read in binary mode
      --tag                  create a BSD-style checksum
  -l, --length               digest length in bits; must not exceed the maximum
                             for the blake3 algorithm and must be a multiple
                             of 8

The following three options are useful only when verifying checksums:
      --ignore-missing  don't fail or report status for missing files
      --strict         exit non-zero for improperly formatted checksum lines
  -w, --warn           warn about improperly formatted checksum lines

Sums are made using 'b3sum'. Full documentation at: 
  <https://github.com/BLAKE3-team/BLAKE3>.
The sums are computed using the BLAKE3 algorithm.  When checking, the input
should be a former output of this program.  The default mode is to print a
line with checksum, a space, a character indicating input mode ('*' for binary,
' ' for text or where binary is insignificant), and name for each FILE.

This program comes with ABSOLUTELY NO WARRANTY.
This is free software, and you are welcome to redistribute it under certain
conditions; type 'b3rsum --license' for details.

More information may be found in the b3rsum(1) man page.
```

## License

**b3rsum** is made by [HacKan](https://hackan.net) under GNU GPL v3.0+. Forks, Issues, PRs, etc, are all welcome.

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

