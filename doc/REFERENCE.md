## Reference
### class ```ConsoleWindow```

```d
@property size_t width()
```
Returns the width of the window/layer.

---

```d
@property size_t height()
```
Returns the width of the window/layer.

---

```d
dchar getSlot(XY location)
```
Returns the dchar at the specific X and Y coordinates in the window. 

---

```d
void print()
```
Prints all the layers in the correct order.

---

```d
dchar[][] snap()
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
@property bool transparent()
@property bool transparent(bool isTransparent)
```
Is the layer transparent or not?
* **NOTE:** There is no such thing as opacity. Transparency only means that blanks, `' '`, are seethrough.

---

```d
@property bool visible()
@property bool visible(bool isVisible)
```
Is the layer visible or not?

---

```d
override dchar getSlot(XY location)
```
Returns the dchar at specified slot.

---

```d
void layerWrite(XY xy, dchar c)
void layerWrite(XY xy, char c)
void layerWrite(XY xy, string s)
```
Functions like ```std.stdio.write();```, only it writes in the layer. Does wrap around badly, no overflow.

---

```d
void remove()
```
Calls ```removeLayer(this);```.

---

```d
void moveLayerFront()
```
Moves the layer to the front.

---

```d
void moveLayerBack()
```
Moves the layer to the back.

---

```d
void moveLayerForward(size_t amount = 1)
```
Moves the layer forward `amount` amount of times.

---

```d
void moveLayerBackward(size_t amount = 1)
```
Moves the layer backwards `amount` amount of times.
