// Written in the D programming language.

/++
High-level allocation routines for Slices

Copyright: Copyright (c) 2021 John Kilpatrick

License: MIT

Authors: John Kilpatrick
+/
module numd.allocation;

private {
	import std.stdio;
	import mir.ndslice;
	import mir.complex;
	import mir.ndslice.topology : map;

	alias defaultType = float;

	import std.traits : Unqual;
}

enum isInteger(T) = is(Unqual!T == short) || is(Unqual!T == ushort)
	|| is(Unqual!T == int) || is(Unqual!T == uint) || is(Unqual!T == long) || is(Unqual!T == ulong);

enum isFloatingPoint(T) = is(Unqual!T == float) || is(Unqual!T == double) || is(Unqual!T == real); // || is(Unqual!T == cent) || is(Unqual!T == ucent);

enum isContinuous(T) = isComplex!(Unqual!T) || isFloatingPoint!(Unqual!T);

enum isNumeric(T) = isInteger!(Unqual!T) || isFloatingPoint!(Unqual!T) || isComplex!(Unqual!T);

enum isReal(T) = isInteger!(Unqual!T) || isFloatingPoint!(Unqual!T);

/++
	Allocates 2D identity sliced array with ones on the major diagonal and zeros elsewhere

	Example:
	---
	Slice!(int*, 2) eye = ones!int(4);
	Slice!(double*, 2) matrix = ones!double(4, 2);
	---
+/
Slice!(T*, N) eye(T = defaultType, size_t N)(size_t[N] lengths...) pure @safe
		if ((isNumeric!T && N >= 2) && lengths.length) {
	auto matrix = slice(lengths, cast(T) 0);
	matrix.diagonal[] = 1;
	return matrix;
}

/// ditto
Slice!(T*, 2u) eye(T = defaultType)(in size_t n) pure @safe if (isNumeric!T) {
	return eye!T(n, n);
}

/// ditto
alias identity = eye;

pure @safe unittest {
	assert(eye!int(2) == [[1, 0], [0, 1]].fuse);
	assert(eye!int(2, 3) == [[1, 0, 0], [0, 1, 0]].fuse);
	assert(identity!int(2, 3) == [[1, 0, 0], [0, 1, 0]].fuse);
	assert(identity!int([2, 3]) == [[1, 0, 0], [0, 1, 0]].fuse);

	assert(eye!(Complex!double)(2) == [
			[Complex!double(1.0, 0), Complex!double(0, 0)],
			[Complex!double(0, 0), Complex!double(1, 0)]
			].fuse);

}

/**
	Returns an array of a given shape filled with ones.

	Example:
	---
	Slice!(int*, 1) vector = ones!int(4);
	Slice!(double*, 2) matrix = ones!double(4, 2);
	---
	Params:
	sizes = dimensions of new array, e.g. `(1)`, or `(1, 2)`

	License: MIT - Copyright (c) 2021 John Kilpatrick
	Throws: throws nothing.
	Returns: slice filled with ones.
*/
auto ones(T = defaultType, size_t N)(in size_t[N] sizes...) @safe pure nothrow 
		if (sizes.length) {
	return slice!T(sizes, 1);
}

///
@safe pure unittest {
	assert(ones!int(2) == [1, 1].fuse);
	assert(ones!int(2, 2) == [[1, 1], [1, 1]].fuse);
}

/// ditto
auto onesLike(T = defaultType, size_t N)(in Slice!(T*, N) x) @safe pure nothrow {
	return ones(x.shape);
}

/**
	Returns an array of a given shape filled with zeros.

	Example:
	---
	Slice!(int*, 1) vector = zeros!int(4);
	Slice!(double*, 2) matrix = zeros!double(4, 2);
	---
	Params:
	sizes = dimensions of new array, e.g. `(1)`, or `(1, 2)`

	License: MIT - Copyright (c) 2021 John Kilpatrick
	Throws: throws nothing.
	Returns: A slice with all zero elements
*/
auto zeros(T = defaultType, size_t N)(size_t[N] sizes...) pure @safe
		if (sizes.length) {
	return slice!T(sizes, 0);
}

///
pure @safe unittest {
	assert(zeros!int(2) == [0, 0].fuse);
	assert(zeros!int(2, 2) == [[0, 0], [0, 0]].fuse);
	assert(zeros!int([2, 2]) == [[0, 0], [0, 0]].fuse);
}

/// ditto
auto zerosLike(T = defaultType, size_t N)(in Slice!(T*, N) x) @safe pure nothrow {
	return zeros(x.shape);
}

/**
	Returns an array of a given shape filled with `fillValue`.

	T defaults to integer.

	Example:
	---
	Slice!(int*, 1) vector = full([4], 1); // [1, 1, 1, 1]
	auto matrix = full!double([4, 2], 1); // TODO
	---
	Params:
	sizes = dimensions of new array, e.g. `[1]`, or `[1, 2]`
	fillValue = value for each element of array

	License: MIT - Copyright (c) 2021 John Kilpatrick
	Throws: throws nothing.
	Returns: A slice with all zero elements
*/
auto full(T = defaultType, size_t N)(size_t[N] sizes, T fillValue) pure @safe {
	return slice!T(sizes, fillValue);
}

//TODO: Rip Off integer loading from https://github.com/libmir/mir-algorithm/blob/9af158d339a1bd966a6abfea700667a574e54010/source/mir/ndslice/allocation.d#L274-L317
// Allows for `full(2, 1) == [1, 1].fuse`;

///
pure @safe unittest {
	assert(full([2], 1) == [1, 1].fuse);
	assert(full([2, 2], 1) == [[1, 1], [1, 1]].fuse);
	assert(full([2, 2], 1.1) == [[1.1, 1.1], [1.1, 1.1]].fuse);
	assert(full!double([2, 2], 1.1) == [[1.1, 1.1], [1.1, 1.1]].fuse);
	assert(full!float([2, 2], 1.1) == [[1.1f, 1.1f], [1.1f, 1.1f]].fuse);
}

/// ditto
auto fullLike(T = defaultType, size_t N)(in Slice!(T*, N) x, in T fillValue) @safe pure nothrow {
	return full(x.shape, fillValue);
}

/++
	Uniform random number const range [0, 1] convinience wrapper

	Params:
		lengths = length of each dimension required

	Returns:
		Slice populated with random values

	Example:
    ---
    auto x = rand!float(4);
	auto y = rand!double([2, 2]);
    ---
+/
Slice!(T*, N) rand(T = defaultType, ulong N)(ulong[N] lengths...) @safe
		if (isFloatingPoint!T) {
	import mir.random.variable : uniformVar;
	import mir.random.algorithm : randomSlice;

	return uniformVar!T(0, 1).randomSlice(lengths);
}

/++
	Normal distribution random number convinience wrapper

	Mean is 0, standard deviation is 1.

	Params:
		lengths = length of each dimension required

	Returns:
		Slice populated with normally distributed random values

	Example:
    ---
    auto x = randn!float(4);
	auto y = randn!double([2, 2]);
    ---
+/
Slice!(T*, N) randn(T = defaultType, ulong N)(ulong[N] lengths...) @safe
		if (isFloatingPoint!T) {
	import mir.random.variable : normalVar;
import mir.random.algorithm : randomSlice;

	return normalVar!T(0, 1).randomSlice(lengths);
}

/++
	Uniform random number convinience wrapper
+/
Slice!(T*, N) rand(T, size_t N)(size_t[N] lengths...) @safe if (isFloatingPoint!T) {
	return uniformVar!T(0, 1).randomSlice(lengths);
}

///
Slice!(T*, N) randn(T, size_t N)(size_t[N] lengths...) @safe if (isFloatingPoint!T) {
	return normalVar!T(0, 1).randomSlice(lengths);
}
