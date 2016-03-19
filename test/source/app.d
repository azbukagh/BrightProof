import std.stdio;
import BrightProof;
import std.datetime : benchmark;
import std.conv : to;
import core.time : Duration;
import core.exception : AssertError;

bool anyErrors = false;
AssertError[] assertError;
SemVerException[] semVerError;

void main() {
	write("cmpTest()... ");
	auto cmpTestR = benchmark!(cmpTest)(1);
	writefln("%s in %s", anyErrors ? "FAIL" : "OK", to!Duration(cmpTestR[0]));
	anyErrors = false;

	write("validationTest()... ");
	auto validationTestR = benchmark!(validationTest)(1);
	writefln("%s in %s", anyErrors ? "FAIL" : "OK", to!Duration(validationTestR[0]));
	anyErrors = false;

	write("buildTest()... ");
	auto buildTestR = benchmark!(buildTest)(1);
	writefln("%s in %s", anyErrors ? "FAIL" : "OK", to!Duration(buildTestR[0]));
	anyErrors = false;

	if(assertError)
		foreach(AssertError a; assertError)
			writeln(a.toString);
	if(semVerError)
		foreach(SemVerException e; semVerError)
			writeln(e.toString);

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
		assertError ~= a;
		anyErrors = true;
	} catch (SemVerException e) {
		semVerError ~= e;
		anyErrors = true;
	}
}

void validationTest() {
	try {
		SemVer("1.0.0");
		SemVer("1.0.0+4444");
		SemVer("1.0.0-eyyyyup");
		SemVer("1.0.0-yay+build");
	} catch (SemVerException e) {
		semVerError ~= e;
		anyErrors = true;
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
	} catch (AssertError a) {
		assertError ~= a;
		anyErrors = true;
	} catch (SemVerException e) {
		semVerError ~= e;
		anyErrors = true;
	}
}
