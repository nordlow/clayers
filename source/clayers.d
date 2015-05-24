module clayers;

import consoled : setCursorPos;
import std.stdio;
import std.algorithm;
import std.datetime;

struct XY{int x,y;}

class ConsoleWindow{
	
	ConsoleLayer[] layers;
	XY size;
	
	protected char[][] slots;
	
	this(XY size = XY(80, 24), char fill = ' '){
		this.size = size;
		
		//Sets the width and height
		slots.length = size.x; foreach(int y; 0 .. size.x) slots[y].length = size.y;
		
		//Set every tile to be the "filling"
		foreach(x; 0 .. size.x) slots[x][0 .. $] = fill;
	}
	
	char getSlot(XY location){
		return snap()[location.x][location.y];
	}
	
	void addLayer(ConsoleLayer cl){
		layers ~= cl;
	}
	
	void print(){
		char[][] writes = snap();

		string print;
		foreach(int y; 0 .. size.y){
			foreach(int x; 0 .. size.x)
				print ~= writes[x][y];
			setCursorPos(0, y);
			write(print);
			print = null;
		}
		
		/+ The version below is about ~15 times faster, but unreliable.
		 + 
		 + For instance, once a whole 80 character line has been
		 + printed the console wraps around and begins on a new
		 + line. And then the command to send a newline happens
		 + which causes empty lines to appear.
		
		string print2;
		foreach(int y; 0 .. size.y){
			foreach(int x; 0 .. size.x)
				print2 ~= writes[x][y];
			print2 ~= "\n";
		}
		setCursorPos(0, 0);
		write(print2);
		+/
	}
	
	char[][] snap(){
		char[][] snap;
		snap.length = size.x; foreach(int y; 0 .. size.x) snap[y].length = size.y;
		foreach(x; 0 .. size.x) snap[x][0 .. $] = ' ';

		foreach(a; 0 .. layers.length)
		foreach(x; 0 .. layers[a].size.x)
		foreach(y; 0 .. layers[a].size.y)
			snap[x + layers[a].location.x][y + layers[a].location.y] = layers[a].slots[x][y];
		
		return snap;
	}

	void removeLayer(ConsoleLayer cl){
		foreach(n; 0 .. layers.length){
			if(cl == layers[n]){
				layers = remove(layers, n);
				break;
			}
		}
	}
}

class ConsoleLayer : ConsoleWindow{
	string id;
	XY location;
	this(XY size, XY location, char fill = '*'){
		this.id = id;
		this.location = location;
		super(size, fill);
	}
	
	char getLayerSlot(XY location){
		return slots[location.x][location.y];
	}
	
	void setLayerSlot(XY location, char a){
		slots[location.x][location.y] = a;
	}
}
