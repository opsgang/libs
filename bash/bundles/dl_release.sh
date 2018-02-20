#!/bin/bash
GHREPO=https://github.com/opsgang/libs

FETCH_TAG='v0.1.1'
FETCH_URL="https://github.com/opsgang/fetch/releases/download/$FETCH_TAG/fetch.tgz"
FETCH_DL='/tmp/ghfetch'

usage() {
    cat <<EOF
ERROR $_SN: usage:

  $_SN <bundle> '<constraint>' <download dir>

  e.g.
  $_SN terraform_run.tgz '~>1.0' /home/me/project/

  OR provide your github token for preferential rate-limit.
  GITHUB_TOKEN=\$token $_SN terraform_run.tgz '~>1.0' /home/me/project/

  ... will create /home/me/project if it does not exist.

  ... will also download opsgang/fetch binary to /tmp/ghfetch if not
      already in your \$PATH. This will be deleted on success.
EOF
}

retry_fetch() {
    local rc=1 retries=3 delay=3

    while [[ $(( retries-- )) -gt 0 ]]; do
        $FETCH \
            --repo="$GHREPO" \
            --tag="$CONSTRAINT"  \
            --release-asset="$BUNDLE" \
            $DOWNLOAD_DIR

        [[ $? -eq 0 ]] && rc=0 && break

        echo "INFO: $_SN: ... failed fetching. Retries left: $retries"
    done

    [[ $? -ne 0 ]] && echo "ERROR $_SN: ... giving up. Is github.com down?"
    return $rc
}

discover_fetch() {
    local rc=1
    local valid_names="fetch ghfetch /tmp/ghfetch"
    local rx='^ *fetch \[global options\] <local-download-path>$'

    for name in $valid_names; do
        if type -P $name >/dev/null && $name --help 2>/dev/null | grep "$rx" >/dev/null
        then
            type -P $name
            rc=0
            break
        fi
    done
    return $rc
}

fetch_me_fetch() {
    echo "INFO $_SN: downloading opsgang 'fetch' binary to $FETCH_DL"
    echo "INFO $_SN: ... we use this to retrieve the release binary"
    echo "INFO $_SN:     version that meets the constraint $CONSTRAINT."

    curl \
        -sS -L --retry 3 \
        -H 'Accept: application/octet-stream' \
        $FETCH_URL \
    | tar -xzv -C /tmp \
    && mv /tmp/fetch /tmp/ghfetch

    if [[ $? -eq 0 ]]; then
        echo "INFO $_SN: fetch downloaded to as $FETCH_DL"
        echo "INFO $_SN: ... learn more about what fetch can do at" 
        echo "INFO $_SN:     https://github.com/opsgang/fetch"
        return 0
    else
        echo "ERROR $_SN: could not download opsgang fetch ($FETCH_URL)"
        return 1
    fi
}

_auth_header() {
    if [[ ! -z "$GITHUB_TOKEN" ]]; then
        echo "-H 'Authorization: token $GITHUB_TOKEN'"
    fi
}

_SN=dl_release.sh

BUNDLE="$1"
CONSTRAINT="$2"
DOWNLOAD_DIR="$3"

RC=0

echo "INFO $_SN: Running."

for var in BUNDLE CONSTRAINT DOWNLOAD_DIR; do
    [[ -z "${!var}" ]] && RC=1
done

[[ $RC -ne 0 ]] && echo "ERROR $_SN requires 3 args." && usage && exit 1

if [[ -z "$GITHUB_TOKEN" ]]; then
    echo "INFO $_SN: \$GITHUB_TOKEN not in env:"
    echo "INFO $_SN: ... you will be strictly rate limited by github."
else
    export GITHUB_OAUTH_TOKEN="$GITHUB_TOKEN"
fi

if ! FETCH=$(discover_fetch); then
    ! fetch_me_fetch && exit 1
    FETCH="$FETCH_DL"
else
    echo "INFO $_SN: Found a suitable 'fetch': $FETCH"
fi

exit 0

if [[ -e "$DOWNLOAD_DIR" ]]; then
    if [[ ! -d "$DOWNLOAD_DIR" ]]; then
        echo "ERROR $_SN: $DOWNLOAD_DIR exists but not a directory"
        echo "ERROR $_SN: ... won't be able to download to there!"
        exit 1
    fi
else    
    echo "INFO $_SN: creating $DOWNLOAD_DIR if needed."
    mkdir -p $DOWNLOAD_DIR && [[ ! -d "$DOWNLOAD_DIR" ]] && exit 1
fi
retry_fetch || exit 1


