#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent:

CIUSER_HOME=/home/ciuser
CIUSER_BUILD_DIR=$CIUSER_HOME/build
NVM_DIR=$CIUSER_HOME/.nvm

install_tools() {
    sudo apt-get update
    sudo apt-get install -y coreutils realpath shellcheck
    sort --help | grep -q -- '--version-sort' || return 1 # ...verify coreutils
    realpath $PWD >/dev/null || return 1                  # ... verify realpath
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
