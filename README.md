# BrightProof [![Page on DUB](https://img.shields.io/dub/v/brightproof.svg)](http://code.dlang.org/packages/brightproof) [![Licence](https://img.shields.io/dub/l/brightproof.svg)](https://github.com/azbukagh/BrightProof/blob/master/LICENCE.md)
=============
SemVer 2.0.0 parsing and constructing library

## Comparing
You can compare structs.
```
SemVer("1.0.0-rc.1") < SemVer("1.0.0-rc.20");
SemVer("1.0.0-rc.1") < SemVer("1.0.0");
SemVer("1.0.0-rc.1") < SemVer("1.0.0+build.1");
```

## Examples
Check out `./examples` directory

## Compile-time
You can use this library at compile-time.
```
pragma(msg, SemVer("1.0.0").nextMajor.nextMinor.toString);
```
