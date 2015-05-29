import std.stdio;
import clayers;

void main(){
	int maxw = 80, maxh = 25;
	int separatorline = 55;

	ConsoleWindow win = new ConsoleWindow(XY(maxw, maxh));

	ConsoleLayer a = new ConsoleLayer(XY(0, 0), XY(separatorline, maxh), ' ', '+');
	ConsoleLayer a2 = new ConsoleLayer(XY(separatorline, 0), XY(maxw - separatorline, maxh), ' ', '*');

	win.addLayer(a);
	win.addLayer(a2);
	win.print();

	readln();
}