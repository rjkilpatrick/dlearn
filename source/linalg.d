module linalg;

private {
	import std.stdio;
	import mir.ndslice;
	import mir.complex;
	import mir.ndslice.topology : map;
	import mir.internal.utility : isFloatingPoint, isComplex;
    import allocation;
    import mir.math.sum;
}

/++
    Dot product of 2 slices of vectors
+/
T dot(T)(const Slice!(T*, 1U) a, const Slice!(T*, 1U) b) pure nothrow  // in((isVector!T && isMatrix!U) || (isMatrix!T && isMatrix!U) || (isMatrix!T && isVector!U))
{
	import mir.math.sum;
	assert(a.length == b.length);
	return (a[] * b[]).sum;
}

pure nothrow @safe unittest {
    assert(dot([1, 1, 1].fuse, [1, 1, 1].fuse) == 3);
}

/// Attempts to multiply matrices
auto matrixMultiply(T)(const Slice!(T*, 2u) a, const Slice!(T*, 2u) b) pure nothrow //TODO: Add commontype
{
	assert(a.length!1 == b.length!0);
	import std.traits : CommonType;

	const m = a.length!0;
	const p = a.length!1;
	const n = b.length!1;

	auto c = zeros!T(m, n);

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

pure nothrow @safe unittest {
    assert(eye!double(2).matrixMultiply(eye!double(2)) == eye!double(2));
    assert(ones!double(2, 2).matrixMultiply(eye!double(2)) == ones!double(2));

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

T trace(T)(Slice!(T*, 2u) x) pure nothrow @trusted if (isNumeric!T) { // TODO: make in
    return x.diagonal[].sum;
}

pure @safe unittest {
    assert([[1, 0], [0, 1]].fuse.trace == 2);
}