#!/bin/bash

echo "::group::Building $PACKAGE tar ball"
R --version | head -n4
rm -f toolchain.tar.zst ## fix for UCRT, just in case it's left over...

BLDIR="$(cd $SRCDIR/.. && pwd)"
if [ -z "$BLCMD" ]; then 
    BLCMD="cd $BLDIR && R CMD build $SRCDIR"
fi
bash -c "$BLCMD"
SRCTAR=`ls -d $BLDIR/${PACKAGE}_*tar.gz`
if [ -z "$SRCTAR" ]; then
    echo "::error ::ERROR: cannot build package tar ball"
    exit 1
fi
ls -l $SRCTAR
echo SRCTAR=$SRCTAR >> $GITHUB_ENV
echo SRCDIR=$SRCDIR >> $GITHUB_ENV
echo BLDIR=$BLDIR >> $GITHUB_ENV
echo '::endgroup::'
