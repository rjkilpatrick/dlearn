# NumD

NumD is a D package that provides NumPy-like Linear algebra and scientific computing.

## Getting Started

### Prerequisits

1. dub
1. dmd / ldc

### Building from source

At present, this is the only way of obtaining NumD.
You will need [`dub`]() and a D compiler installed (preferably [`ldc`]() for fast math).

1. Download NumD from <https://github.com/rjkilpatrick/numd>
1. Copy the folder `numd` in the `source` directory into your project folder
1. `dub add-local numd`

## Usage

For more examples, please refer to the Documentation.

## Building the Documentation

NumD uses `ddox` documentation generator which you can build with:

``` sh
dub build -b ddox
```

Or you can build and then run a webserver with:

``` sh
dub run -b ddox
```

## Contributing

If you find a bug, please [submit an issue](https://github.com/rjkilpatrick/numd/issues).

Any and all contributions are appreciated.
If you think of a feature you'd like added, or how we can improve the project, submit an issue too.

## License

NumD is distributed under the MIT license, as found in the [LICENSE](LICENSE) file.
