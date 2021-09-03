# NumD

[![GitHub latest release](https://img.shields.io/github/release/rjkilpatrick/numd.svg?maxAge=86400&style=flat-square)](https://github.com/rjkilpatrick/numd/releases)
[![Github Issues](https://img.shields.io/github/issues/rjkilpatrick/numd?style=flat-square)](https://github.com/rjkilpatrick/numd/issues)
[![Github build status](https://img.shields.io/github/workflow/status/rjkilpatrick/numd/Run%20all%20dub%20unit%20tests?style=flat-square)](https://github.com/rjkilpatrick/NumD/actions/workflows/unit-test.yml)
[![License](https://img.shields.io/github/license/rjkilpatrick/numd?style=flat-square)](https://github.com/rjkilpatrick/NumD/blob/main/LICENSE)

High-level Linear algebra and scientific computing package in D.

## State of the Project

The **API** is in very early stages and is subject to change **without notice**.
If you are using it in your own projects, please pin to an [exact version](https://github.com/dlang/dub/wiki/Version-management).

## Getting Started

### Prerequisits

1. [dub](https://dub.pm/)
1. [dmd / ldc](https://dlang.org/download.html)

### Building from source

At present, this is the only way of obtaining NumD before the name is finalized.

1. Download NumD from <https://github.com/rjkilpatrick/numd>
1. Copy the folder `numd` in the `source` directory into your project folder
1. `dub add-local numd`

## Usage

```d
import std : writeln;
import numd.allocation : ones;
import numd.math : sinh;

auto x = ones!double(2, 2);
x.sinh.writeln;
```

For more examples, please refer to the [Documentation](https://rjkilpatrick.github.io/NumD/).

## Building the Documentation

NumD uses `ddox` documentation generator which you can build with:

```sh
dub build -b ddox
```

Or you can build and then run a webserver with:

```sh
dub run -b ddox
```

## Contributing

If you find a bug, please [submit an issue](https://github.com/rjkilpatrick/numd/issues).

Any and all contributions are appreciated.
If you think of a feature you'd like added, or how we can improve the project, submit an issue too.

## License

NumD is distributed under the MIT license, as found in  [LICENSE](LICENSE).
