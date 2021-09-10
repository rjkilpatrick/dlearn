// Written in the D programming language.

/++
High-level linear algebra manipulation methods

Copyright: Copyright (c) 2021 John Kilpatrick

License: MIT

Authors: John Kilpatrick
+/
module numd.linalg;

private {
	import std.stdio;
	import mir.ndslice;
	import mir.complex;
	import mir.ndslice.topology : map;
	import mir.internal.utility : isFloatingPoint, isComplex;
	import mir.math.sum;
	import mir.math.common : fastmath;
	import std.traits : CommonType;

	import numd.allocation;
}

/++
    Dot product of 2 slices of vectors
+/
@fastmath CommonType!(T, U) dot(T, U, size_t N, size_t M)(const Slice!(T*,
		N) a, const Slice!(U*, M) b) pure @safe if (N >= 1 && N == M)
in {
	assert(a.shape == b.shape);
}
do {
	import mir.math.sum : sum;

	assert(a.shape == b.shape);
	return (a[] * b[]).sum;
}

pure @safe unittest {
	assert(dot([1, 1, 1].fuse, [1, 1, 1].fuse) == 3);
	assert(dot([[1, 1, 1]].fuse, [[1, 1, 1]].fuse) == 3);
}

/// Attempts to multiply matrices
Slice!(CommonType!(T, U)*, 2u) matrixMultiply(T, U)(
		const Slice!(T*, 2u) a, const Slice!(U*, 2u) b) pure nothrow @safe @fastmath
in {
	assert(a.length!1 == b.length!0);
}
do {
	import std.traits : CommonType;

	const m = a.length!0;
	const p = a.length!1;
	const n = b.length!1;

	auto c = zeros!(CommonType!(T, U))(m, n);

	foreach (i; 0 .. m) {
		foreach (j; 0 .. n) {
			foreach (k; 0 .. p) {
				c[i][j] += a[i][k] * b[k][j];
			}
			// c[i][j] = a[i, 0..$].dot(b[0..$, j]);
		}
	}

	return c;
}

pure @safe unittest {
	assert(eye!double(2).matrixMultiply(eye!double(2)) == eye!double(2));
	assert(ones!double(2, 2).matrixMultiply(eye!double(2)) == ones!double(2, 2));

	// const a = [[1, 2, 3], [4, 5, 6]].fuse;
	// const b = [[7, 8], [9, 10], [11, 12]].fuse;
	// const a = iota!double([2, 3], 1).slice;
	// const b = iota!double([3, 2], 7).slice;

	// const result = [[56, 64], [139, 154]].fuse;
	// assert(a.matrixMultiply(b) == result);
}

// // auto matrixMultiply(T)(const Slice!(T*, 2u) a, const Slice!(T*, 1u) b) pure nothrow {
// // 	return matrixMultiply(a, b.unsqueeze(-1));
// // }

// // auto matrixMultiply(T)(const Slice!(T*, 1u) a, const Slice!(T*, 2u) b) pure nothrow {
// // 	return matrixMultiply(a.unsqueeze(-2), b);
// // }

/// Takes the trace of a 2D mir Slice
static @fastmath T trace(T)(Slice!(T*, 2u) x) pure nothrow @nogc @safe
		if (isNumeric!T) {
	import mir.math.sum : sum;

	return x.diagonal[].sum;
}

///
pure @safe unittest {
	assert([[1, 0], [0, 1]].fuse.trace == 2);
}
