module BrightProof;

/**
* Are a and b equal?
* Warning: Doesn't compares Identifier and Meta.
* Return: true if equal.
*/
bool eq(SemVer a, SemVer b) {
	return (a.Major == b.Major) &&
		(a.Minor == b.Minor) &&
		(a.Patch == a.Patch);
}
///
unittest {
	assert(eq(SemVer("1.0.0"), SemVer("1.0.0-beta+build"))); //Euyp, they are equal. 
	assert(!eq(SemVer("2.0.0"), SemVer("1.0.0")));
}

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

/**
* Main struct
*/
struct SemVer {
	private {
		size_t SVMajor, SVMinor, SVPatch;
		string SVIdentifier, SVMeta;
	}

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
			SVMajor = to!size_t(i[0..MajorDot]);
		} else {
			throw new Exception("There is a non-number characters in major");
		}
		
		if(i[MajorDot+1..MinorDot].isNumeric) {
			SVMinor = to!size_t(i[MajorDot+1..MinorDot]);
		} else {
			throw new Exception("There is a non-number characters in minor");
		}

		if(IdentifierStart != -1) {
			if(i[MinorDot+1..IdentifierStart].isNumeric) {
				SVPatch = to!size_t(i[MinorDot+1..IdentifierStart]);
			} else {
				throw new Exception("There is a non-number in patch");
			}
			if(MetaStart != -1) {
				SVIdentifier = i[IdentifierStart+1..MetaStart];
				SVMeta = i[MetaStart+1..$];
			} else {
				SVIdentifier = i[IdentifierStart+1..$];
			}
		} else {
			if(MetaStart != -1) {
				if(i[MinorDot+1..MetaStart].isNumeric) {
					SVPatch = to!size_t(i[MinorDot+1..MetaStart]);
				} else {
					throw new Exception("There is a non-number in patch");
				}
				SVMeta = i[MetaStart+1..$];
			} else {
				if(i[MinorDot+1..$].isNumeric) {
					SVPatch = to!size_t(i[MinorDot+1..$]);
				} else {
					throw new Exception("There is a non-number in patch");
				}
			}
		}
	}

	/**
	* Convert SemVer to string
	* Returns: SemVer in string (MAJOR.MINOR.PATCH-IDENTIFIER+META)
	*/
	string toString() {
		import std.format : format;
		string o = format("%d.%d.%d", SVMajor, SVMinor, SVPatch);
		if(SVIdentifier)
			o ~= format("-%s", SVIdentifier);
		if(SVMeta)
			o ~= format("+%s", SVMeta);
		return o;
	}

	/**
	* Get/set properties
	*/
	@property size_t Major() {
		return SVMajor;
	}
	/// ditto
	@property void Major(size_t m) {
		SVMajor = m;
	}
	/// ditto
	@property size_t Minor() {
		return SVMinor;
	}
	/// ditto
	@property void Minor(size_t m) {
		SVMinor = m;
	}
	/// ditto
	@property size_t Patch() {
		return SVPatch;
	}
	/// ditto
	@property void Patch(size_t p) {
		SVPatch = p;
	}
	/// ditto
	@property string Identifier() {
		return SVIdentifier;
	}
	/// ditto
	@property void Identifier(string i) {
		SVIdentifier = i;
	}
	/// ditto
	@property string Meta() {
		return SVMeta;
	}
	/// ditto
	@property void Meta(string m) {
		SVMeta = m;
	}

	bool opEquals()(auto ref const SemVer b) const {
		return (this.SVMajor == b.SVMajor) &&
			(this.SVMinor == b.SVMinor) &&
			(this.SVPatch == b.SVPatch) &&
			(this.SVIdentifier == b.SVIdentifier) &&
			(this.SVMeta == b.SVMeta);
	}

	int opCmp(ref const SemVer b) const {
		if(this.SVMajor != b.SVMajor)
			return this.SVMajor < b.SVMajor ? -1 : 1;
		else if(this.SVMinor != b.SVMinor)
			return this.SVMinor < b.SVMinor ? -1 : 1;
		else if(this.SVMajor != b.SVMajor)
			return this.SVMajor < b.SVMajor ? -1 : 1;

		if(this.SVIdentifier && b.SVIdentifier) {
			return cmpString(this.SVIdentifier, b.SVIdentifier);
		} else if(this.SVIdentifier) {
			return 1;
		} else if(b.SVIdentifier) {
			return -1;
		}

		if(this.SVMeta && b.SVMeta) {
			return cmpString(this.SVMeta, b.SVMeta);
		} else if(this.SVMeta) {
			return 1;
		} else if(b.SVMeta) {
			return -1;
		}

		return 0;
	}

	int opCmp(in SemVer b) const {
		return this.opCmp(b);
	}

	private int cmpString(const string a, const string b) const {
		size_t i;
		while(true) {
			if((a.length == i) && (b.length == i)) {
				return 0;
			} else if(a.length == i) {
				return -1;
			} else if(b.length == i) {
				return 1;
			}

			if(a[i] == b[i]) {
				i++;
			} else {
				return a[i] < b[i] ? -1 : 1;
			}
		}
	}
}
///
unittest {
	SemVer("1.0.0");
	SemVer("1.0.0+4444");
	SemVer("1.0.0-eyyyyup");
	SemVer("1.0.0-yay+build");
}
