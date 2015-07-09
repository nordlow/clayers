import std.stdio;
import std.datetime;
import std.file;
import std.math;

/*
This is a different flavour of the original write speed benchmarker.

The purpose of this program is to rapidly print out a 80x24 window ten times, and measure the time to do so.
*/

struct XY{ size_t x,y; }

void main(){
	version(Windows)
		hOutput = GetStdHandle(handle);

    string os = "unknown";
    int amount = 10;

    version(Windows){
        os = "win";
    }
    version(Posix){
        os = "posix";
    }

    StopWatch s1, s2;
    File file = File("output_"~os~"_w2itespeed.txt", "w");

    file.write("Testing on ", os, "\n");

    foreach(a; 0 .. amount){
        
        s1.start();
		
		foreach(y; 0 .. 24)
        foreach(x; 0 .. 80){
            scp(XY(x, y));
            write('1');
        }
        stdout.flush();

        s1.stop();

        s2.start();
		
		string print;
		foreach(y; 0 .. 24){
			foreach(x; 0 .. 80){
				print ~= '2';
			}
			scp(XY(0, y));
			write(print);
			print = null;
		}

        stdout.flush();

        s2.stop();

        file.write("(", os, ") ", a, " slots:\n\t\t\tSCP heavy: ", s1.peek(), "(", s1.peek().msecs, "msecs)", "\n\t\t\tliner:     ", s2.peek(), "(", s2.peek().msecs, "msecs)", "\n");

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
