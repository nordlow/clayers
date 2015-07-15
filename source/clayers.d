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
	fg color = fg.init;
	bg background = bg.init;
	md mode = md.init;

	string getCharacter(){
		return colorize.color(to!string(character), color, background, mode);
	}
}

class ConsoleWindow{
	private File log;
	private bool[] lineDirty;

	private void systemInit(){
		import std.c.stdlib;

		//Create a the log file.
		log = File("clayers.log", "w+");

		version(Windows){
			//For windows, creat a handle.
			hOutput = GetStdHandle(STD_OUTPUT_HANDLE);
			if(signalHandlerActive)
				SetConsoleCtrlHandler(&CtrlHandler, TRUE);
		}
		version(Posix){
			if(signalHandlerActive)
				signal(2, &handle);
		}

		//Sets console/terminal to no-linewrap.
		slw(false);
		//Set the cursor to not be visible.
		scv(false);

		//Set linewrapping on exit.
		atexit(&cleanup);
	}

	//TODO: Should layers be able to have their own sub-layers, which in turn could have even more sub-layers? I can see some pretty interesting things with this. If not, just change protected to private. ;-)
	protected ConsoleLayer[] layers;
	protected XY size;
	protected Slot[][] slots;

	protected void sld(size_t y, bool dirty = true){
		lineDirty[y] = dirty;
	}

	this(XY windowSize = XY()){

		if(windowSize == XY())
			windowSize = gws();
		size = windowSize;

		systemInit();
		
		//Sets the width and height.
		slots = new Slot[][](size.y, size.x);
		//All lines are dirty from the beginning.
		lineDirty = new bool[](size.y);
		lineDirty[] = true;
		//Set every tile to be blank.
		foreach(y; 0 .. size.y) slots[y][0 .. $] = Slot(' ');
		//Print out all the tiles to remove junk characters.
		scp(XY(0, 0));

		foreach(x; 0 .. size.x){
			foreach(y; 0 .. size.y){
				scp(XY(x, y));
				write(' ');
			}
		}
	}

	/**
	 * Logging method.
	 */
	void clayersLog(string s){
		log.writeln(s);
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
					print ~= writes[y][x].getCharacter();
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
		foreach (y, col; snap) col[] = slots[y][];

		//Magic pasta-code which returns a 'snap'.	
		foreach(a; 0 .. layers.length){
			if(layers[a].visible){
				foreach(x; 0 .. layers[a].size.x){
					foreach(y; 0 .. layers[a].size.y){
						if(!layers[a].visible || layers[a].getSlot(XY(x,y)).character == ' ' && layers[a].getSlot(XY(x,y)).background == bg.init && layers[a].getSlot(XY(x,y)).mode != md.swap && layers[a].transparent)
							continue;

						//Temp fix. #13 d-colorize
						version(Windows){
							if(layers[a].getSlot(XY(x,y)).color == fg.init)
								layers[a].setSlotColor(XY(x,y), fg.white);
							if(layers[a].getSlot(XY(x,y)).background == bg.init)
								layers[a].setSlotBackground(XY(x,y), bg.black);
						}

						snap[y+layers[a].location.y][x+layers[a].location.x] = layers[a].getSlot(XY(x,y));
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
	protected bool transparent_ = false, visible_     = true;

	protected override void sld(size_t y, bool dirty = true){
		parent.sld(y + location.y, dirty);
	}
	protected void setParent(ConsoleWindow cw){
		parent = cw;
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
		return slots[location.y][location.x];
	}

	void write(XY xy, dchar c, fg color = fg.init, bg background = bg.init, md mode = md.init){
		try{
			slots[xy.y][xy.x] = Slot(c, color, background, mode);
			sld(xy.y);
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
	void setSlotCharacter(XY xy, dchar character){
		try{
			slots[xy.y][xy.x].character = character;
			sld(xy.y);
		}catch{
			clayersLog("Warning: Failed to set color " ~ text(character) ~ " at " ~ text(xy.x) ~ ", " ~ text(xy.y) ~ ")");
		}
	}
	/**
	 * Set the text-color at specified location
	 */
	void setSlotColor(XY xy, fg color){
		try{
			slots[xy.y][xy.x].color = color;
			sld(xy.y);
		}catch{
			clayersLog("Warning: Failed to set color " ~ text(color) ~ " at " ~ text(xy.x) ~ ", " ~ text(xy.y) ~ ")");
		}
	}
	/**
	 * Set the background color at specified location
	 */
	void setSlotBackground(XY xy, bg background){
		try{
			slots[xy.y][xy.x].background = background;
			sld(xy.y);
		}catch{
			clayersLog("Warning: Failed to set background " ~ text(background) ~ " at " ~ text(xy.x) ~ ", " ~ text(xy.y) ~ ")");
		}
	}
	/**
	 * Set the mode at specified location
	 */
	void setSlotMode(XY xy, md mode){
		try{
			slots[xy.y][xy.x].mode = mode;
			sld(xy.y);
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

//Much code in here was stolen and modified from 'robik/ConsoleD'.
private{
	extern(C){
		int atexit(void function ());
		void cleanup(){
			slw(true);
		}
	}

	version(Windows){
		import core.sys.windows.windows;
		import std.algorithm;

		enum CTRL_C_EVENT = 0;
		CONSOLE_SCREEN_BUFFER_INFO info;
		HANDLE hOutput, hInput;

		extern(Windows) BOOL CtrlHandler( DWORD signal ) nothrow {
			if(signal == CTRL_C_EVENT && signalHandlerActive){
				HANDLE hOutput = GetStdHandle(STD_OUTPUT_HANDLE);

				SetConsoleMode(hOutput, 0x0002);
				SetConsoleTextAttribute(hOutput, 0);
				signalHandlerActive = false;

				return !!!false; // ;)
			}
			return false;
		}

		void scp(XY pos){
			GetConsoleScreenBufferInfo( hOutput, &info );
			COORD c = {cast(short)min(info.srWindow.Right  - info.srWindow.Left + 1, max(0,pos.x)), cast(short)max(0, pos.y)};
			stdout.flush();
			SetConsoleCursorPosition(hOutput, c);
		}
		void scv(bool visible){
			CONSOLE_CURSOR_INFO cci;
			GetConsoleCursorInfo(hOutput, &cci);
			cci.bVisible = visible;
			SetConsoleCursorInfo(hOutput, &cci);
		}
		void slw(bool lw){
			lw ? SetConsoleMode(hOutput, 0x0002) : SetConsoleMode(hOutput, 0x0);
		}

		XY gws(){
			hOutput = GetStdHandle(STD_OUTPUT_HANDLE);
			GetConsoleScreenBufferInfo( hOutput, &info );
			
			int cols, rows;
			
			cols = (info.srWindow.Right  - info.srWindow.Left + 1);
			rows = (info.srWindow.Bottom - info.srWindow.Top  + 1);

			return XY(cols, rows);
		}
	}

	version(Posix){
		import core.stdc.signal;
		import core.sys.posix.sys.ioctl;
		import core.sys.posix.unistd : STDOUT_FILENO;

		extern(C) void raise(int sig);
		extern(C) void signal(int sig, void function(int) );
		extern(C) void handle(int sig){
			import core.sys.posix.unistd : write;
			//Thank you dav1d, from #d
			enum string rs = "\033[?7h \033[0m";
			core.sys.posix.unistd.write(STDOUT_FILENO, rs.ptr, rs.length);
			stdout.flush();

			signal(sig, SIG_DFL);
			raise(sig);
		}

		void scp(XY pos){
			stdout.flush();
			writef("\033[%d;%df", pos.y + 1, pos.x + 1);
		}
		void scv(bool visible){
			char c;
			visible ? c = 'h' : c = 'l';
			writef("\033[?25%c", c);
		}
		void slw(bool lw){
			lw ? write("\033[?7h") : write("\033[?7l");
		}

		XY gws(){
			winsize w;
			ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);

			return XY(w.ws_col, w.ws_row);
		}
	}

	version(OSX){
		enum TIOCGWINSZ = 0x40087468;
	}
}

