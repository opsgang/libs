#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent:

BATS_GIT_URL="${BATS_GIT_URL:-https://github.com/bats-core/bats-core}"
BATS_GIT_REF="${BATS_GIT_REF:-master}"

install_tools() {
    export DEBIAN_FRONTEND=noninteractive
    apt-get -qq update
    apt_get_if_missing "coreutils realpath" || return 1

    _install_test_tools || return 1
}

coreutils_exists() {
    # ... check if sort can handle semver - that's a GNU extension
    ( set -o pipefail ; sort --help | grep -q -- '--version-sort' )
}

realpath_exists() { realpath $(pwd) ; }

parallel_exists() { parallel --version ; }

libxml2_utils_exists() { xmllint --version ; }

apt_get_if_missing() {
    local pkgs="$1"
    local rc=0
    local pkg="" to_install="" verify_func=""

    for pkg in $pkgs; do
        verify_func="${pkg//-/_}_exists"
        $verify_func &>/dev/null || to_install="$pkg $to_install"
    done

    if [[ ! -z "$to_install" ]]; then
        echo "INFO: will install $to_install"
        apt-get -y install $to_install
    fi

    for pkg in $to_install; do
        verify_func="${pkg//-/_}_exists"
        if ! $verify_func &>/dev/null
        then
            echo >&2 "ERROR: could not install $pkg"
            rc=1
        fi
    done

    return $rc
}

_install_test_tools() {
    _install_bats \
    && _install_strip_ansi_cli \
    && _install_tap_xunit
}

# ... _install_bats, also installs parallel
_install_bats() {
    local d=/var/tmp/bats-core
    git clone --depth 1 --branch $BATS_GIT_REF $BATS_GIT_URL $d
    (
        cd $d
        local rc=0

        ./install.sh /usr/local
        if ! bats --version &>/dev/null
        then
            echo >&2 "ERROR: could not install bats"
            rc=1
        fi
        rm -rf $d &>/dev/null

        apt_get_if_missing "parallel" || rc=1
        exit $rc
    )
}

_install_strip_ansi_cli() {
    npm i -g --silent strip-ansi-cli
    vstr="\033[1mFoo Bar\033[0m"

    if [[ "$(echo -e "$vstr" | strip-ansi 2>/dev/null)" != "Foo Bar" ]]; then
        echo >&2 "ERROR: could not install strip-ansi-cli"
        return 1
    else
        return 0
    fi
}

_install_tap_xunit() {
    npm i -g --silent tap-xunit
    # ... libxml2 provides xmllint for verification
    apt_get_if_missing "libxml2-utils" || return 1
    vstr='1..2\nok 1 foo test\nok 2 bar test\n'
    (
        set -o pipefail
        if ! echo -e "$vstr" | tap-xunit | xmllint --format - &>/dev/null
        then
            echo "ERROR: could not verify tap-junit install"
            return 1
        else
            return 0
        fi
    )
}

prepare_env() {
    install_tools   || return 1
}

build() { return 0 ; } # nothing to build yet

main() {
    prepare_env || return 1
    build || return 1
}

main
