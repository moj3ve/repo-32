#!/bin/bash
DEBFILE="$1"
TMPDIR=`mktemp -d /tmp/deb.XXXXXXXXXX` || exit 1
OUTPUT=`basename "$DEBFILE" .deb`.deb

if [[ -e "$OUTPUT" ]]; then
  echo "$OUTPUT exists."
  rm -r "$TMPDIR"
  exit 1
fi

dpkg-deb -x "$DEBFILE" "$TMPDIR"
dpkg-deb --control "$DEBFILE" "$TMPDIR"/DEBIAN

if [[ ! -e "$TMPDIR"/DEBIAN/control ]]; then
  echo DEBIAN/control not found.

  rm -r "$TMPDIR"
  exit 1
fi

CONTROL="$TMPDIR"/DEBIAN/control

MOD=`stat -c "%y" "$CONTROL"`
sensible-editor "$CONTROL"

if [[ "$MOD" == `stat -c "%y" "$CONTROL"` ]]; then
  echo Not modified.
else
  echo Building new deb...
  dpkg -b "$TMPDIR" "$OUTPUT"
fi

rm -r "$TMPDIR"