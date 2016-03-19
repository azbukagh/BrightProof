module BrightProof;
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
	* Params:
	*	i = input string
	* Throws: SemVerException if there is any syntax errors.
	*/
	this(string i) {
		import std.string : indexOf, isNumeric;
		import std.conv : to;

		auto MajorDot = indexOf(i, ".", 0);
		auto MinorDot = indexOf(i, ".", MajorDot + 1);
		auto PreReleaseStart = indexOf(i, "-", MinorDot + 1);
		auto BuildStart = indexOf(i, "+", PreReleaseStart + 1);

		if((MajorDot == -1) || (MinorDot == -1)) {
			// If there is no 2 dots - this is not complete semver.
			throw new SemVerException("There is no major, minor or patch");
		} else if(MajorDot < 1) {
			// If first symbol is a dot, there is no Major.
			throw new SemVerException("There is no major version number");
		} else if((MinorDot < 1) || (MinorDot - MajorDot < 2)) {
			// If there is nothing between MajorDot and MinorDot.
			throw new SemVerException("There is no minor version number");
		} else if(
			((PreReleaseStart < 1) && (i.length - MinorDot < 2)) ||
			((PreReleaseStart >= 0) && (PreReleaseStart - MinorDot < 2))) {
			// There is no Patch, if there is nothing after MinorDot.
			// and string end or `-`.
			throw new SemVerException("There is no patch version number");
		} else if(
			((BuildStart < 1) && (i.length - PreReleaseStart < 2)) ||
			((BuildStart >= 0) && (BuildStart - PreReleaseStart < 2))) {
			// There is nothing in PreRelease, if nothing follow `-` .
				throw new SemVerException("There is no prerelease version string");
		} else if(i.length - BuildStart < 2) {
			// There is no in Build, if string ends after `+`.
			throw new SemVerException("There is no build version string");
		}

		// Now we know where Major, Minor, Patch, PreRelease, Build starts and ends.
		if(i[0..MajorDot].isNumeric) {
			Major = to!size_t(i[0..MajorDot]);
		} else {
			throw new SemVerException("There is a non-number characters in major");
		}

		if(i[MajorDot+1..MinorDot].isNumeric) {
			Minor = to!size_t(i[MajorDot+1..MinorDot]);
		} else {
			throw new SemVerException("There is a non-number characters in minor");
		}

		if(PreReleaseStart != -1) {
			if(i[MinorDot+1..PreReleaseStart].isNumeric) {
				Patch = to!size_t(i[MinorDot+1..PreReleaseStart]);
			} else {
				throw new SemVerException("There is a non-number in patch");
			}
			if(BuildStart != -1) {
				PreRelease = i[PreReleaseStart+1..BuildStart];
				Build = i[BuildStart+1..$];
			} else {
				PreRelease = i[PreReleaseStart+1..$];
			}
		} else {
			if(BuildStart != -1) {
				if(i[MinorDot+1..BuildStart].isNumeric) {
					Patch = to!size_t(i[MinorDot+1..BuildStart]);
				} else {
					throw new SemVerException("There is a non-number in patch");
				}
				Build = i[BuildStart+1..$];
			} else {
				if(i[MinorDot+1..$].isNumeric) {
					Patch = to!size_t(i[MinorDot+1..$]);
				} else {
					throw new SemVerException("There is a non-number in patch");
				}
			}
		}
	}

	/**
	* Next Major/Minor/Patch version
	* Increments numbers with semver rules.
	* Example:
	* 	1.2.3 -> nextMajor -> 2.0.0
	* 	1.2.3 -> nextMinor -> 1.3.0
	* 	1.2.3 -> nextPatch -> 1.2.4
	* 	1.2.3-rc.1+build.5 -> nextPatch -> 1.2.4
	*/
	void nextMajor() {
		Major++;
		Minor = Patch = 0;
		PreRelease.length = Build.length = 0;
	}
	/// ditto
	void nextMinor() {
		Minor++;
		Patch = 0;
		PreRelease.length = Build.length = 0;
	}
	/// ditto
	void nextPatch() {
		Patch++;
		PreRelease = Build = "";
	}

	/**
	* Convert SemVer to string
	* Returns: SemVer in string (MAJOR.MINOR.PATCH-IDENTIFIER+META)
	*/
	string toString() {
		import std.format : format;
		string o = format("%d.%d.%d", Major, Minor, Patch);
		if(PreRelease != "")
			o ~= format("-%s", PreRelease);
		if(Build != "")
			o ~= format("+%s", Build);
		return o;
	}

	/**
	* true, if this == b
	*/
	bool opEquals()(auto ref const SemVer b) const {
		return (this.Major == b.Major) &&
			(this.Minor == b.Minor) &&
			(this.Patch == b.Patch) &&
			(this.PreRelease == b.PreRelease) &&
			(this.Build == b.Build);
	}

	/**
	* Compares two SemVer structs.
	*/
	int opCmp(ref const SemVer b) const {
		import natcmp;
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

		if((this.Build != "") && (b.Build != "")) {
			return compareNatural(this.PreRelease, b.PreRelease);
		} else if(this.Build != "") {
			return 1;
		} else if(b.Build != "") {
			return -1;
		}
		return 0;
	}
	/// ditto
	int opCmp(in SemVer b) const {
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
		assert(SemVer("1.0.0-rc.1") < SemVer("1.0.0+build.9"));
		assert(SemVer("1.0.0-rc.1") < SemVer("1.0.0-rc.1+build.5"));
		assert(SemVer("1.0.0-rc.1+build.5") == SemVer("1.0.0-rc.1+build.5"));
	}
}
