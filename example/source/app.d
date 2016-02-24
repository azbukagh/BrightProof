import std.stdio;
import BrightProof;

int main(string[] args) {
	if(args.length < 2)
		return -1;
	SemVer a,b;
	try {
		a = SemVer(args[1]);
		b = SemVer(args[2]);
	} catch (Exception e) {
		writeln("Some errors. Check your input and try again");
		writeln(e.toString);
		return -2;
	}
	
assert(SemVer("1.0.0-alpha") < SemVer("1.0.0-alpha.1"));
assert(SemVer("1.0.0-alpha.1") < SemVer("1.0.0-alpha.beta"));
assert(SemVer("1.0.0-alpha.beta") < SemVer("1.0.0-beta"));
assert(SemVer("1.0.0-beta") < SemVer("1.0.0-beta.2"));
// assert(SemVer("1.0.0-beta.2") < SemVer("1.0.0-beta.11"));
assert(SemVer("1.0.0-beta.11") < SemVer("1.0.0-rc.1"));
assert(SemVer("1.0.0-rc.1") > SemVer("1.0.0"));
assert(SemVer("1.0.0-rc.1") < SemVer("1.0.0-rc.1+build.5"));
assert(SemVer("1.0.0-rc.1+build.5") == SemVer("1.0.0-rc.1+build.5"));
	writeln("Equal?: ", a == b);
	writeln("Greather?: ", a > b);
	writeln("Less?: ", a < b);
	return 0;
}
