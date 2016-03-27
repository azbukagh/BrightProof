import std.stdio;
import BrightProof;

int main(string[] args) {
	if(args.length < 2) {
		usage(args);
		return -1;
	}
	SemVer a,b;
	try {
		a = SemVer(args[1]);
		b = SemVer(args[2]);
	} catch (SemVerException e) {
		writeln("Some errors. Check your input and try again");
		writeln(e.toString);
		return -2;
	}

	string symbol;
	if(a > b)
		symbol = ">";
	else if(a < b)
		symbol = "<";
	else if(a == b)
		symbol = "=";
	else
		symbol = "O RLY?";

	writefln("%s %s %s",
		a.toString,
		symbol,
		b.toString);
	return 0;
}

void usage(string[] args) {
	writefln("Usage:\n" ~
	 "%s <ver1> <ver2>\n" ~
	 "Program just compares versions",
	args[0]);
}
