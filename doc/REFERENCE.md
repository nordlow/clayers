## Reference

### aliases
```d
fg = colorize.fg
bg = colorize.bg
md = colorize.mode
```
See <https://github.com/yamadapc/d-colorize#available-colors-and-modes> for more info about colors.

### struct ```Slot```
```d
dchar character
fg color = fg.init
bg background = bg.init
md mode = md.init
```
Storage for a *character*, text *color*, *background* and *mode*.

* **NOTE:** Not all *mode*s are supported on all platforms.

---

```d
string getCharacter()
```
Returns a fully colorized letter.

### struct ```XY```
```d
size_t x
size_t y
```
Simple two-value storage. Use like this: `XY(10, 4)`.

### class ```ConsoleWindow```

```d
this(XY size = XY(80, 24))
```
Constructor, sets the size of the window.

---

```d
void clayersLog(string s)
```
Logs to file `clayers.log`

---

```d
void setSafePrint(bool sp)
```
Does not print out the bottom right slot. Recommended, necessary for POSIX and causes studdering on Windows.
*Why this function exists is because once the full screen is printed, it moves the cursor down one line. which means that the screen gets pushed up one line, while the program still not. This causes weird rendering and a huge scrollback.*

---

```d
@property size_t width()
@property size_t height()
```
Returns the width/height of the window/layer.

---

```d
Slot getSlot(XY location)
```
Returns the slot at the specific X and Y coordinates in the window. 

---

```d
void print()
```
Prints all the layers in the correct order.

---

```d
Slot[][] snap()
```
Returns a 'snap', snapshot, of all the layers merged.

---

```d
void addLayer(ConsoleLayer cl)
```
Adds a new layer.  
* **DO NOT USE** ```addLayer(new ConsoleLayer(...))```, because there is no way to remove the layer otherwise.

---

```d
void removeLayer(ConsoleLayer cl)
```
Removes a specific layer

---

### class ```ConsoleLayer```, inherits ```ConsoleWindow```

```d
this(XY location, XY size, bool transparent = false)
```
Constructor for the layer. Sets the location and size. Also optional transparancy.

---

```d
@property bool transparent()
@property bool transparent(bool isTransparent)
```
Is the layer transparent or not?
* **NOTE:** There is no such thing as transparency. Transparency only means that blanks, `' '` with default background, are seethrough.

---

```d
@property bool visible()
@property bool visible(bool isVisible)
```
Is the layer visible or not?

---

```d
override Slot getSlot(XY location)
```
Returns the slot at specified location.

---

```d
void write(XY xy, dchar c,  fg color = fg.init, bg background = bg.init, md mode = md.init)
void write(XY xy, string s, fg color = fg.init, bg background = bg.init, md mode = md.init)
```
Writes to the current layer at (xy.x, xy.y). Uses `colorize` for color support.
* **Note:** The modes `bold` and `blink` are known to cause unexpected behaviour.

---

```d
void setSlotColor      (XY xy, fg color)
void setSlotBackground (XY xy, bg background)
void setSlotMode       (XY xy, md mode)
```
Sets the text-color, background-color and mode respectively at specified location.

---

```d
void remove()
```
Deletes the layer.

---

```d
void moveToFront()
```
Moves the layer to the front.

---

```d
void moveToBack()
```
Moves the layer to the back.

---

```d
void moveForward(size_t amount = 1)
```
Moves the layer forward `amount` amount of times.

---

```d
void moveBackward(size_t amount = 1)
```
Moves the layer backwards `amount` amount of times.
