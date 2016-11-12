import std.conv : to;
import std.stdio : writeln;
import BrightProof;

// SemVer can be parsed in compile-time
enum VERSION = SemVer("2.0.7");

void main() {
	// Enum can be used in compile-time
	pragma(msg, "Compiling program...");
	pragma(msg, "Major version: " ~ VERSION.Major.to!string);
	pragma(msg, "Minor version: " ~ VERSION.Minor.to!string);
	pragma(msg, "Patch version: " ~ VERSION.Patch.to!string);

	// And in run-time
	writeln("Running program...");
	writeln("Major version: ", VERSION.Major);
	writeln("Minor version: ", VERSION.Minor);
	writeln("Patch version: ", VERSION.Patch);
}
