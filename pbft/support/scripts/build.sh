#!/bin/bash
set -x

export GOOS=$1
export GOARCH=amd64

protoc -I src/pbft-core/fastchain/ \
          src/pbft-core/fastchain/fastchain.proto \
          --go_out=plugins=grpc:src/pbft-core/fastchain/

git_commit_hash() {
    echo $(git rev-parse --short HEAD)
}

export GOPATH=$GOPATH:`pwd`:`pwd`/..

OUTDIR="bin/$GOOS"
mkdir -p "$OUTDIR"

if [ "$GOOS" = "linux" ]; then
    export CGO_ENABLED=1
fi

LDFLAGS="-s -w -X common.GitCommitHash=$(git_commit_hash)"

go build -o "$OUTDIR"/pbft-client \
    -ldflags "$LDFLAGS" \
    ./src/pbft-core/client/

go build -o "$OUTDIR"/truechain-engine \
    -ldflags "$LDFLAGS" \
    ./src/pbft-core/pbft-sim-engine/
