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
    File file = File("output_writespeed_" ~ os, "w");

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

        file.write("(", os, ") ", a, " slots:\n\t\t\tSCP heavy: ", s1.peek(), "\n\t\t\tliner:     ", s2.peek(), "\n");

        s1.reset();
        s2.reset();
    }
}

version(Windows){
    import core.sys.windows.windows;
    import std.algorithm;
    CONSOLE_SCREEN_BUFFER_INFO info;
    HANDLE hOutput = GetStdHandle(handle);
}

void scp(XY pos){
    version(Windows){
        COORD c = {cast(short)min(80 /* TEMP */ ,max(0,pos.x)), cast(short)max(0,pos.y)};
        stdout.flush();
        SetConsoleCursorPosition(hOutput, c);
    }else version(Posix){
        stdout.flush();
        writef("\033[%d;%df", pos.y + 1, pos.x + 1);
    }
    //All code in this function is stolen from setCursorPos() from ConsoleD.
}
