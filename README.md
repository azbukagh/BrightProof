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

## Functions
- *eq* are operands equal?
- *gt* are a > b?
- *ge* are a >= b ?
- *lt* are a < b?
- *le* are a <= b ?

## Example
Aviable in `./example`.
