#!/usr/bin/env bash
# vim: et sr sw=4 ts=4 smartindent:
# Cancels redundant PR builds on circleci pipelines.
# Expected to be run from Github Actions.
#
# This only works for PR branches as it relies on
# env var GITHUB_HEAD_REF which only exists for PRs
# in github actions.
#
# This is by design - generally we don't want to cancel
# builds of commits on release or main branches as sometimes
# we need to deploy different commits sequentially rather than
# bundled. However commits on a PR generally should get squashed
# as they are all part of the same feature or bugfix and we only
# need to built the HEAD of it.

REQUIRED_VARS="
    CIRCLE_TOKEN
    CCI_ORG_NAME
    GH_BRANCH
"

CCI_GITHUB_APP="${CCI_GITHUB_APP:-}" # set to true if you access CircleCi with Github App
CCI_API="https://circleci.com/api/v2"

# If you access circleci with github app and not oauth
# set CCI_ORG_NAME to your Circleci org id (see your org settings)
if [[ -n "$CCI_GITHUB_APP" ]]; then
    if [[ -z "$CCI_ORG_NAME" ]]; then
        echo >&2 "ERROR: using CCI_GITHUB_APP: set env var CCI_ORG_NAME to your CircleCI org ID"
        exit 1
    fi
    CCI_VCS_SLUG="circleci"
else
    # defaults when using CircleCI oauth, not github app
    CCI_VCS_SLUG="gh"
    CCI_ORG_NAME="${GITHUB_REPOSITORY}"
fi

declare -a WORKFLOWS_TO_CANCEL=()

set_GH_BRANCH() {
    GH_BRANCH=""
    case "${GITHUB_EVENT_NAME:-}" in
      pull_request*) GH_BRANCH="$GITHUB_HEAD_REF" ;;
      *) GH_BRANCH="$GITHUB_REF_NAME" ;;
    esac

    if [[ -z "$GH_BRANCH" ]]; then
        echo >&2 "ERROR: couldn't set GH_BRANCH based on trigger event [${GITHUB_EVENT_NAME:-}]"
        return 1
    fi

    export GH_BRANCH
    return 0
}

required_vars() {
    local rc=0
    local required_vars="$1"
    local this_var=""
    for this_var in $required_vars; do
        if ! check_var_defined $this_var
        then
            failed="${failed}\$$this_var "
            rc=1
        fi
    done
    [[ $rc -ne 0 ]] && echo >&2 "ERROR: following vars must be set in env:\n$failed"
    return $rc
}

check_var_defined() { [[ ! -z "${!1}" ]] ; }

pipelines_for_branch() {
    local o=""
    o=$(
        curl -sS --request GET \
            --url "$CCI_API/project/${CCI_VCS_SLUG}/${CCI_ORG_NAME}/pipeline?branch=$GH_BRANCH" \
            --header "Circle-Token: ${CIRCLE_TOKEN}" \
        | jq -r '.items[].id'
    )

    if [[ $? -ne 0 ]] || [[ -z "${o:-}" ]]; then
        echo >&2 "ERROR: failed to get pipelines for branch $GH_BRANCH"
        return 1
    else
        echo "$o"
        return 0
    fi
}

cancel_workflows() {
    local rc=0
    for id in ${WORKFLOWS_TO_CANCEL[@]}; do
        echo "INFO: attempting to cancel workflow id $id"
        curl --request POST \
            --url "$CCI_API/workflow/$id/cancel" \
            --header "Circle-Token: ${CIRCLE_TOKEN}" \
        || rc=1
    done

    return $rc
}

workflow_for_pipeline() {
    local pipeline_id="$1"
    local o=""
    o=$(
        curl -sS --request GET \
            --url "${CCI_API}/pipeline/${pipeline_id}/workflow" \
            --header "Circle-Token: ${CIRCLE_TOKEN}" \
        | jq -r '.items[] | select(.status | test("running|failing|on_hold")) | .id'
    )
    if [[ $? -ne 0 ]]; then
        echo >&2 "ERROR: failed to get single workflow for pipeline $pipeline_id"
        return 1
    else
        echo "$o"
        return 0
    fi
}

main() {
    set_GH_BRANCH || return 1
    required_vars "$REQUIRED_VARS" || return 1

    echo "INFO: Getting pipelines for branch $GH_BRANCH"
    pipeline_ids=$(pipelines_for_branch) || return 1

    local rc=0
    for pipeline_id in $pipeline_ids; do
        ! workflow_id=$(workflow_for_pipeline "$pipeline_id") && rc=1 && continue
        [[ -n "$workflow_id" ]] && WORKFLOWS_TO_CANCEL+=("$workflow_id")
    done

    if [[ ${#WORKFLOWS_TO_CANCEL[@]} -lt 1 ]]; then
        echo "INFO: found no active workflows to cancel."
        return 0
    fi

    echo "INFO: will cancel these workflow ids:" ${WORKFLOWS_TO_CANCEL[*]}
    if cancel_workflows
    then
        echo "INFO: all currently running workflows cancelled successfully"
        return 0
    else
        echo "INFO: Didn't kill all workflows successfully."
        echo "INFO: Please clean them up manually via the circleci dashboard"
        return 1
    fi

}

main
exit 0
