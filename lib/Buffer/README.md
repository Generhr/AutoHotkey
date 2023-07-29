# Buffer

Methods to generate specific structures using the native Buffer object for AutoHotkey v2.*

## Functions

#### `BufferFromArray(array[, type])`
Create a buffer instance and append each value in an array to it.

##### Parameters
1. [Array] array: The result value computed. Objects by themselves are automatically converted to string.
2. [String] type: Data type to use when inserting a given value. Defaults to `"UInt"`.

##### Return
[Buffer]: A new buffer instance with a `.Ptr` property.

#### `BufferFromBuffer(structs*)`
Create a buffer instance and copies the data from each struct passed into it.

##### Parameters
1. [Buffer] structs*: Any number of structures to concatenate into a new buffer instance. The memory will be a copy, not shared.

##### Return
[Buffer]: A new buffer instance with a `.Ptr` property.

## Instance methods

#### `struct.NumGet(offset, type[, bytes])`
Retrieve a value from this struct at the given offset.

##### Arguments
1. [Integer] offset: The offset at which to start retrieving the data.
2. [String] type: The data type to retrieve.
3. [Integer] bytes: The number of bytes to copy into a structure. This only applies if `type` is `"Buffer"`.

##### Return
[*]: Returns the data at the specified address or if `type` is `"Struct"`, a new instance with `bytes` of data copied into it.

##### Example
```autohotkey
struct := Buffer(8)
struct.NumPut(0, "UShort", 1, "Float", 2)

MsgBox(struct.NumGet(2, "Float"))  ; Retrieve the Float (4 bytes) at offset 2 (the first byte after the UShort entry).
```

#### `struct.NumPut(offset, type, value, type, value, ...)`
Retrieve a value from this struct at the given offset.

##### Arguments
1. [Integer] offset: The offset at which to start inserting data.
2. [String] type: The data type to inserting.
3. [Any] value: `value` is inserted at `offset` and any additional `value` parameters are inserted at `offset` + the number of bytes taken up by preceding entries.

##### Return
[Integer]: The next available byte in address space after all values have been inserted.

##### Example
```autohotkey
struct := Buffer(8)
struct.NumPut(0, "UShort", 1, "Float", 2)

MsgBox(struct.NumGet(2, "Float"))  ; Retrieve the Float (4 bytes) at offset 2 (the first byte after the UShort entry).
```
