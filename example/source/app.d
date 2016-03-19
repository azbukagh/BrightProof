import std.stdio;
import BrightProof;

int main(string[] args) {
	if(args.length < 2)
		return -1;
	SemVer a,b;
	try {
		a = SemVer(args[1]);
		b = SemVer(args[2]);
	} catch (SemVerException e) {
		writeln("Some errors. Check your input and try again");
		writeln(e.toString);
		return -2;
	}

	writeln("Equal?: ", a == b);
	writeln("Greater?: ", a > b);
	writeln("Less?: ", a < b);
	return 0;
}
