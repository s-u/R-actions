# R-actions

This repository contains various GitHub Actions for R that can be used in GitHub workflows.

## pkg-check

GitHub action to build, install and check an R package.

Minimal example:

```yaml
  - uses: s-u/R-actions/pkg-check@master
```

By default it expects the package's `DESCRIPTION` file in the root of the repository and no systems dependencies. It will run `R CMD build`, automatically install package dependencies from CRAN, run `R CMD INSTALL` and finally `R CMD check`.

## Inputs

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

## Examples

A real example with external system dependencies:
```yaml
  - uses: s-u/R-actions/pkg-check@master
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
        os: [ 'windows-latest', 'macOS-10.15', 'ubuntu-20.04' ]

    steps:
      - uses: actions/checkout@v2

      - uses: s-u/R-actions/pkg-check@master
```

__NOTE__: The action does not modify the R configuration, it will use whichever R version has been provided. Therefore it is common to combine this action with something like `r-lib/actions/setup-r@master` to add multiple R versions to the check matrix.
