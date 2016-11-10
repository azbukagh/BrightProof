/**
* Authors: Azbuka
* License: MIT, see LICENCE.md
* Copyright: Azbuka 2016
* See_Also:
*	Semantic Versioning http://semver.org/
*/
module BrightProof;

import std.traits : isNarrowString;

/**
* Exception for easy error handling
*/
class SemVerException : Exception {
	 /**
	* Params:
	* 	msg = message
	* 	file = file, where SemVerException have been throwed
	* 	line = line number in file
	* 	next = next exception
	*/
	@safe pure nothrow this(string msg,
		string file = __FILE__,
		size_t line = __LINE__,
		Throwable next = null) {
			super(msg, file, line, next);
	}
}

/**
* Main struct
* Examples:
* ---
* SemVer("1.0.0");
* SemVer("1.0.0+4444");
* SemVer("1.0.0-eyyyyup");
* SemVer("1.0.0-yay+build");
* ---
*/
struct SemVer {
	size_t Major, Minor, Patch;
	string PreRelease, Build;

	/**
	* Constructor
	* Params:
	*	i = input string
	* Throws: SemVerException if there is any syntax errors.
	*/
	pure this(T)(T i)
	if(isNarrowString!T){
		import std.string : isNumeric;
		import std.conv : to;

		size_t MajorDot, MinorDot, PreReleaseStart, BuildStart;

		for(size_t count = 0; count < i.length; count++) {
			switch(i[count]) {
				case '.':
					if(!MajorDot) {
						MajorDot = count;
						break;
					}
					if(!MinorDot)
						MinorDot = count;
					break;
				case '-':
					if(!BuildStart && !PreReleaseStart)
						PreReleaseStart = count;
					break;
				case '+':
					BuildStart = count;
					break;
				default: break;
			}
		}

		if(MajorDot == 0) {
			// If first symbol is a dot there is no Major.
			throw new SemVerException("There is no major version number");
		} else if(!MinorDot || (MinorDot - MajorDot < 2)) {
			// If there is nothing between MajorDot and MinorDot.
			throw new SemVerException("There is no minor version number");
		} else if(
			(!PreReleaseStart && (i.length - MinorDot < 2)) ||
			(!PreReleaseStart && (PreReleaseStart - MinorDot < 2))) {
			// There is no Patch if nothing follows MinorDot
			throw new SemVerException("There is no patch version number");
		} else if(
			(!BuildStart && (i.length - PreReleaseStart < 2)) ||
			((BuildStart > 0) && (BuildStart - PreReleaseStart < 2))) {
			// PreRelease is empty if nothing follows`-` .
				throw new SemVerException("There is no prerelease version string");
		} else if(i.length - BuildStart < 2) {
			// Build is empty if nothing follow `+`.
			throw new SemVerException("There is no build version string");
		}

		if(isNumeric(i[0..MajorDot])) {
			if((MajorDot > 1) && (to!size_t(i[0..1]) == 0))
				throw new SemVerException("Major starts with '0'");

			this.Major = to!size_t(i[0..MajorDot]);
		} else {
			throw new SemVerException("There is a non-number character in major");
		}

		if(isNumeric(i[MajorDot+1..MinorDot])) {
			if((MinorDot - MajorDot > 2) && (to!size_t(i[MajorDot+1..MajorDot+2]) == 0))
				throw new SemVerException("Minor starts with '0'");

			this.Minor = to!size_t(i[MajorDot+1..MinorDot]);
		} else {
			throw new SemVerException("There is a non-number character in minor");
		}

		if(PreReleaseStart) {
			if(isNumeric(i[MinorDot+1..PreReleaseStart])) {
				if((PreReleaseStart - MinorDot > 2) && (to!size_t(i[MinorDot+1..MinorDot+2]) == 0))
					throw new SemVerException("Patch starts with '0'");

				this.Patch = to!size_t(i[MinorDot+1..PreReleaseStart]);
			} else {
				throw new SemVerException("There is a non-number character in patch");
			}
			if(BuildStart) {
				this.PreRelease = i[PreReleaseStart+1..BuildStart];
			} else {
				this.PreRelease = i[PreReleaseStart+1..$];
			}
		} else {
			if(BuildStart) {
				if(isNumeric(i[MinorDot+1..BuildStart])) {
					if((BuildStart - MinorDot > 2) && (to!size_t(i[MinorDot+1..MinorDot+2]) == 0))
						throw new SemVerException("Patch starts with '0'");

					this.Patch = to!size_t(i[MinorDot+1..BuildStart]);
				} else {
					throw new SemVerException("There is a non-number character in patch");
				}
				this.Build = i[BuildStart+1..$];
			} else {
				if(isNumeric(i[MinorDot+1..$])) {
					if((i.length - MinorDot > 2) && (to!size_t(i[MinorDot+1..MinorDot+2]) == 0))
						throw new SemVerException("Patch starts with '0'");

					this.Patch = to!size_t(i[MinorDot+1..$]);
				} else {
					throw new SemVerException("There is a non-number character in patch");
				}
			}
		}
	}

	/**
	* Next Major/Minor/Patch version
	* Increments version in semver way
	* Example:
	* 	1.2.3 -> nextMajor -> 2.0.0
	* 	1.2.3 -> nextMinor -> 1.3.0
	* 	1.2.3 -> nextPatch -> 1.2.4
	* 	1.2.3-rc.1+build.5 -> nextPatch -> 1.2.4
	*/
	@safe @nogc pure nothrow SemVer nextMajor() {
		this.Major++;
		this.Minor = this.Patch = 0;
		this.PreRelease = this.Build = "";
		return this;
	}
	/// ditto
	@safe @nogc pure nothrow SemVer nextMinor() {
		this.Minor++;
		this.Patch = 0;
		this.PreRelease = this.Build = "";
		return this;
	}
	/// ditto
	@safe @nogc pure nothrow SemVer nextPatch() {
		this.Patch++;
		this.PreRelease = this.Build = "";
		return this;
	}

	/**
	* Convert SemVer to string
	* Returns: SemVer in string (MAJOR.MINOR.PATCH-PRERELEASE+BUILD)
	*/
	@safe pure string toString() {
		import std.array : appender;
		import std.format : formattedWrite;

		auto writer = appender!string();
		writer.formattedWrite("%d.%d.%d", this.Major, this.Minor, this.Patch);
		if(PreRelease != "")
			writer.formattedWrite("-%s", this.PreRelease);
		if(Build != "")
			writer.formattedWrite("+%s", this.Build);
		return writer.data;
	}

	/**
	* true, if this == b
	*/
	@safe @nogc pure nothrow const bool opEquals()(auto ref const SemVer b) {
		return (this.Major == b.Major) &&
			(this.Minor == b.Minor) &&
			(this.Patch == b.Patch) &&
			(this.PreRelease == b.PreRelease);
	}

	/**
	* Compares two SemVer structs.
	*/
version(Have_natcmp):
	@safe const int opCmp(ref const SemVer b) {
		import natcmp;

		if(this == b)
			return 0;

		if(this.Major != b.Major)
			return this.Major < b.Major ? -1 : 1;
		else if(this.Minor != b.Minor)
			return this.Minor < b.Minor ? -1 : 1;
		else if(this.Major != b.Major)
			return this.Major < b.Major ? -1 : 1;

		if((this.PreRelease != "") && (b.PreRelease != "")) {
			int result = compareNatural(this.PreRelease, b.PreRelease);
			if(result) {
				return result;
			}
		} else if(this.PreRelease != "") {
			return -1;
		} else if(b.PreRelease != "") {
			return 1;
		}

		throw new SemVerException("I don't know, how you got that error: SemVer is not an equal, but also not an different");
	}
	/// ditto
	@safe const int opCmp(in SemVer b) {
		return this.opCmp(b);
	}
	///
	unittest {
		assert(SemVer("1.0.0-alpha") < SemVer("1.0.0-alpha.1"));
		assert(SemVer("1.0.0-alpha.1") < SemVer("1.0.0-alpha.beta"));
		assert(SemVer("1.0.0-alpha.beta") < SemVer("1.0.0-beta"));
		assert(SemVer("1.0.0-beta") < SemVer("1.0.0-beta.2"));
		assert(SemVer("1.0.0-beta.2") < SemVer("1.0.0-beta.11"));
		assert(SemVer("1.0.0-beta.11") < SemVer("1.0.0-rc.1"));
		assert(SemVer("1.0.0-rc.1") < SemVer("1.0.0"));
		assert(SemVer("1.0.0-rc.1") == SemVer("1.0.0+build.9"));
		assert(SemVer("1.0.0-rc.1") == SemVer("1.0.0-rc.1+build.5"));
		assert(SemVer("1.0.0-rc.1+build.5") == SemVer("1.0.0-rc.1+build.5"));
	}
}
