#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent:

CIUSER_HOME=/home/ciuser
CIUSER_BUILD_DIR=$CIUSER_HOME/build
NVM_DIR=$CIUSER_HOME/.nvm

install_tools() {
    sudo apt-get update
    sudo apt-get install -y coreutils realpath curl xz-utils
    sort --help | grep -q -- '--version-sort' || return 1 # ...verify coreutils
    realpath $PWD >/dev/null || return 1                  # ... verify realpath
    # install the latest version of shellcheck
    (
        cd /tmp \
        && curl -o shellcheck.tar.xz \
            https://storage.googleapis.com/shellcheck/shellcheck-stable.linux.x86_64.tar.xz \
        && tar xvf shellcheck.tar.xz \
        && mv shellcheck-stable/shellcheck /usr/bin/ \
        && chmod +x /usr/bin/shellcheck
    ) || return 1
    shellcheck --version | grep -E '^version:' || return 1 # ... verify shellcheck and print version
}

# workarounds because of quirky behaviour when building
# on shippable nodes.
shippable_hacks() {
    hack_nvm_sh  || return 1
}

# hack_nvm_sh() :
# Required to suppress spurious error on standard shippable build node
# when running with non-root user.
# The standard shippable build node will call nvm.sh
# any time a user shell is invoked, but only root has nvm.sh available.
hack_nvm_sh() {
    mkdir $NVM_DIR 2>/dev/null
    echo '#!/bin/bash' > $NVM_DIR/nvm.sh
    chmod a+x $NVM_DIR/nvm.sh
    chown -R ciuser:ciuser $NVM_DIR
}

prepare_ciuser() {
    adduser --disabled-password --gecos "" ciuser || return 1
    cp -r $SHIPPABLE_BUILD_DIR $CIUSER_BUILD_DIR || return 1
    chown -R ciuser:ciuser $CIUSER_BUILD_DIR || return 1
}

prepare_env() {
    install_tools   || return 1
    prepare_ciuser || return 1
    shippable_hacks || return 1
}

build() { return 0 ; } # nothing to build yet

main() {
    prepare_env || return 1
    build || return 1
}

main
