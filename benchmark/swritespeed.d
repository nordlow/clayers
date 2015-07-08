import std.stdio;
import std.datetime;
import std.file;
import std.math;

/*
This is a write special version of the speed benchmarker.

All this does is printing out the values for 'SCP heavy' and 'liner' in separate files.
*/

struct XY{ size_t x,y; }

void main(){
	version(Windows)
		hOutput = GetStdHandle(handle);

	string os = "unknown";
	int amount = 200;

	version(Windows){
		os = "win";
	}
	version(Posix){
		os = "posix";
	}

	StopWatch s1, s2;
	File file1 = File("output_"~os~"_swritespeed_SCP.txt", "w");
	file1.writeln("SCP heavy");
	File file2 = File("output_"~os~"_swritespeed_liner.txt", "w");
	file2.writeln("liner");

	foreach(a; 0 .. amount){
		
		s1.start();
		foreach(x; 0 .. a){
			scp(XY(x, 0));
			write('1');
		}
		stdout.flush();

		s1.stop();

		s2.start();
		string print;
		foreach(x; 0 .. a){
			print ~= '2';
		}
		scp(XY(0, 1));
		write(print);
		stdout.flush();

		s2.stop();

		file1.writeln(s1.peek());
		file2.writeln(s2.peek());

		s1.reset();
		s2.reset();
	}
}

version(Windows){
	import core.sys.windows.windows;
	import std.algorithm;
	uint handle = STD_ERROR_HANDLE;
	CONSOLE_SCREEN_BUFFER_INFO info;
	HANDLE hOutput;

	void scp(XY pos){
		GetConsoleScreenBufferInfo( hOutput, &info );
		COORD c = {cast(short)min(info.srWindow.Right  - info.srWindow.Left + 1, max(0,pos.x)), cast(short)max(0, pos.y)};
		stdout.flush();
		SetConsoleCursorPosition(hOutput, c);
	}
}else version(Posix){
	void scp(XY pos){
		stdout.flush();
		writef("\033[%d;%df", pos.y + 1, pos.x + 1);
	}
}