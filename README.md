BrightProof
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
Also, Identifiers and Metas now compared too:
```
SemVer("1.0.0-rc.1") < SemVer("1.0.0-rc.20");
SemVer("1.0.0-rc.1") < SemVer("1.0.0");
SemVer("1.0.0-rc.1") < SemVer("1.0.0+build.1");
```

## Example
Aviable in `./example`.

## TODO
- [ ] Change Identifier -> PreRelease and Meta -> Build in 1.0.0.
