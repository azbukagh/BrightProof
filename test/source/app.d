import std.stdio;
import BrightProof;
import std.datetime : benchmark;
import std.conv : to;
import core.time : Duration;
import core.exception : AssertError;

struct Result {
	string TestName;
	Duration Time;
	bool Failed;
	AssertError AError;
	SemVerException SError;
}

bool testFail = false;
AssertError assertError = null;
SemVerException semVerError = null;

Result[] runTests(FUN...)() {
	Result[] o;
	foreach(f; FUN) {
		o ~= Result(
			__traits(identifier, f),
			to!Duration(benchmark!(f)(1)[0]),
			testFail,
			assertError,
			semVerError
		);
		testFail = false;
		assertError = null;
		semVerError = null;
	}
	return o;
}

int main() {
	Result[] results = runTests!(
		cmpTest,
		validationTest,
		buildTest,
		largeValuesTest,
		unicodeValuesTest,
		unicodeCmpTest)();

	foreach(r; results)
		writefln(
			"%s\t%s\tin %s",
			r.TestName,
			r.Failed ? "FAILED" : "OK",
			r.Time
		);

	bool anyFailed = false;
	foreach(r; results) {
		if(r.AError)
			writeln(r.AError);
		if(r.SError)
			writeln(r.SError);
		if(r.Failed)
			anyFailed = true;
	}
	return anyFailed ? -1 : 0;
}

void cmpTest() {
	try {
		assert(SemVer!string("1.0.0-alpha") < SemVer!string("1.0.0-alpha.1"));
		assert(SemVer!string("1.0.0-alpha.1") < SemVer!string("1.0.0-alpha.beta"));
		assert(SemVer!string("1.0.0-alpha.beta") < SemVer!string("1.0.0-beta"));
		assert(SemVer!string("1.0.0-beta") < SemVer!string("1.0.0-beta.2"));
		assert(SemVer!string("1.0.0-beta.2") < SemVer!string("1.0.0-beta.11"));
		assert(SemVer!string("1.0.0-beta.11") < SemVer!string("1.0.0-rc.1"));
		assert(SemVer!string("1.0.0-rc.1") < SemVer!string("1.0.0"));
		assert(SemVer!string("1.0.0-rc.1") < SemVer!string("1.0.0+build.9"));
		assert(SemVer!string("1.0.0-rc.1") == SemVer!string("1.0.0-rc.1+build.5"));
		assert(SemVer!string("1.0.0-rc.1+build.5") == SemVer!string("1.0.0-rc.1+build.5"));

		assert(SemVer!string("1.0.0-alpha.1") > SemVer!string("1.0.0-alpha"));
		assert(SemVer!string("1.0.0-alpha.beta") > SemVer!string("1.0.0-alpha.1"));
		assert(SemVer!string("1.0.0-beta") > SemVer!string("1.0.0-alpha"));
		assert(SemVer!string("1.0.0-beta.2") > SemVer!string("1.0.0-beta"));
		assert(SemVer!string("1.0.0-beta.11") > SemVer!string("1.0.0-beta.2"));
		assert(SemVer!string("1.0.0-rc.1") > SemVer!string("1.0.0-beta.11"));
		assert(SemVer!string("1.0.0") > SemVer!string("1.0.0-rc.42"));
		assert(SemVer!string("1.0.0+build.34") > SemVer!string("1.0.0-rc.42"));
		assert(SemVer!string("1.0.0-rc.1+build.34") == SemVer!string("1.0.0-rc.1"));
	} catch (AssertError a) {
		assertError = a;
		testFail = true;
	} catch (SemVerException e) {
		semVerError = e;
		testFail = true;
	}
}

void validationTest() {
	try {
		SemVer!string("1.0.0");
		SemVer!string("1.0.0+4444");
		SemVer!string("1.0.0-eyyyyup");
		SemVer!string("1.0.0-yay+build");
	} catch (SemVerException e) {
		semVerError = e;
		testFail = true;
	}
}

void buildTest() {
	try {
		auto s = SemVer!string("34.42.69+build.4");
		s.nextMinor;
		s.nextPatch;
		s.nextMajor;
		s.nextMinor;
		s.nextMinor;
		assert(s.toString == "35.2.0");
	} catch (AssertError a) {
		assertError = a;
		testFail = true;
	} catch (SemVerException e) {
		semVerError = e;
		testFail = true;
	}
}

void largeValuesTest() {
	try {
		SemVer!string(to!string(size_t.max) ~
			"." ~ to!string(size_t.max) ~
			"." ~ to!string(size_t.max)
		);
	} catch (SemVerException e) {
		semVerError = e;
		testFail = true;
	}
}

void unicodeValuesTest() {
	try {
		SemVer!dstring("1.0.0-α.1");
	} catch (SemVerException e) {
		semVerError = e;
		testFail = true;
	}
}

void unicodeCmpTest() {
	try {
		assert(SemVer!dstring("1.0.0-α") < SemVer!dstring("1.0.0-α.1"));
		assert(SemVer!dstring("1.0.0-α.1") < SemVer!dstring("1.0.0-α.β"));
		//assert(SemVer!dstring("1.0.0-α.β") < SemVer!dstring("1.0.0-β"));
		//assert(SemVer!dstring("1.0.0-β") < SemVer!dstring("1.0.0-β.2"));
		assert(SemVer!dstring("1.0.0-β.2") < SemVer!dstring("1.0.0-β.11"));
	} catch (AssertError a) {
		assertError = a;
		testFail = true;
	} catch (SemVerException e) {
		semVerError = e;
		testFail = true;
	}
}
