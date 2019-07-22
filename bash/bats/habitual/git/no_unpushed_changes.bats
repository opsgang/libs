#!/bin/bash
# vim: et sr sw=4 ts=4 smartindent syntax=sh:
#

load git

@test "no_unpushed_changes skips checks if DEVMODE" {
    # ... setup - working dir is non-git dir
    export DEVMODE=true

    # ... run
    run no_unpushed_changes
    print_on_err

    # ... verify
    [[ $status -eq 0 ]]
    [[ $output =~ skipping\ git\ checks ]]
}
