module numd.allocation;

private {
	import std.stdio;
	import mir.ndslice;
	import mir.complex;
	import mir.ndslice.topology : map;
	import mir.internal.utility : isComplex;

	alias defaultType = int;

	import std.traits : Unqual;
}

enum isInteger(T) = is(Unqual!T == short) || is(Unqual!T == ushort)
	|| is(Unqual!T == int) || is(Unqual!T == uint) || is(Unqual!T == long) || is(Unqual!T == ulong);

enum isFloatingPoint(T) = is(Unqual!T == float) || is(Unqual!T == double) || is(Unqual!T == real); // || is(Unqual!T == cent) || is(Unqual!T == ucent);

enum isNumeric(T) = isInteger!(Unqual!T) || isFloatingPoint!(Unqual!T) || isComplex!(Unqual!T);

/++
	Allocates 2D identity sliced array with ones on the major diagonal and zeros elsewhere

	Example:
	---
	Slice!(int*, 2) eye = ones!int(4);
	Slice!(double*, 2) matrix = ones!double(4, 2);
	---
+/
Slice!(T*, N) eye(T = defaultType, size_t N)(size_t[N] lengths...) pure nothrow 
		if (isNumeric!T && N >= 2) {
	auto matrix = slice(lengths, cast(T) 0);
	matrix.diagonal[] = 1;
	return matrix;
}

/// ditto
Slice!(T*, 2u) eye(T = defaultType)(in size_t n) pure nothrow if (isNumeric!T) {
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
auto ones(T = defaultType, size_t N)(in size_t[N] sizes...) pure nothrow {
	return slice!T(sizes, 1);
}

///
pure @safe unittest {
	assert(ones!int(2) == [1, 1].fuse);
	assert(ones!int(2, 2) == [[1, 1], [1, 1]].fuse);
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
auto zeros(T = defaultType, size_t N)(size_t[N] sizes...) pure nothrow {
	return slice!T(sizes, 0);
}

///
pure @safe unittest {
	assert(zeros!int(2) == [0, 0].fuse);
	assert(zeros!int(2, 2) == [[0, 0], [0, 0]].fuse);
	assert(zeros!int([2, 2]) == [[0, 0], [0, 0]].fuse);
}

/**
	Returns an array of a given shape filled with `fillValue`.

	T defaults to integer.

	Example:
	---
	Slice!(int*, 1) vector = full([4], 1);
	auto matrix = full!double([4, 2], 1);
	---
	Params:
	sizes = dimensions of new array, e.g. `[1]`, or `[1, 2]`
	fillValue = value for each element of array

	License: MIT - Copyright (c) 2021 John Kilpatrick
	Throws: throws nothing.
	Returns: A slice with all zero elements
*/
auto full(T = defaultType, size_t N)(size_t[N] sizes, T fillValue) pure nothrow {
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