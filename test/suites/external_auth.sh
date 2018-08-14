test_macaroon_auth() {
    # shellcheck disable=SC2039
    local identity_endpoint
    # shellcheck disable=SC2086
    identity_endpoint="$(cat ${TEST_DIR}/macaroon-identity.endpoint)"

    ensure_has_localhost_remote "$LXD_ADDR"

    lxc config set candid.api.url "$identity_endpoint"

    # invalid credentials make the remote add fail
    # shellcheck disable=SC2039
    ! cat <<EOF | lxc remote add macaroon-remote "https://$LXD_ADDR" --auth-type candid --accept-certificate
wrong-user
wrong-pass
EOF

    # valid credentials work
    # shellcheck disable=SC2039
    cat <<EOF | lxc remote add macaroon-remote "https://$LXD_ADDR" --auth-type candid --accept-certificate
user1
pass1
EOF

    # run a lxc command through the new remote
    lxc config show macaroon-remote: | grep -q candid.api.url

    # cleanup
    lxc config unset candid.api.url
    lxc config unset core.https_address
    lxc remote remove macaroon-remote
}
