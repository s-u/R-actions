#!/bin/bash

OS="$1"
DEPTYPE="$2"
CRAN="$3"

echo "::group::Install $PACKAGE and dependencies"
mkdir -p $BLDIR/repo/src/contrib
mkdir $BLDIR/Rlib
SAFEDIR=$BLDIR
cp $SRCTAR $BLDIR/repo/src/contrib
REPOURL="file://$BLDIR/repo"
if [ "$OS" = Linux -o "$DEPTYPE" = source ]; then
    PKGTYPE=source
else ## create a fake, empty binary repo
    BRPATH=$BLDIR/repo`Rscript -e 'cat(contrib.url('\'\'',.Platform$pkgType))'`
    echo Binary install - target repo is $BRPATH
    mkdir -p $BRPATH
    echo '' > $BRPATH/PACKAGES
    ls -l $BRPATH
    PKGTYPE=both
fi
if [ "$OS" = Windows ]; then
    SAFEDIR=$(cd $BLDIR && Rscript -e 'cat(getwd())')
    REPOURL="file:$SAFEDIR/repo"
fi
R_LIBS=$BLDIR/Rlib Rscript -e "\
         tools::write_PACKAGES('$SAFEDIR/repo/src/contrib',type='source'); \
         if (isTRUE('@CRAN@' %in% getOption('repos'))) { repos <- getOption('repos'); repos['CRAN'] <- '$CRAN'; options(repos = repos) }; \
         install.packages('$PACKAGE',,c('$REPOURL',getOption('repos')), type='$PKGTYPE', dependencies=TRUE) \
       "
echo '::endgroup::'
