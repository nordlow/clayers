import std.stdio;
import std.datetime;
import std.file;

struct XY{ size_t x,y; }

void main(){
    StopWatch s1, s2;

    int scpheavy, liner;
    File file = File("writespeed_output", "w");

    file.write("SCP = set cursor position\nliner = append to string, then write\n");
    version(Windows){
        file.write("Testing on Windows\n");
    }
    version(Posix){
        file.write("Testing on Linux\n");
    }

    foreach(a; 0 .. 200){
        s1.start();

        foreach(x; 0 .. a){
            scp(XY(x, 0));
            write('1');
        }

        s1.stop();

        s2.start();

        string print;
        foreach(x; 0 .. a){
            print ~= '2';
            scp(XY(0, 1));
            write(print);
        }

        s2.stop();

        bool f = s1.peek() < s2.peek();
        f ? ++scpheavy : ++liner;
        file.write("For ", a, " slots, ", f ? "SCP heavy" : "liner", " is faster\n");

        s1.reset();
        s2.reset();
    }

    file.write("\nSCP was faster ", scpheavy, " times\nliner was faster ", liner, " times\n\n", scpheavy > liner ? "SCP heavy" : "liner", " is the fastest for ");
    version(Windows){
        file.write("Windows\n");
    }
    version(Posix){
        file.write("Linux\n");
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
