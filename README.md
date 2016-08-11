# BrightProof [![Page on DUB](https://img.shields.io/dub/v/brightproof.svg)](http://code.dlang.org/packages/brightproof) [![Licence](https://img.shields.io/dub/l/brightproof.svg)](https://github.com/azbukagh/BrightProof/blob/master/LICENCE.md)
=============
SemVer 2.0.0 parser

## Usage
1. Add brightproof to your dub.json as dependency.
2. Import it:
```
import BrightProof;
```
3. And use:
```
SemVer ver = SemVer("0.0.2-beta");
ver.Major++;
ver.toString == "1.0.2-beta";
```

## Comparing
SemVer structs can be compared via `<`, `>`, `==`, `>=`, `<=`, just like any other values.
Also, PreReleases and Buildss now compared too:
```
SemVer("1.0.0-rc.1") < SemVer("1.0.0-rc.20");
SemVer("1.0.0-rc.1") < SemVer("1.0.0");
SemVer("1.0.0-rc.1") < SemVer("1.0.0+build.1");
```

## Example
Aviable in `./example`.


## Building
BrightProof tested on:


| OS | Architecture | Compiler |
|----|--------------|----------|
| Archlinux | x86, x86_64 | DMD 2.070 |
| Archlinux | x86_64 | LDC 0.17.0 |
| Archlinux | x86_64 | GDC 5.3.0 |
|----|--------------|----------|


## TODO
- [ ] Test on different OS (BSD, Windows), architectures (x86, x86_64) with different compilers (DMD, LDC, GDC)

