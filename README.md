# R-actions

This repository contains various GitHub Actions for R that can be used in GitHub workflows.

## pkg-check

GitHub action to build, install and check an R package.

Minimal example:

```yaml
  - uses: s-u/R-actions/pkg-check@v1
```

By default it expects the package's `DESCRIPTION` file in the root of the repository and no systems dependencies. It will run `R CMD build`, automatically install package dependencies from CRAN, run `R CMD INSTALL` and finally `R CMD check`.

### Inputs

* `debian-deps`

    Optional list of Debian/Ubuntu packages that need to be installed using `apt-get install`.
    
* `macos-deps`

    Optional list of macOS dependencies from [R-macos recipes](https://github.com/R-macos/recipes) (with versions) that need to be installed.

* `pkg-path`

    The subdirectory containing the `DESCRIPTION` file. Defaults to `.` (i.e., root of the repository)

* `check-flags`

    Additional flags to use for checking (e.g. `--as-cran`)

* `build-script`

    Optional script to use instead of `R CMD build` (e.g., `sh mkdist`). It is expected to create the package tar ball one level up from the repository directory (so the same as if one called `(cd .. && R CMD build <package>)`.

### Examples

A real example with external system dependencies:
```yaml
  - uses: s-u/R-actions/pkg-check@v1
    with:
      debian-deps: libtiff-dev
      macos-deps: pkgconfig-0.28 xz-5.2.4 jpeg-9 tiff-4.1.0
      check-flags: --as-cran
```

See the [pkg-check-test repository](https://github.com/s-u/pkg-check-test) for this example in action (based on the [tiff package](https://github.com/s-u/tiff)).

Full `check.yaml` example to put in `.github/actions` which tests on Ubuntu, macOS and Windows:

```yaml
on: [push, pull_request]

name: Package Check

jobs:
  check:
    runs-on: ${{ matrix.os }}

    name: ${{ matrix.os }} check

    strategy:
      fail-fast: false
      matrix:
        os: [ 'windows-2022', 'macOS-10.15', 'ubuntu-22.04' ]
        r-version: [ release, devel ]

    steps:
      - uses: actions/checkout@v2
      
      - uses: s-u/R-actions/install@v1
        with:
          r-version: ${{ matrix.r-version }}

      - uses: s-u/R-actions/pkg-check@v1
```

## install

GitHub action to install R on the runner.

Minimal example:

```yaml
  - uses: s-u/R-actions/install@v1
```

This installs a well-defined R based on CRAN tar balls, binaries (macOS and Windows) and releases. It is very fast to run.

### Inputs

* `r-version`

    Version of R to install. Only `devel` and `release` are guaranteed to work on all platforms.

* `tools`

    Optional specification of the toolchian to install. Currently this is only used on Windows and passed as the `toolchain-type` of the `toolchain-install` actions from [ucrt3](https://github.com/kalibera/ucrt3), so the valid options are `none`, `base` and `full`.

The binaries for the Linux runners are created using the [R-build](https://github.com/s-u/R-build) repository based on CRAN nightly tar balls which live in `/opt/R/` (with symlinks from `/usr/local`). The macOS builds come from [last-success](https://mac.r-project.org/high-sierra/last-success/) CRAN builds and Windows build from [pre-release](https://cran.r-project.org/bin/windows/base/rdevel.html) CRAN builds.


## tinytex

GitHub action to install [TinyTex](https://yihui.org/tinytex/)

Minimal example:

```yaml
  - uses: s-u/R-actions/tinytex@v1
```

The runners don't have TeX by default so if you want to be able to check R package manuals, you will need to install it in some way and this action is just one of the possible ways.

### Inputs

* `flavor`

    Optional name of the distribution. The possible values are release names from [tinytex-releases](https://github.com/yihui/tinytex-releases) with `TinyTeX` as default. `TinyTeX-1` is the minimal distribution for R packages.

* `version`

    Optional TinyTeX version number. Defaults to `latest` which is the latest daily release. See [releases](https://github.com/yihui/tinytex-releases/releases) for available version numbers.
