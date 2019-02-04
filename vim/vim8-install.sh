#!/bin/sh

# Name:        vim8-install.sh
# Summary:     script to install Vim8 from sources.
# Author:      Yakov Lerner
# Date:        2006-10-19


USAGE=\
'Description: download, build and install vim8 from hg sources.
    First off, script asks you whether you want to install Vim
    system-wide (you need to know root password for that), or
    under user'"'"'s $HOME (for one user only).

    Vim will be built and configured with --with-features=huge.
    You can pass configure options on the commandline. All options
    starting with -- are passed to configure. vim8-install.sh --help
    prints list of all options recognized by configure.

Options:
    any option beginning with -- is passed to configure.
    --help   print list of --options recognized by configure step.
    -cvs     use cvs method to pull the sources.
    -svn     use svn method to download sources
    -hg      use hg  method to download sources.
    -git     use git method to download sources. This is default method.
';

# [deleted] zipfile of commandline installs from given zipfile
# [deleted] -f   force download even if same-named zipfile is found locally

METHODS_LIST="git hg svn cvs"
DOWNLOAD_METHOD="git"; # allowed value are 'git' ('git' is default), 'hg', 'svn', 'cvs'.

die() { echo 1>&2 "$*"; exit 100; }


dieUsage() { echo "${USAGE?}"; exit 100; }

prog=`basename $0`


ASSIGN_DIR() { # sets global $DIR and $BLD
    # DIR=/var/tmp/user$uid/`basename $ZIP .zip`.src
    case "$DOWNLOAD_METHOD" in
    "cvs")
        DIR=/var/tmp/user$uid/vim8_from_cvs ;;
    "svn")
        DIR=/var/tmp/user$uid/vim8_from_svn ;;
    "hg")
        DIR=/var/tmp/user$uid/vim8_from_hg ;;
    "git")
        DIR=/var/tmp/user$uid/vim8_from_git ;;
    *)
        die "Error, unknown download method ($1), must be 'git', 'hg' or 'svn' or 'cvs'"
    esac
    mkdir -p $DIR || die "ERROR creating directory"
    BLD=$DIR/vim8
}

CLEAN_ALL() {
    for method in $METHODS_LIST; do
        DOWNLOAD_METHOD=$method
        ASSIGN_DIR # sets global $DIR and $BLD
        echo "    * cleaning ${DIR?} ..."
        case ${DIR?} in */tmp/*)
            rm -rf ${DIR?}
        esac
    done
}


CONFIG_HELP() {
    echo '------------------------------------------------------------'
    echo `basename $0` help:
    echo '------------------------------------------------------------'
    echo "$USAGE";
    echo ""

    ASSIGN_DIR # sets global $DIR and $BLD

    if test ! -f $BLD/configure ; then
        # 'svn co' does not let us check out single file.
        # another possibility is to 'svn co -N' (flat)
        # I tried 'svn co -N' (DO_SVN -N) and it still feels slow.

        STORED_CONFIGURE_HELP_COPY
    else
        echo '------------------------------------------------------------'
        echo 'configure help'
        echo '------------------------------------------------------------'
        ( cd $BLD && ./configure --help )
    fi
    exit
}

DOWNLOAD() {
echo "Download method: ${DOWNLOAD_METHOD}"
    case "$DOWNLOAD_METHOD" in
    "cvs")
        DO_CVS
    ;;
    "svn")
        DO_SVN
    ;;
    "hg")
        DO_HG
    ;;
    "git")
        DO_GIT
    ;;
    *)
        die "Error, unknown download method ($1), must be 'git' or 'hg' or 'svn' or 'cvs'"
    esac
}

DO_CVS() {
    type cvs >/dev/null 2>&1 || { \
        die "ERROR: 'cvs' utility is not installed. Please install and retry";
    }
    if test -d $DIR/vim8/CVS ; then
        echo "# previously downloaded source found."
        sleep 1
        cd $DIR/vim8 || exit 1
        ( set -x; cvs -z3 update )
    else
        mkdir -p $DIR || exit 1
        cd $DIR || exit 1
        ( set -x; cvs -z3 -d:pserver:anonymous@vim.cvs.sf.net:/cvsroot/vim checkout vim8 )
    fi
    if test $? != 0; then
        echo "CVS returned error(s). Press Enter to continue, Ctrl-C to stop"
        read ANSWER
    fi
}

SVN_WARN_ERRORS() { # $1-status code
    if test "$1" != 0; then
        echo "svn returned error(s). Press Enter to continue, Ctrl-C to stop"
        read DUMMY
    fi
}

HG_WARN_ERRORS() { # $1-status code
    if test "$1" != 0; then
        echo "hg returned error(s). Press Enter to continue, Ctrl-C to stop"
        read DUMMY
    fi
}

GIT_WARN_ERRORS() { # $1-status code
    if test "$1" != 0; then
        echo "git returned error(s). Press Enter to continue, Ctrl-C to stop"
        read DUMMY
    fi
}

CHECK_SVN_LOCAL_MODS() {
    echo "    * checking for svn locally modified files ..."
    cd $DIR/vim8 || exit 1
    MODS=`svn st | grep '^M'`
    if test "$MODS" = ""; then
        echo "No locally modified files"
    else
        while true ; do
            echo "**** Found locally modified files (dir=`pwd`) ***** "
            echo "$MODS"
            echo "**** Found locally modified files (dir=`pwd`) ***** "
            echo "Select (1) Discard local changes (2) Keep local changes [1] ?"
            read ANS
            case $ANS in
            1|"")
                echo "    * removing locally modified files"
                delfiles=`echo "$MODS" | sed 's/^.//'`
                ( set -x ; rm $delfiles )
                break
            ;;
            2)
                break
            esac
        done
    fi
}

CHECK_HG_LOCAL_MODS() {
    echo "    * checking for hg locally modified files ..."
    cd $DIR/vim8 || exit 1
    MODS=`hg st | grep '^M'`
    if test "$MODS" = ""; then
        echo "No locally modified files"
    else
        while true ; do
            echo "**** Found locally modified files (dir=`pwd`) ***** "
            echo "$MODS"
            echo "**** Found locally modified files (dir=`pwd`) ***** "
            echo "Select (1) Discard local changes (2) Keep local changes [1] ?"
            read ANS
            case $ANS in
            1|"")
                echo "    * removing locally modified files"
                delfiles=`echo "$MODS" | sed 's/^.//'`
                ( set -x ; rm $delfiles )
                break
            ;;
            2)
                break
            esac
        done
    fi
}

CHECK_GIT_LOCAL_MODS() {
    echo "    * checking for git locally modified files ..."
    cd $DIR/vim8 || exit 1
    MODS=`git status | grep '^M'`
    if test "$MODS" = ""; then
        echo "No locally modified files"
    else
        while true ; do
            echo "**** Found locally modified files (dir=`pwd`) ***** "
            echo "$MODS"
            echo "**** Found locally modified files (dir=`pwd`) ***** "
            echo "Select (1) Discard local changes (2) Keep local changes [1] ?"
            read ANS
            case $ANS in
            1|"")
                echo "    * removing locally modified files"
                delfiles=`echo "$MODS" | sed 's/^.//'`
                ( set -x ; rm $delfiles )
                break
            ;;
            2)
                break
            esac
        done
    fi
}



DO_SVN() { # $1 - svn option. We might want to pass -N to check out
           # $BLD/configure, for help text only.
    ASSIGN_DIR # sets global $DIR and $BLD

    cd "${DIR?}" || exit 1

    type svn >/dev/null 2>&1 || \
        die "Error: 'svn' utility is not installed. Please install svn and retry."

    if test -d $DIR/vim8/.svn ; then
        echo "# previously downloaded source found."
        CHECK_SVN_LOCAL_MODS

        ( set -x; cd $DIR/vim8 && svn up )

        SVN_WARN_ERRORS $?
    else
        mkdir -p vim8

        ( set -x; cd $DIR && svn co $1 https://svn.sourceforge.net/svnroot/vim/vim8 )

        SVN_WARN_ERRORS $?
    fi
}


DO_HG() { # $1 - hg option. We might want to pass -N to check out
           # $BLD/configure, for help text only.
    ASSIGN_DIR # sets global $DIR and $BLD

    cd "${DIR?}" || exit 1

    type hg >/dev/null 2>&1 || \
        die "Error: 'hg' utility is not installed. Please install hg and retry."

    if test -d $DIR/vim8/.hg ; then
        echo "# previously downloaded source found."
        CHECK_HG_LOCAL_MODS

        ( set -x; cd $DIR/vim8 && hg pull && hg update )

        HG_WARN_ERRORS $?
    else
        mkdir -p vim8

        ( set -x; hg clone https://vim.googlecode.com/hg/ vim8 )

        HG_WARN_ERRORS $?
    fi
}


DO_GIT() { # $1 - git option. We might want to pass -N to check out
           # $BLD/configure, for help text only.
    ASSIGN_DIR # sets global $DIR and $BLD

    cd "${DIR?}" || exit 1

    type git >/dev/null 2>&1 || \
        die "Error: 'git' utility is not installed. Please install git and retry."

    if test -d $DIR/vim8/.git ; then
        echo "# previously downloaded source found."
        CHECK_GIT_LOCAL_MODS

        ( set -x; cd $DIR/vim8 && git pull )

        GIT_WARN_ERRORS $?
    else
        mkdir -p vim8

        ( set -x; git clone https://github.com/vim/vim.git vim8 )

        GIT_WARN_ERRORS $?
    fi
}


HANDLE_ROOT_INSTALLATION_ERROR() {
    echo ""
    echo "Installation had errors! Enter your choice [1]:"

    while true; do
        echo ""
        echo "1) Repeat installation step using same 'su -c root '"
        echo "   Useful if you mistyped the root passord previous time"
        echo "2) Start shell in which you can do 'make install' manually"
        echo "3) Print name of directory in which 'make install' must be done"
        echo "q) Quit"

        trap "echo 'Leaving directory '`/bin/pwd`; exit 1" 0 1 2 15

        read ANS

        case $ANS in

        [qQ]*) exit 1;;

        3) for x in 1 2 3 4; do /bin/pwd; done
           sleep 2
           continue;;

        2) echo "Current dir is `/bin/pwd`"
           echo "Become root and do 'make install' in this directory"
           echo "Starting subshell ..."
           $SHELL
           exit
        ;;

        1|"") break;;

        *) continue;;

        esac
    done
}


MAKE_AND_INSTALL() {
    cd $DIR/vim8 || exit 100

    echo "Extracted in dir $DIR"
    # set -x

    if test "$NOBUILD" != 1; then
        make distclean
        ./configure $CONFIG_OPT || \
            die "ERROR running {./configure $CONFIG_OPT} in directory $DIR"
        echo "Completed configure in dir. $DIR ..."


        make || die "ERROR in make in directory $DIR"
    fi


    # time for install
    SU_COMMAND="su root -c"
    while true ; do
        if test "$IS_CYGWIN" = 1 ; then
            # cygwin does not need su
            make install || die "ERROR in install in directory $DIR"
            echo "Build and install successful"
        elif test "$ASK_ROOT" = 1; then
            echo ""
            echo "Enter root password below for installation of vim8 under /usr/local/bin"
            $SU_COMMAND "make install"
            if test $? != 0; then
                HANDLE_ROOT_INSTALLATION_ERROR
                # don't break. If HANDLE_ROOT_INSTALLATION_ERROR wanted to break, it's exit.
            else
                echo 'Leaving directory '`/bin/pwd`
                break
            fi
        else
        # non-root install
            make install || die "ERROR in install in directory $DIR"
            echo "Build and install successful"
            echo ""
            break
        fi
    done

    WARN_HOME_DIR_NOT_IN_PATH
}


WARN_HOME_DIR_NOT_IN_PATH() {
    if test "$INTO_HOME" = 1; then
        IS_DIR_IN_PATH $HOME/bin
        if test $? != 0; then
            echo "***********************************"
            echo "***********************************"
            echo '**** Warning: directory $HOME/bin is not in you PATH!'
            echo '**** You need to add directory $HOME/bin to your PATH to run new vim'
        fi
    fi
}


IS_DIR_IN_PATH() {
     _rc=1
     IFS0=$IFS; IFS=":$IFS"
     for dir in $PATH ; do
        if test "$1" = "$dir"; then
            _rc=0 # found
            break
        fi
     done
     IFS=$IFS0
     return $_rc
}


INITIAL_DIALOG() { # ->$INTO_HOME, $ASK_ROOT
    case "$CONFIG_OPT" in
    *--prefix=*) # if --prefix= is given on the command line,
                 # then skip dialogs
    ;;
    *)
        echo "This will download, build and install vim8 (using $DOWNLOAD_METHOD)."
        if test $uid = 0 ; then
            CONFIG_OPT="$CONFIG_OPT --prefix=/usr/local"

            echo ""
            echo "You are superuser."
            echo "Target install directory will be: /usr/local/bin"
            echo "Configure options will be: "
            echo "         ./configure $CONFIG_OPT"
            echo "Press Enter to continue, Ctrl-C to cancel"
            echo "->"
            read ENTER
        else
            echo "Select one of the following:"
            if test "$IS_CYGWIN" != 1; then
                echo "1) You know root password and you want to install"
                echo "   vim globally for all users on this computer"
                echo "   (into /usr/local/bin)"
            else
                # CYGWIN
                echo "1) You want to install vim globally for all users"
                echo "   on this computer (into /usr/local/bin)"
            fi
            echo "2) You do not know root password or you want to"
            echo "   install vim under your "'$'"HOME/bin directory"
            read ANS

            case $ANS in
            2) CONFIG_OPT="$CONFIG_OPT --prefix=$HOME"
               INTO_HOME=1
            ;;
            1) CONFIG_OPT="$CONFIG_OPT --prefix=/usr/local"
               ASK_ROOT=1
               if test "$IS_CYGWIN" = 1; then
                    ASK_ROOT=0
               fi
            ;;
            *) echo "Try again"
               exit 20
            esac
        fi
    esac
}


MAIN() {
    ASK_ROOT=0
    IS_CYGWIN=0
    case `uname -s` in *CYGWIN*) IS_CYGWIN=1;; esac

    uid=`id|awk -F'[()=]' '{ print $2}'`

    while test $# != 0 ; do
        case $1 in
#        -z) ZIP=$2
#            test -f $ZIP || die "ERROR: no such file ($ZIP)"
#        ;;
#        [^-]*) ZIP=$2; shift 2;
#            test -f $ZIP || die "ERROR: no such file ($ZIP)"
#        ;;
        --help)
            CONFIG_HELP
            exit
        ;;
        --*)
            CONFIG_OPT="$CONFIG_OPT $1"; shift
        ;;
        -nb)
            NOBUILD=1;
            shift
        ;;
        -x|-show-dir)
            ASSIGN_DIR # sets global $DIR and $BLD
            echo $DIR
            exit
        ;;
        -y|-show-svn)
            ASSIGN_DIR # sets global $DIR, $BLD
            echo "cd $DIR && svn co https://svn.sourceforge.net/svnroot/vim/vim8"
            exit
        ;;
        -y|-show-hg)
            ASSIGN_DIR # sets global $DIR, $BLD
            echo "cd $DIR && hg clone https://vim.googlecode.com/hg/ vim8"
            exit
        ;;
        -y|-show-git)
            ASSIGN_DIR # sets global $DIR, $BLD
            echo "cd $DIR && git clone https://github.com/vim/vim.git vim8"
            exit
        ;;
        -cvs|--cvs)
            DOWNLOAD_METHOD="cvs"; shift;
            ASSIGN_DIR # sets global $DIR, $BLD
        ;;
        -svn|--svn)
            DOWNLOAD_METHOD="svn"; shift;
            ASSIGN_DIR # sets global $DIR, $BLD
        ;;
        -hg|--hg)
            DOWNLOAD_METHOD="hg"; shift;
            ASSIGN_DIR # sets global $DIR, $BLD
        ;;
        -git|--git)
            DOWNLOAD_METHOD="git"; shift;
            ASSIGN_DIR # sets global $DIR, $BLD
        ;;
        clean|-clean|--clean)
            CLEAN_ALL
            exit;
        ;;
        *)
            echo 1>&2 "Error: bad argument: <$1>"
            echo 1>&2 ""
            dieUsage;
            exit 100;
        esac
    done

    case $CONFIG_OPT in *--with-features=*) ;;
    *) CONFIG_OPT="$CONFIG_OPT --with-features=huge" ;;
    esac

    #type hg >/dev/null 2>&1 || { \
    #    die "ERROR: 'hg' utility is not installed. Please install and retry";
    #}

    INITIAL_DIALOG # ->$INTO_HOME, $ASK_ROOT

    # before 061009, we had DO_SVN here. after 061009, he have selectable download method.
    DOWNLOAD

    MAKE_AND_INSTALL
}


    # I have some doubts about putting copy of configure-help into here.
    # The plus is that you can see --help immediately even before checkout.
    # It would be nice if I could put it at then end of script
    # Oh well, actually I can
STORED_CONFIGURE_HELP_COPY()
{
    # if $BLD/configure file is present, we obtain --help from
    # if $BLD/configure file is not present, we use stored copy
cat <<'EOF'
------------------------------------------------------------
configure help
------------------------------------------------------------
`configure' configures this package to adapt to many kinds of systems.

Usage: auto/configure [OPTION]... [VAR=VALUE]...

To assign environment variables (e.g., CC, CFLAGS...), specify them as
VAR=VALUE.  See below for descriptions of some of the useful variables.

Defaults for the options are specified in brackets.

Configuration:
  -h, --help              display this help and exit
      --help=short        display options specific to this package
      --help=recursive    display the short help of all the included packages
  -V, --version           display version information and exit
  -q, --quiet, --silent   do not print `checking...' messages
      --cache-file=FILE   cache test results in FILE [disabled]
  -C, --config-cache      alias for `--cache-file=config.cache'
  -n, --no-create         do not create output files
      --srcdir=DIR        find the sources in DIR [configure dir or `..']

Installation directories:
  --prefix=PREFIX         install architecture-independent files in PREFIX
                          [/usr/local]
  --exec-prefix=EPREFIX   install architecture-dependent files in EPREFIX
                          [PREFIX]

By default, `make install' will install all the files in
`/usr/local/bin', `/usr/local/lib' etc.  You can specify
an installation prefix other than `/usr/local' using `--prefix',
for instance `--prefix=$HOME'.

For better control, use the options below.

Fine tuning of the installation directories:
  --bindir=DIR            user executables [EPREFIX/bin]
  --sbindir=DIR           system admin executables [EPREFIX/sbin]
  --libexecdir=DIR        program executables [EPREFIX/libexec]
  --sysconfdir=DIR        read-only single-machine data [PREFIX/etc]
  --sharedstatedir=DIR    modifiable architecture-independent data [PREFIX/com]
  --localstatedir=DIR     modifiable single-machine data [PREFIX/var]
  --libdir=DIR            object code libraries [EPREFIX/lib]
  --includedir=DIR        C header files [PREFIX/include]
  --oldincludedir=DIR     C header files for non-gcc [/usr/include]
  --datarootdir=DIR       read-only arch.-independent data root [PREFIX/share]
  --datadir=DIR           read-only architecture-independent data [DATAROOTDIR]
  --infodir=DIR           info documentation [DATAROOTDIR/info]
  --localedir=DIR         locale-dependent data [DATAROOTDIR/locale]
  --mandir=DIR            man documentation [DATAROOTDIR/man]
  --docdir=DIR            documentation root [DATAROOTDIR/doc/PACKAGE]
  --htmldir=DIR           html documentation [DOCDIR]
  --dvidir=DIR            dvi documentation [DOCDIR]
  --pdfdir=DIR            pdf documentation [DOCDIR]
  --psdir=DIR             ps documentation [DOCDIR]

X features:
  --x-includes=DIR    X include files are in DIR
  --x-libraries=DIR   X library files are in DIR

Optional Features:
  --disable-option-checking  ignore unrecognized --enable/--with options
  --disable-FEATURE       do not include FEATURE (same as --enable-FEATURE=no)
  --enable-FEATURE[=ARG]  include FEATURE [ARG=yes]
  --enable-fail-if-missing    Fail if dependencies on additional features
     specified on the command line are missing.
  --disable-darwin        Disable Darwin (Mac OS X) support.
  --disable-selinux	  Don't check for SELinux support.
  --disable-xsmp          Disable XSMP session management
  --disable-xsmp-interact Disable XSMP interaction
  --enable-luainterp=OPTS     Include Lua interpreter.  default=no OPTS=no/yes/dynamic
  --enable-mzschemeinterp   Include MzScheme interpreter.
  --enable-perlinterp=OPTS     Include Perl interpreter.  default=no OPTS=no/yes/dynamic
  --enable-pythoninterp=OPTS   Include Python interpreter. default=no OPTS=no/yes/dynamic
  --enable-python3interp=OPTS   Include Python3 interpreter. default=no OPTS=no/yes/dynamic
  --enable-tclinterp      Include Tcl interpreter.
  --enable-rubyinterp=OPTS     Include Ruby interpreter.  default=no OPTS=no/yes/dynamic
  --enable-cscope         Include cscope interface.
  --enable-workshop       Include Sun Visual Workshop support.
  --disable-netbeans      Disable NetBeans integration support.
  --enable-sniff          Include Sniff interface.
  --enable-multibyte      Include multibyte editing support.
  --enable-hangulinput    Include Hangul input support.
  --enable-xim            Include XIM input support.
  --enable-fontset        Include X fontset output support.
  --enable-gui=OPTS     X11 GUI default=auto OPTS=auto/no/gtk2/gnome2/motif/athena/neXtaw/photon/carbon
  --enable-gtk2-check     If auto-select GUI, check for GTK+ 2 default=yes
  --enable-gnome-check    If GTK GUI, check for GNOME default=no
  --enable-motif-check    If auto-select GUI, check for Motif default=yes
  --enable-athena-check   If auto-select GUI, check for Athena default=yes
  --enable-nextaw-check   If auto-select GUI, check for neXtaw default=yes
  --enable-carbon-check   If auto-select GUI, check for Carbon default=yes
  --disable-gtktest       Do not try to compile and run a test GTK program
  --disable-largefile     omit support for large files
  --disable-acl           Don't check for ACL support.
  --disable-gpm           Don't use gpm (Linux mouse daemon).
  --disable-sysmouse    Don't use sysmouse (mouse in *BSD console).
  --disable-nls           Don't support NLS (gettext()).

Optional Packages:
  --with-PACKAGE[=ARG]    use PACKAGE [ARG=yes]
  --without-PACKAGE       do not use PACKAGE (same as --with-PACKAGE=no)
  --with-mac-arch=ARCH    current, intel, ppc or both
  --with-developer-dir=PATH    use PATH as location for Xcode developer tools
  --with-local-dir=PATH   search PATH instead of /usr/local for local libraries.
  --without-local-dir     do not search /usr/local for local libraries.
  --with-vim-name=NAME    what to call the Vim executable
  --with-ex-name=NAME     what to call the Ex executable
  --with-view-name=NAME   what to call the View executable
  --with-global-runtime=DIR    global runtime directory in 'runtimepath'
  --with-modified-by=NAME       name of who modified a release version
  --with-features=TYPE    tiny, small, normal, big or huge (default: normal)
  --with-compiledby=NAME  name to show in :version message
  --with-lua-prefix=PFX   Prefix where Lua is installed.
  --with-luajit           Link with LuaJIT instead of Lua.
  --with-plthome=PLTHOME   Use PLTHOME.
  --with-python-config-dir=PATH  Python's config directory
  --with-python3-config-dir=PATH  Python's config directory
  --with-tclsh=PATH       which tclsh to use (default: tclsh8.0)
  --with-ruby-command=RUBY  name of the Ruby command (default: ruby)
  --with-x                use the X Window System
  --with-gnome-includes=DIR Specify location of GNOME headers
  --with-gnome-libs=DIR   Specify location of GNOME libs
  --with-gnome            Specify prefix for GNOME files
  --with-motif-lib=STRING   Library for Motif
  --with-tlib=library     terminal library to be used

Some influential environment variables:
  CC          C compiler command
  CFLAGS      C compiler flags
  LDFLAGS     linker flags, e.g. -L<lib dir> if you have libraries in a
              nonstandard directory <lib dir>
  LIBS        libraries to pass to the linker, e.g. -l<library>
  CPPFLAGS    (Objective) C/C++ preprocessor flags, e.g. -I<include dir> if
              you have headers in a nonstandard directory <include dir>
  CPP         C preprocessor
  XMKMF       Path to xmkmf, Makefile generator for X Window System

Use these variables to override the choices made by `configure' or to help
it to find libraries and programs with nonstandard names/locations.
EOF
}



MAIN "$@"

# ------ Todo --------
# force "$ASK_ROOT" if prefix is not writable
# XXX we need to try svn twice (on OSX, fails 1st time)
# XXX  (c) "Customize Build Options" in top menu
# XXX  -> (I) include all interpreters  (i) include perl/python/ruby/scheme
# XXX  -> (t) change target dir prefix
# XXX  -> (g) select gui option
# XXX  -> detect gui option of existing vim
# XXX  -> (s) select build size

# last change
# 061019 lerner added cvs option
