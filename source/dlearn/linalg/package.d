// Written in the D programming language.

/++
High-level linear algebra manipulation methods

Copyright: Copyright (c) 2021 John Kilpatrick

License: MIT

Authors: John Kilpatrick
+/
module dlearn.linalg;

private {
	import std.stdio;
	import mir.ndslice;
	import mir.complex;
	import mir.ndslice.topology : map;
	import mir.math.common : fastmath;
	import std.traits : CommonType;

	import dlearn.allocation;
	import dlearn.math;
	import dlearn.utils;
}

/++
    Dot product of 2 slices
+/
T dot(T, SliceKind kindX, U, SliceKind kindY, size_t N)(Slice!(T*, N,
		kindX) x, Slice!(U*, N, kindY) y) pure nothrow @safe @fastmath // {
// 	import mir.blas : dot;

// 	return dotProd(x.flattened, y.flattened);
// }
in {
	assert(x.strides == y.strides);
}
do {
	import mir.algorithm.iteration : reduce;
	import mir.ndslice.topology : zip;
	import mir.math.common : fastmath;

	static @fastmath T fmuladd(T, Z)(const T a, Z z) {
		return a + z.a * z.b;
	}

	auto z = zip!true(x, y);

	return reduce!fmuladd(0, z);
}

pure @safe unittest {
	assert(dot([1, 1, 1].fuse, [1, 1, 1].fuse) == 3);
	assert(dot([[1, 1, 1], [1, 1, 1]].fuse, [[1, 1, 1], [1, 1, 1]].fuse) == 6);
}

/// Attempts to multiply matrices
Slice!(CommonType!(T, U)*, 2u) matrixMultiply(T, SliceKind kindX, U, SliceKind kindY)(
		Slice!(T*, 2u, kindX) a, Slice!(U*, 2u, kindY) b) pure nothrow @safe @fastmath
in {
	assert(a.length!1 == b.length!0, "Number of columns of a must equal number of rows of b");
}
out(ret) {
	assert(a.length!0 == ret.length!0, "Number of columns of a must equal number of rows returned");
	assert(b.length!1 == ret.length!1, "Number of columns of a must equal number of rows returned");
}
do {
	import std.traits : CommonType;
	import mir.blas : gemm;

	const m = a.length!0;
	const n = b.length!1;

	auto c = empty!(CommonType!(T, U))(m, n);
	gemm(1, a, b, 0, c);
	return c;
}

///
pure @safe unittest {
	assert(eye!double(2).matrixMultiply(eye!double(2)) == eye!double(2));
	assert(ones!double(2, 2).matrixMultiply(eye!double(2)) == ones!double(2, 2));

	auto a = [2, 3].iota(1).as!double.slice;
	auto b = [3, 2].iota(7).as!double.slice;

	const result = [[58, 64], [139, 154]].fuse.as!double;
	// assert(a.matrixMultiply(b).approxEqual(result));
	assert(a.matrixMultiply(b) == result);
}

/// ditto
Slice!(CommonType!(T, U)*, 1u) matrixMultiply(T, SliceKind kindX, U, SliceKind kindY)(
		Slice!(T*, 2u, kindX) a, Slice!(U*, 1u, kindY) x) pure nothrow @safe @fastmath
in {
	assert(a.length!1 == x.length);
}
do {
	import std.traits : CommonType;
	import mir.blas : gemv;

	const m = a.length!0;

	auto c = empty!(CommonType!(T, U))(m);
	gemv(1.0, a, x, 0.0, c);
	return c;
}

///
pure @safe unittest {
	// assert(eye!double(2).matrixMultiply(ones!double(2)).approxEqual(ones!double(2)));
	assert(eye!double(2).matrixMultiply(ones!double(2)) == ones!double(2));
}

/// ditto
Slice!(CommonType!(T, U)*, 1u) matrixMultiply(T, U)(Slice!(T*, 1u) x, Slice!(U*, 2u) a) pure nothrow {
	return a.transposed.matrixMultiply(x);
}

///
pure @safe unittest {
	// assert(ones!double(2).matrixMultiply(eye!double(2)).approxEqual(ones!double(2)));
	assert(ones!double(2).matrixMultiply(eye!double(2)) == ones!double(2));
	assert([2, 2].iota.as!double.slice.matrixMultiply([2, 2].iota(1)
			.as!double.slice) == [[3.0, 4.0], [11.0, 16.0]]);
}

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
