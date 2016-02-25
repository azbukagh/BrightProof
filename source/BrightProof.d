module BrightProof;

/**
* Are a and b equal?
* Warning: Doesn't compares Identifier and Meta.
* Return: true if equal.
*/
deprecated("Use a == b or a != b. This function must be deleted in 1.0.0") {
	bool eq(SemVer a, SemVer b) {
		return (a.Major == b.Major) &&
			(a.Minor == b.Minor) &&
			(a.Patch == b.Patch);
	}
	///
	unittest {
		assert(eq(SemVer("1.0.0"), SemVer("1.0.0-beta+build"))); //Euyp, they are equal. 
		assert(!eq(SemVer("2.0.0"), SemVer("1.0.0")));
	}
}
deprecated("Use a < b, a > b, a >= b, a <= b. This function must be deleted in 1.0.0") {
	/**
	* Are a greater than b?
	* Warning: Doesn't compares Identifier and Meta.
	* Return: true if greater.
	*/
	bool gt(SemVer a, SemVer b) {
		if(a.Major > b.Major) {
			return true;
		} else if(a.Major == b.Major) {
			if(a.Minor > b.Minor) {
				return true;
			} else if(a.Minor == b.Minor) {
				if(a.Patch > b.Patch) {
					return true;
				} else {
					return false;
				}
			} else {
				return false;
			}
		} else {
			return false;
		}
	}
	///
	unittest {
		assert(!gt(SemVer("1.0.0"), SemVer("1.0.0-beta+build")));
		assert(gt(SemVer("2.0.0"), SemVer("1.0.0")));
	}

	/**
	* Are a greater than or equal to b?
	* Warning: Doesn't compares Identifier and Meta.
	* Return: true if greater or equal.
	*/
	bool ge(SemVer a, SemVer b) {
		return eq(a, b) || gt(a, b);
	}
	///
	unittest {
		assert(ge(SemVer("1.0.0"), SemVer("1.0.0-beta+build")));
		assert(ge(SemVer("2.0.0"), SemVer("1.0.0")));
	}

	/**
	* Are a less than b?
	* Warning: Doesn't compares Identifier and Meta.
	* Return: true if less.
	*/
	bool lt(SemVer a, SemVer b) {
		if(a.Major < b.Major) {
			return true;
		} else if(a.Major == b.Major) {
			if(a.Minor < b.Minor) {
				return true;
			} else if(a.Minor == b.Minor) {
				if(a.Patch < b.Patch) {
					return true;
				} else {
					return false;
				}
			} else {
				return false;
			}
		} else {
			return false;
		}
	}
	unittest {
		assert(!lt(SemVer("1.0.0"), SemVer("1.0.0-beta+build")));
		assert(!lt(SemVer("2.0.0"), SemVer("1.0.0")));
	}

	/**
	* Are a less than or equal to b?
	* Warning: Doesn't compares Identifier and Meta.
	* Return: true if less or equal.
	*/
	bool le(SemVer a, SemVer b) {
		return eq(a, b) || lt(a, b);
	}
	///
	unittest {
		assert(le(SemVer("1.0.0"), SemVer("1.0.0-beta+build")));
		assert(!le(SemVer("2.0.0"), SemVer("1.0.0")));
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
	string Identifier, Meta;

	/**
	* Params:
	*	i = input string
	* Throws: Exception if there is any syntax errors.
	*/
	this(string i) {
		import std.string : indexOf, isNumeric;
		import std.conv : to;

		auto MajorDot = indexOf(i, ".", 0);
		auto MinorDot = indexOf(i, ".", MajorDot + 1);
		auto IdentifierStart = indexOf(i, "-", MinorDot + 1);
		auto MetaStart = indexOf(i, "+", IdentifierStart + 1);

		if((MajorDot == -1) || (MinorDot == -1)) {
			throw new Exception("There is no major, minor or patch");
		} else if(MajorDot < 1) {
			throw new Exception("There is no major version number");
		} else if((MinorDot < 1) || (MinorDot - MajorDot < 2)) {
			throw new Exception("There is no minor version number");
		} else if(
			((IdentifierStart < 1) && (i.length - MinorDot < 2)) ||
			((IdentifierStart >= 0) && (IdentifierStart - MinorDot < 2))) {
			throw new Exception("There is no patch version number");
		} else if(
			((MetaStart < 1) && (i.length - IdentifierStart < 2)) ||
			((MetaStart >= 0) && (MetaStart - IdentifierStart < 2))) {
				throw new Exception("There is no identifier version string");
		} else if(i.length - MetaStart < 2) {
			throw new Exception("There is no meta version string");
		}

		if(i[0..MajorDot].isNumeric) {
			Major = to!size_t(i[0..MajorDot]);
		} else {
			throw new Exception("There is a non-number characters in major");
		}
		
		if(i[MajorDot+1..MinorDot].isNumeric) {
			Minor = to!size_t(i[MajorDot+1..MinorDot]);
		} else {
			throw new Exception("There is a non-number characters in minor");
		}

		if(IdentifierStart != -1) {
			if(i[MinorDot+1..IdentifierStart].isNumeric) {
				Patch = to!size_t(i[MinorDot+1..IdentifierStart]);
			} else {
				throw new Exception("There is a non-number in patch");
			}
			if(MetaStart != -1) {
				Identifier = i[IdentifierStart+1..MetaStart];
				Meta = i[MetaStart+1..$];
			} else {
				Identifier = i[IdentifierStart+1..$];
			}
		} else {
			if(MetaStart != -1) {
				if(i[MinorDot+1..MetaStart].isNumeric) {
					Patch = to!size_t(i[MinorDot+1..MetaStart]);
				} else {
					throw new Exception("There is a non-number in patch");
				}
				Meta = i[MetaStart+1..$];
			} else {
				if(i[MinorDot+1..$].isNumeric) {
					Patch = to!size_t(i[MinorDot+1..$]);
				} else {
					throw new Exception("There is a non-number in patch");
				}
			}
		}
	}

	void nextMajor() {
		Major++;
		Minor = Patch = 0;
		Identifier.length = Meta.length = 0;
	}

	void nextMinor() {
		Minor++;
		Patch = 0;
		Identifier.length = Meta.length = 0;
	}

	void nextPatch() {
		Patch++;
		Identifier = Meta = "";
	}

	/**
	* Convert SemVer to string
	* Returns: SemVer in string (MAJOR.MINOR.PATCH-IDENTIFIER+META)
	*/
	string toString() {
		import std.format : format;
		string o = format("%d.%d.%d", Major, Minor, Patch);
		if(Identifier != "")
			o ~= format("-%s", Identifier);
		if(Meta != "")
			o ~= format("+%s", Meta);
		return o;
	}

	/**
	* true, if this == b
	*/
	bool opEquals()(auto ref const SemVer b) const {
		return (this.Major == b.Major) &&
			(this.Minor == b.Minor) &&
			(this.Patch == b.Patch) &&
			(this.Identifier == b.Identifier) &&
			(this.Meta == b.Meta);
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

		if((this.Identifier != "") && (b.Identifier != "")) {
			int result = compareNatural(this.Identifier, b.Identifier);
			if(result) {
				return result;
			}
		} else if(this.Identifier != "") {
			return -1;
		} else if(b.Identifier != "") {
			return 1;
		}

		if((this.Meta != "") && (b.Meta != "")) {
			return compareNatural(this.Identifier, b.Identifier);
		} else if(this.Meta != "") {
			return 1;
		} else if(b.Meta != "") {
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
