#!/bin/bash
set -e

SELFDIR=`dirname "$0"`
cd "$SELFDIR/../.."
source "./internal/lib/library.sh"

require_envvar WORKSPACE "$WORKSPACE"
require_envvar REPOSITORY "$REPOSITORY"

PASSENGER_ROOT="${PASSENGER_ROOT:-$WORKSPACE}"
CONCURRENCY=${CONCURRENCY:-8}

if [[ "$REPOSITORY" =~ -testing$ ]]; then
	YANK=-y
else
	YANK=
fi

run ./build \
	-w "$WORKSPACE/work" \
	-c "$WORKSPACE/cache" \
	-o "$WORKSPACE/output" \
	-p "$PASSENGER_ROOT" \
	-j "$CONCURRENCY" \
	-R \
	-O \
	pkg:all
run ./publish \
	-d "$WORKSPACE/output" \
	-c ~/.packagecloud_token \
	-r "$REPOSITORY" \
	-l "$WORKSPACE/publish-log" \
	$YANK \
	publish:all