#!/bin/bash

set -ex

eval "$(go env)"
echo "$GOPATH" | lolcat # should print $HOME/go or something like that

function sync_go_repo_and_patch {
    DEST="$GOPATH/src/$1"
    figlet "Syncing $1" | lolcat

    if [ ! -d $DEST ]; then
        mkdir -p $DEST
        git clone $2 $DEST
    fi

    pushd $DEST

    git am --abort || true
    git checkout master
    git fetch origin
    git rebase origin/master
    if test "$#" -gt "2" ; then
        git branch -D metalkube || true
        git checkout -b metalkube

        shift; shift;
        for arg in "$@"; do
            curl -L $arg | git am
        done
    fi
    popd
}

# Install manifests
sync_go_repo_and_patch github.com/chunfuwen/manifests https://github.com/chunfuwen/kubevirt_manifest.git

#copy manifest into dev-scripts folder
cp -r ${GOPATH}/src/github.com/chunfuwen/manifests ~/dev-scripts

#copy shell scripts into  dev-scripts folder
cp  ${GOPATH}/src/github.com/chunfuwen/manifestsi/*.sh  ~/dev-scripts


# Install rook repository
sync_repo_and_patch github.com/rook/rook https://github.com/rook/rook.git

# Install ceph-mixin repository
sync_repo_and_patch github.com/ceph/ceph-mixins https://github.com/ceph/ceph-mixins.git

# Install web ui operator repository
sync_repo_and_patch github.com/kubevirt/web-ui-operator https://github.com/kubevirt/web-ui-operator
