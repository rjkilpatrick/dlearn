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

public import mir.internal.utility : isComplex;
/++
	Allocates 2D identity sliced array with ones on the major diagonal and zeros elsewhere

	Example:
	---
	Slice!(int*, 2) eye = ones!int(4);
	Slice!(double*, 2) matrix = ones!double(4, 2);
	---
+/
Slice!(T*, N) eye(T = defaultType, ulong N)(ulong[N] lengths...) pure @safe
		if ((isNumeric!T && N >= 2) && lengths.length) {
	auto matrix = slice(lengths, cast(T) 0);
	matrix.diagonal[] = 1;
	return matrix;
}

/// ditto
Slice!(T*, 2u) eye(T = defaultType)(const ulong n) pure @safe if (isNumeric!T) {
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
	lengths = dimensions of new array, e.g. `(1)`, or `(1, 2)`

	License: MIT - Copyright (c) 2021 John Kilpatrick
	Throws: throws nothing.
	Returns: slice filled with ones.
*/
auto ones(T = defaultType, ulong N)(const ulong[N] lengths...) @safe pure nothrow 
		if (lengths.length) {
	return slice!T(lengths, 1);
}

///
@safe pure unittest {
	assert(ones!int(2) == [1, 1].fuse);
	assert(ones!int(2, 2) == [[1, 1], [1, 1]].fuse);
}

/// ditto
auto onesLike(T = defaultType, ulong N)(const Slice!(T*, N) x) @safe pure nothrow {
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
	lengths = dimensions of new array, e.g. `(1)`, or `(1, 2)`

	License: MIT - Copyright (c) 2021 John Kilpatrick
	Throws: throws nothing.
	Returns: A slice with all zero elements
*/
auto zeros(T = defaultType, ulong N)(ulong[N] lengths...) pure @safe
		if (lengths.length && isNumeric!T) {
	return slice!T(lengths, 0);
}

///
pure @safe unittest {
	assert(zeros!int(2) == [0, 0].fuse);
	assert(zeros!int(2, 2) == [[0, 0], [0, 0]].fuse);
	assert(zeros!int([2, 2]) == [[0, 0], [0, 0]].fuse);
}

/// ditto
auto zerosLike(T = defaultType, ulong N)(const Slice!(T*, N) x) @safe pure nothrow {
	return zeros(x.shape);
}

///
pure @safe unittest {
	import mir.ndslice.topology : as;

	assert(zerosLike([0, 0].fuse) == [0, 0].fuse);

	// auto x = [[1, 2], [3, 4]].as!(double[]).sliced(2, 2);
	// assert(zerosLike(x) == [[0., 0.], [0., 0.]].fuse);
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
	lengths = dimensions of new array, e.g. `[1]`, or `[1, 2]`
	fillValue = value for each element of array

	License: MIT - Copyright (c) 2021 John Kilpatrick
	Throws: throws nothing.
	Returns: A slice with all zero elements
*/
auto full(T = defaultType, ulong N)(ulong[N] lengths, T fillValue) pure @safe
		if (isNumeric!T) {
	return slice!T(lengths, fillValue);
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
auto fullLike(T = defaultType, ulong N)(const Slice!(T*, N) x, const T fillValue) @safe pure nothrow {
	return full(x.shape, fillValue);
}

/**
	Returns an unfilled slice of a given shape.

	Example:
	---
	Slice!(int*, 1) vector = empty!int(4);
	Slice!(double*, 2) matrix = empty!double(4, 2);
	---
	Params:
	lengths = dimensions of new array, e.g. `(1)`, or `(1, 2)`

	License: MIT - Copyright (c) 2021 John Kilpatrick
	Throws: throws nothing.
	Returns: unfilled slice.
*/
auto empty(T = defaultType, ulong N)(const ulong[N] lengths...) @safe pure nothrow 
		if (lengths.length) {
	import mir.ndslice.allocation : uninitSlice;
	return uninitSlice!T(lengths);
}

///
@safe pure unittest {
	auto x = empty!int(2);
	x[] = 1;

	assert(x == [1, 1].fuse);
}

/// ditto
auto emptyLike(T = defaultType, ulong N)(const Slice!(T*, N) x) @safe pure nothrow {
	return empty(x.shape);
}


public import mir.ndslice.topology : linspace;

// Random

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
	Places vector on diagonal of a new matrix
+/
Slice!(T*, 2) diag(T = defaultType)(Slice!(T*, 1) x) @safe pure nothrow {
	auto y = zeros!(T, 2)(x.length, x.length);
	y.diagonal[] = x;
	return y;
}

///
pure @safe unittest {
	import mir.complex : Complex;

	assert(diag([1., 1.].fuse) == eye(2, 2));
	// assert(diag([Complex!double(2., 0), Complex!double(0., 1.)].fuse) == [
	// [Complex!double(2., 0.), Complex!double(0., 0.)],
	// [Complex!double(0., 0.), Complex!double(0., 1.)]
	// ].fuse);
	assert(diag([0, 0].fuse) == [[0, 0], [0, 0]].fuse);
}
