import std.stdio;
import BrightProof;
import std.datetime : benchmark;
import std.conv : to;
import core.time : Duration;
import core.exception : AssertError;

void main() {
	auto r = benchmark!(cmpTest, validationTest, buildTest)(1);
	writeln("cmpTest(): ", to!Duration(r[0]));
	writeln("validationTest(): ", to!Duration(r[1]));
	writeln("buildTest(): ", to!Duration(r[2]));
}

void cmpTest() {
	try {
		assert(SemVer("1.0.0-alpha") < SemVer("1.0.0-alpha.1"));
		assert(SemVer("1.0.0-alpha.1") < SemVer("1.0.0-alpha.beta"));
		assert(SemVer("1.0.0-alpha.beta") < SemVer("1.0.0-beta"));
		assert(SemVer("1.0.0-beta") < SemVer("1.0.0-beta.2"));
		assert(SemVer("1.0.0-beta.2") < SemVer("1.0.0-beta.11"));
		assert(SemVer("1.0.0-beta.11") < SemVer("1.0.0-rc.1"));
		assert(SemVer("1.0.0-rc.1") < SemVer("1.0.0"));
		assert(SemVer("1.0.0-rc.1") < SemVer("1.0.0+build.9"));
		assert(SemVer("1.0.0-rc.1") < SemVer("1.0.0-rc.1+build.5"));
		assert(SemVer("1.0.0-rc.1+build.5") == SemVer("1.0.0-rc.1+build.5"));

		assert(SemVer("1.0.0-alpha.1") > SemVer("1.0.0-alpha"));
		assert(SemVer("1.0.0-alpha.beta") > SemVer("1.0.0-alpha.1"));
		assert(SemVer("1.0.0-beta") > SemVer("1.0.0-alpha"));
		assert(SemVer("1.0.0-beta.2") > SemVer("1.0.0-beta"));
		assert(SemVer("1.0.0-beta.11") > SemVer("1.0.0-beta.2"));
		assert(SemVer("1.0.0-rc.1") > SemVer("1.0.0-beta.11"));
		assert(SemVer("1.0.0") > SemVer("1.0.0-rc.42"));
		assert(SemVer("1.0.0+build.34") > SemVer("1.0.0-rc.42"));
		assert(SemVer("1.0.0-rc.1+build.34") > SemVer("1.0.0-rc.1"));
	} catch (AssertError a) {
		error(a, __FUNCTION__);
	}
}

void validationTest() {
	try {
		SemVer("1.0.0");
		SemVer("1.0.0+4444");
		SemVer("1.0.0-eyyyyup");
		SemVer("1.0.0-yay+build");
	} catch (Exception e) {
		error(e, __FUNCTION__);
	}
}

void buildTest() {
	try {
		SemVer s = SemVer("34.42.69+build.4");
		s.nextMinor;
		s.nextPatch;
		s.nextMajor;
		s.nextMinor;
		s.nextMinor;
		assert(s.toString == "35.2.0");
	} catch (Exception e) {
		error(e, __FUNCTION__);
	} catch (AssertError a) {
		error(a, __FUNCTION__);
	}
}

void error(T)(T a, string f = __FUNCTION__) {
	writefln("Error in %s", f);
	writeln(a.toString);
}
