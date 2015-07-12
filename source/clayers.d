module clayers;

import std.stdio;
import std.algorithm;
import std.conv;
import std.range;

import colorize;

alias fg = colorize.fg;
alias bg = colorize.bg;
alias md = colorize.mode;

struct XY{size_t x,y;}
struct Slot{
	dchar character;

	//Temporarily while https://github.com/yamadapc/d-colorize/issues/13 still exists.
	version(Windows){
		fg color = fg.white;
		bg background = bg.black;
	}else{
		fg color = fg.init;
		bg background = bg.init;
	}

	md mode = md.init;

	string getCharacter(){
		return colorize.color(to!string(character), color, background, mode);
	}
}


class ConsoleWindow{

	//TODO: Should layers be able to have their own sub-layers, which in turn could have even more sub-layers? I can see some pretty interesting things with this. If not, just change protected to private. ;-)
	protected ConsoleLayer[] layers;
	protected XY size;
	protected Slot[][] slots;
	protected bool[] lineDirty;

	private File log;

	this(XY size){

		systemInit();
		
		this.size = size;
		//lineDirty[0 .. $] = true;
		//Sets the width and height.
		slots = new Slot[][](size.x, size.y);
		//All lines are dirty from the beginning.
		lineDirty = new bool[](size.y);
		lineDirty[] = true;
		//Set every tile to be blank.
		foreach(x; 0 .. size.x) slots[x][0 .. $] = Slot(' ');
		//Print out all the tiles to remove junk characters.
		scp(XY(0, 0));
		foreach(x; 0 .. size.x){
			foreach(y; 0 .. size.y){
				scp(XY(x, y));
				write(' ');
			}
		}
	}

	private void systemInit(){
		//Create a the log file.
		log = File("clayers.log", "w+");

		version(Windows){
			//For windows, creat a handle.
			hOutput = GetStdHandle(handle);
			if(signalHandlerActive)
				SetConsoleCtrlHandler(&CtrlHandler, TRUE);
		}
		version(Posix){
			if(signalHandlerActive)
				signal(2, &handle);

			ioctl(0, TIOCGWINSZ, &w);

			printf ("lines %d\n", w.ws_row);
			printf ("columns %d\n", w.ws_col);
			readln();
		}

		//Sets console/terminal to no-linewrap.
		slw(false);
		//Set the cursor to not be visible.
		scv(false);
	}

	/**
	 * Logging method.
	 */
	void clayersLog(string s){
		log.writeln(s);
	}

	//Functions to operate correctly with console/terminal. All code in here was stolen and modified from 'robik/ConsoleD'.
	private{
		version(Windows){
			import core.sys.windows.windows;
			import std.algorithm;
			uint handle = STD_ERROR_HANDLE;
			CONSOLE_SCREEN_BUFFER_INFO info;
			HANDLE hOutput, hInput;

			/**
			 * Set cursor position
			 */
			void scp(XY pos){
				GetConsoleScreenBufferInfo( hOutput, &info );
				COORD c = {cast(short)min(info.srWindow.Right  - info.srWindow.Left + 1, max(0,pos.x)), cast(short)max(0, pos.y)};
				stdout.flush();
				SetConsoleCursorPosition(hOutput, c);
			}
			/**
			 * Sets the visibility of the cursor
			 */
			void scv(bool visible){
				CONSOLE_CURSOR_INFO cci;
				GetConsoleCursorInfo(hOutput, &cci);
				cci.bVisible = visible;
				SetConsoleCursorInfo(hOutput, &cci);
			}
			/**
			 * Sets line-wrapping on and off
			 */
			void slw(bool lw){
				lw ? SetConsoleMode(hOutput, 0x0002) : SetConsoleMode(hOutput, 0x0);
			}

		}else version(Posix){
			/**
			 * Set cursor position
			 */
			void scp(XY pos){
				stdout.flush();
				writef("\033[%d;%df", pos.y + 1, pos.x + 1);
			}
			/**
			 * Sets the visibility of the cursor
			 */
			void scv(bool visible){
				char c;
				visible ? c = 'h' : c = 'l';
				writef("\033[?25%c", c);
			}
			/**
			 * Sets line-wrapping on and off
			 */
			void slw(bool lw){
				lw ? write("\033[?7h") : write("\033[?7l");
			}
		}
	}

	@property{
		/**
		 * Returns the width of the window/layer.
		 */
		size_t width(){
			return size.x;
		}

		/**
		 * Returns the height of the windows/layer.
		 */
		size_t height(){
			return size.y;
		}
	}

	/**
	 * Returns the slot at the specific X and Y coordinates in the window.
	 */
	Slot getSlot(XY location){
		return snap()[location.x][location.y];
	}

	/**
	 * Prints all the layers in the correct order.
	 */
	void print(bool force = false){
		//Get a snap of what to print out.
		Slot[][] writes = snap();

		string print;
		foreach(y; 0 .. height){
			if(force || lineDirty[y]){
				foreach(x; 0 .. width){
					//Append all characters on one line to 'print'
					print ~= writes[x][y].getCharacter();
				}
				//Set the cursor at the beginning of the line...
				scp(XY(0, y));

				//...and then print it.
				cwrite(print);

				//Reset 'print'.
				print = null;
				lineDirty[y] = false;
			}
		}
		//Flush. Withouth this problems may occur.
		stdout.flush();
	}

	/*
	 * Returns a 'snap', snapshot, of all the layers merged.
	 */
	Slot[][] snap(){
		//Thanks ketmar from #d
		Slot[][] snap = new Slot[][](slots.length, slots[0].length);
		foreach (x, col; snap) col[] = slots[x][];

		//Magic pasta-code which returns a 'snap'.	
		foreach(a; 0 .. layers.length){
			if(layers[a].visible){
				foreach(x; 0 .. layers[a].size.x){
					foreach(y; 0 .. layers[a].size.y){
						if(!layers[a].visible || layers[a].getSlot(XY(x,y)).character == ' ' && layers[a].getSlot(XY(x,y)).background == bg.init && layers[a].getSlot(XY(x,y)).mode != md.swap && layers[a].transparent)
							continue;
						snap[x+layers[a].location.x][y+layers[a].location.y] = layers[a].getSlot(XY(x,y));
					}
				}
			}
		}
		return snap;
	}

	/**
	 * Adds a new layer.
	 * DO NOT USE `addLayer(new ConsoleLayer(...))`, because there is no way to remove the layer otherwise.
	 *
	 * Params:
	 *	 cl = Should be a already defined layer.
	 */
	void addLayer(ConsoleLayer...)(ConsoleLayer consoleLayers){
		foreach(cl; consoleLayers){
			cl.setParent(this);
			layers ~= cl;
		}
	}

	/**
	 * Removes a specific layer
	 *
	 * Params:
	 *	 cl = Layer to be removed.
	 */
	void removeLayer(ConsoleLayer...)(ConsoleLayer consoleLayers){
		foreach(cl; consoleLayers){
			foreach(n; 0 .. layers.length){
				if(cl == layers[n]){
					cl.removeParent();
					layers = remove(layers, n);
					return;
				}
			}
			clayersLog("A layer could not be removed.");
		}
	}

}

class ConsoleLayer : ConsoleWindow{

	private ConsoleWindow parent;
	protected XY location;
	protected bool transparent_ = false;
	protected bool visible_     = true;

	protected void setParent(ConsoleWindow cw){
		parent = cw;
	}
	protected void removeParent(){
		parent = null;
	}

	this(XY topleft, XY bottomright, bool transparent = false, bool visible = true){
		this.location = topleft;
		this.transparent = transparent;
		this.visible = visible;

		super(XY(bottomright.x - topleft.x, bottomright.y - topleft.y));
	}

	@property{
		/**
		 * Is the layer transparent or not?
		 */
		bool transparent(){
			return transparent_;
		}

		bool transparent(bool isTransparent){
			return transparent_ = isTransparent;
		}

		/**
		 * Is the layer visible or not?
		 */
		bool visible(){
			return visible_;
		}

		bool visible(bool isVisible){
			return visible_ = isVisible;
		}
	}

	/*
	 * Returns the slot at specified slot.
	 *
	 * Params:
	 *	 location = X and Y coordinates of the slot to return.
	 */	
	override Slot getSlot(XY location){
		return slots[location.x][location.y];
	}

	void write(XY xy, dchar c, fg color = fg.init, bg background = bg.init, md mode = md.init){
		try{
			slots[xy.x][xy.y] = Slot(c, color, background, mode);
			lineDirty[xy.y] = true;
		}catch{
			clayersLog("Warning: Failed to write " ~ text(c) ~ " at (" ~ text(xy.x) ~ ", " ~ text(xy.y) ~ ")");
		}
	}
	void write(XY xy, string s, fg color = fg.init, bg background = bg.init, md mode = md.init){
		foreach(a; 0 .. s.length){
			write(XY(xy.x + a, xy.y), s[a], color, background, mode);
		}
	}

	/**
	 * Set the text-color at specified location
	 */
	void setSlotColor(XY xy, fg color){
		try{
			slots[xy.x][xy.y].color = color;
			lineDirty[xy.y] = true;
		}catch{
			clayersLog("Warning: Failed to set color " ~ text(color) ~ " at " ~ text(xy.x) ~ ", " ~ text(xy.y) ~ ")");
		}
	}
	/**
	 * Set the background color at specified location
	 */
	void setSlotBackground(XY xy, bg background){
		try{
			slots[xy.x][xy.y].background = background;
			lineDirty[xy.y] = true;
		}catch{
			clayersLog("Warning: Failed to set background " ~ text(background) ~ " at " ~ text(xy.x) ~ ", " ~ text(xy.y) ~ ")");
		}
	}
	/**
	 * Set the mode at specified location
	 */
	void setSlotMode(XY xy, md mode){
		try{
			slots[xy.x][xy.y].mode = mode;
			lineDirty[xy.y] = true;
		}catch{
			clayersLog("Warning: Failed to set mode " ~ text(mode) ~ " at " ~ text(xy.x) ~ ", " ~ text(xy.y) ~ ")");
		}
	}

	/**
	 * Remove the layer.
	 */
	void remove(){
		parent.removeLayer(this);
	}
	/**
	 * Moves the layer to the front.
	 *
	 * Params:
	 *	 cl = Layer to be moved to the front.
	 */
	void moveToFront(){
		moveForward(parent.layers.length);
	}

	/**
	 * Moves the layer to the back.
	 *
	 * Params:
	 *	 cl = Layer to be moved to the back.
	 */
	void moveToBack(){
		moveBackward(parent.layers.length);
	}

	/*
	 * Moves the layer forward `amount` amount of times.
	 *
	 * Params:
	 *	 cl = Layer to be moved. 
	 *	 amount = The amount of times the layer should be moved.
	 */
	void moveForward(size_t amount = 1){
		foreach(c; 0 .. amount){
			foreach(a; 0 .. parent.layers.length){
				if(parent.layers[a] == this && a < parent.layers.length - 1){
					auto t = parent.layers[a + 1];
					parent.layers[a + 1] = parent.layers[a];
					parent.layers[a] = t;
				}
			}
		}
	}

	/*
	 * Moves the layer backwards `amount` amount of times.
	 *
	 * Params:
	 *	 cl = Layer to be moved. 
	 *	 amount = The amount of times the layer should be moved.
	 */
	void moveBackward(size_t amount = 1){
		foreach(c; 0 .. amount){
			foreach(a; 0 .. parent.layers.length){
				if(parent.layers[a] == this && a > 0){
					auto t = parent.layers[a - 1];
					parent.layers[a - 1] = parent.layers[a];
					parent.layers[a] = t;
				}
			}
		}
	}
}

__gshared bool signalHandlerActive = true;
void setSignalHandlerActive(bool active){
	//This code must be run before a ConsoleWindow is created.
	signalHandlerActive = active;
}

//This is some ugly code, but necessary to make sure linewrapping gets reset.
version(Posix){
	import core.stdc.signal;
	import core.sys.posix.sys.ioctl;

	winsize w;

	extern(C) void raise(int sig);
	extern(C) void signal(int sig, void function(int) );
	extern(C) void handle(int sig){
		import core.sys.posix.unistd : STDOUT_FILENO, write;
		//Thank you dav1d, from #d
		enum string rs = "\033[?7h\033[0m";
		core.sys.posix.unistd.write(STDOUT_FILENO, rs.ptr, rs.length);
		stdout.flush();

		signal(sig, SIG_DFL);
		raise(sig);
	}
}
version(Windows){

	//TODO: I have no idea if thise code even works.

	enum WinEvents {CTRL_C_EVENT = 0, CTRL_BREAK_EVENT = 1, CTRL_CLOSE_EVENT = 2, CTRL_LOGOFF_EVENT = 5, CTRL_SHUTDOWN_EVENT = 6}
	import core.sys.windows.windows;

	extern(Windows)
	BOOL CtrlHandler( DWORD signal ) nothrow
	{
		if(signal == WinEvents.CTRL_C_EVENT && signalHandlerActive)
		{
			uint handle = STD_ERROR_HANDLE;
			
			HANDLE hOutput = GetStdHandle(handle);

			SetConsoleMode(hOutput, 0x0002);
			SetConsoleTextAttribute(hOutput, 0);
			signalHandlerActive = false;

			return true;
		}

		return false;
	}
}
