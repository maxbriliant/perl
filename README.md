[![Actions Status](https://www.iconfinder.com/icons/4691330/download/png/512)](https://stallman.org)
(https://wiki.gentoo.org/wiki/Main_Page)

<table class="infobox biography vcard" style="width:22em"><tbody><tr><th colspan="2" style="text-align:center;font-size:125%;font-weight:bold"><div class="fn" style="display:inline">Maksimoto Yukihiro<br>Маси-мото Юкихиро</div></th></tr><tr><td colspan="2" style="text-align:center;font-size:125%; font-weight:bold;"><div class="nickname">辉煌 敬意 
</div></td></tr><tr>

<td colspan="2" style="text-align:center">
<a href="" 
<class="image"><img alt="https://ih1.redbubble.net/image.74043243.5885/flat,800x800,075,f.jpg" src="https://ih1.redbubble.net/image.74043243.5885/flat,800x800,075,f.jpg" decoding="async" width="" height="" srcset="https://ih1.redbubble.net/image.74043243.5885/flat,800x800,075,f.jpg" data-file-width="500" data-file-height="680"></a>


</div></td></tr><tr><th scope="row">Born</th><td><span style="display:none"> (<span class="bday">1994-04-05</span>) </span>May 4. 1994<span class="noprint ForceAgeToShow"> (age&nbsp;23)</span><br><div style="display:inline" class="birthplace"><a href="https://pl.wikipedia.org/wiki/Malina_(ro%C5%9Blina)" title="Malinvoka">Malinovka</a>, China</div></td></tr><tr><th scope="row">Nationality</th><td class="category">German</td></tr><tr><th scope="row">Nick&nbsp;name</th><td class="nickname">Makz</td></tr><tr><th scope="row">Occupation</th><td class="role">Computer scientist, programmer, Student</td></tr><tr><th scope="row">Known&nbsp;for</th><td><a href="https://en.wikipedia.org/wiki/Platypux" title="Slackware Tux">Platypux</a></td></tr><tr></tr></tbody></table></td>



# What's Ruby

<div style="text-align: right"><a href="https://thepracticaldev.s3.amazonaws.com/i/r4ezmdl8gnv45aahl987.png">
<class="image"><img alt="https://thepracticaldev.s3.amazonaws.com/i/r4ezmdl8gnv45aahl987.png" src="https://thepracticaldev.s3.amazonaws.com/i/r4ezmdl8gnv45aahl987.png" decoding="async" width="340" height="240" srcset="https://thepracticaldev.s3.amazonaws.com/i/r4ezmdl8gnv45aahl987.png" data-file-width="600" data-file-height="240"></a>


Ruby is an interpreted object-oriented programming language often
used for web development. It also offers many scripting features
to process plain text and serialized files, or manage system tasks.
It is simple, straightforward, and extensible.

## Features of Ruby

*   Simple Syntax
*   **Normal** Object-oriented Features (e.g. class, method calls)
*   **Advanced** Object-oriented Features (e.g. mix-in, singleton-method)
*   Operator Overloading
*   Exception Handling
*   Iterators and Closures
*   Garbage Collection
*   Dynamic Loading of Object Files (on some architectures)
*   Highly Portable (works on many Unix-like/POSIX compatible platforms as
    well as Windows, macOS, Haiku, etc.) cf.
    https://github.com/ruby/ruby/blob/master/doc/contributing.rdoc#platform-maintainers


## How to get Ruby

For a complete list of ways to install Ruby, including using third-party tools
like rvm, see:

https://www.ruby-lang.org/en/downloads/

### Git

The mirror of the Ruby source tree can be checked out with the following command:

    $ git clone https://github.com/ruby/ruby.git

There are some other branches under development. Try the following command
to see the list of branches:

    $ git ls-remote https://github.com/ruby/ruby.git

You may also want to use https://git.ruby-lang.org/ruby.git (actual master of Ruby source)
if you are a committer.

### Subversion

Stable branches for older Ruby versions can be checked out with the following command:

    $ svn co https://svn.ruby-lang.org/repos/ruby/branches/ruby_2_6/ ruby

Try the following command to see the list of branches:

    $ svn ls https://svn.ruby-lang.org/repos/ruby/branches/


## Ruby home page

https://www.ruby-lang.org/

## Mailing list

There is a mailing list to discuss Ruby. To subscribe to this list, please
send the following phrase:

    subscribe

in the mail body (not subject) to the address
[ruby-talk-request@ruby-lang.org](mailto:ruby-talk-request@ruby-lang.org?subject=Join%20Ruby%20Mailing%20List&body=subscribe).

## How to compile and install

1.  If you want to use Microsoft Visual C++ to compile Ruby, read
    [win32/README.win32](win32/README.win32) instead of this document.

2.  If `./configure` does not exist or is older than `configure.ac`, run
    `autoconf` to (re)generate configure.

3.  Run `./configure`, which will generate `config.h` and `Makefile`.

    Some C compiler flags may be added by default depending on your
    environment. Specify `optflags=..` and `warnflags=..` as necessary to
    override them.

4.  Edit `include/ruby/defines.h` if you need. Usually this step will not be needed.

5.  Remove comment mark(`#`) before the module names from `ext/Setup` (or add
    module names if not present), if you want to link modules statically.

    If you don't want to compile non static extension modules (probably on
    architectures which do not allow dynamic loading), remove comment mark
    from the line "`#option nodynamic`" in `ext/Setup`.

    Usually this step will not be needed.

6.  Run `make`.

    * On Mac, set RUBY\_CODESIGN environment variable with a signing identity.
      It uses the identity to sign `ruby` binary. See also codesign(1).

7.  Optionally, run '`make check`' to check whether the compiled Ruby
    interpreter works well. If you see the message "`check succeeded`", your
    Ruby works as it should (hopefully).

8.  Optionally, run `make update-gems` and `make extract-gems`.

    If you want to install bundled gems, run `make update-gems` and
    `make extract-gems` before running `make install`.

9.  Run '`make install`'.

    This command will create the following directories and install files into
    them.

    *   `${DESTDIR}${prefix}/bin`
    *   `${DESTDIR}${prefix}/include/ruby-${MAJOR}.${MINOR}.${TEENY}`
    *   `${DESTDIR}${prefix}/include/ruby-${MAJOR}.${MINOR}.${TEENY}/${PLATFORM}`
    *   `${DESTDIR}${prefix}/lib`
    *   `${DESTDIR}${prefix}/lib/ruby`
    *   `${DESTDIR}${prefix}/lib/ruby/${MAJOR}.${MINOR}.${TEENY}`
    *   `${DESTDIR}${prefix}/lib/ruby/${MAJOR}.${MINOR}.${TEENY}/${PLATFORM}`
    *   `${DESTDIR}${prefix}/lib/ruby/site_ruby`
    *   `${DESTDIR}${prefix}/lib/ruby/site_ruby/${MAJOR}.${MINOR}.${TEENY}`
    *   `${DESTDIR}${prefix}/lib/ruby/site_ruby/${MAJOR}.${MINOR}.${TEENY}/${PLATFORM}`
    *   `${DESTDIR}${prefix}/lib/ruby/vendor_ruby`
    *   `${DESTDIR}${prefix}/lib/ruby/vendor_ruby/${MAJOR}.${MINOR}.${TEENY}`
    *   `${DESTDIR}${prefix}/lib/ruby/vendor_ruby/${MAJOR}.${MINOR}.${TEENY}/${PLATFORM}`
    *   `${DESTDIR}${prefix}/lib/ruby/gems/${MAJOR}.${MINOR}.${TEENY}`
    *   `${DESTDIR}${prefix}/share/man/man1`
    *   `${DESTDIR}${prefix}/share/ri/${MAJOR}.${MINOR}.${TEENY}/system`


    If Ruby's API version is '*x.y.z*', the `${MAJOR}` is '*x*', the
    `${MINOR}` is '*y*', and the `${TEENY}` is '*z*'.

    **NOTE**: teeny of the API version may be different from one of Ruby's
    program version

    You may have to be a super user to install Ruby.

If you fail to compile Ruby, please send the detailed error report with the
error log and machine/OS type, to help others.

Some extension libraries may not get compiled because of lack of necessary
external libraries and/or headers, then you will need to run '`make distclean-ext`'
to remove old configuration after installing them in such case.

## Copying

See the file [COPYING](COPYING).

## Feedback

Questions about the Ruby language can be asked on the Ruby-Talk mailing list
(https://www.ruby-lang.org/en/community/mailing-lists) or on websites like
(https://stackoverflow.com).

Bugs should be reported at https://bugs.ruby-lang.org. Read [HowToReport] for more information.

[HowToReport]: https://bugs.ruby-lang.org/projects/ruby/wiki/HowToReport

## Contributing

See the file [CONTRIBUTING.md](CONTRIBUTING.md)

## The Author

Ruby was originally designed and developed by Yukihiro Matsumoto (Matz) in 1995.

<matz@ruby-lang.org>
