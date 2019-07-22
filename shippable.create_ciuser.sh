#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent:
#
# This script creates a user to run the tests
# as some require non-superuser permissions
# to work e.g. testing a file is unreadable
#
prepare_ciuser() {
    adduser --disabled-password --gecos "" ciuser || return 1
    cp -r $SHIPPABLE_BUILD_DIR $CIUSER_BUILD_DIR || return 1
    chown -R ciuser:ciuser $CIUSER_BUILD_DIR || return 1
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

main() {
    # ... required vars
    [[ -z "$CIUSER_BUILD_DIR" ]] && exit 1
    [[ -z "$NVM_DIR" ]] && exit 1

    prepare_ciuser && shippable_hacks
}

main
