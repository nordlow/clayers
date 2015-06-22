import std.stdio;
import std.datetime;
import std.file;
import std.math;

struct XY{ size_t x,y; }

void main(){
    
    string os = "unknown";
    int amount = 200;

    version(Windows){
        os = "Windows";
    }
    version(Posix){
        os = "Posix";
    }

    StopWatch s1, s2;
    File file = File("writespeed_output", "w");

    file.write("Testing on ", os, "\n");

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
            scp(XY(0, 1));
            write(print);
        }
        stdout.flush();
        s2.stop();

        bool f = s1.peek() < s2.peek();
        file.write("(", os, ") For ", a, " slots,\t", f ? "SCP heavy" : "liner    ", " is ", abs(s1.peek().msecs - s2.peek().msecs),  "\tmsecs faster, ", abs(s1.peek - s2.peek()), "\n");

        s1.reset();
        s2.reset();
    }
}

version(Windows){
    import core.sys.windows.windows;
    CONSOLE_SCREEN_BUFFER_INFO info;
    HANDLE handleOut = null;
}

void scp(XY pos){
    version(Windows){
        COORD c = {cast(short)min(width,max(0,pos.x)), cast(short)max(0,pos.y)};
        stdout.flush();
        SetConsoleCursorPosition(handleOut, c);
    }else version(Posix){
        stdout.flush();
        writef("\033[%d;%df", pos.y + 1, pos.x + 1);
    }
    //All code in this function is stolen from setCursorPos() from ConsoleD.
}
