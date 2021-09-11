// Written in the D programming language.

/++
Mathematical functions acting on slices

Copyright: Copyright (c) 2021 John Kilpatrick

License: MIT

Authors: John Kilpatrick
+/
module dlearn.math;

private {
    import mir.ndslice;
    import mir.ndslice.topology : map;
    import mir.complex : Complex;

    import mir.math.common : approxEqual, fastmath;

    import dlearn.allocation;
    import dlearn.utility;
}

// Unary functions

// Trigonometric & Hyperbolic functions
static foreach (func; [
        "acos", "acosh", "asin", "asinh", "atan", "atanh", "cos", "cosh",
        "sin", "sinh", "tan", "tanh"
    ]) { // TODO: atan2 element-wise NYI for isFloatingPoint!T, atan2 doesn't make sense for complex types
    mixin("static @fastmath Slice!(T*, N) " ~ func
            ~ "(T, size_t N)(in Slice!(T*, N) x) pure nothrow @safe if (isNumeric!T) {
        import std.math.trigonometry : " ~ func ~ ";
        import std.complex : "
            ~ func ~ ";

        return x[].map!" ~ func ~ ".slice;
    }");
}

//
pure @safe unittest {
    import mir.ndslice.topology : as, iota;
    import mir.ndslice : slice;

    const x = 10.iota.as!double.slice;

    // Trig
    x.sin;
    x.cos;
    x.tan;

    // Inverse trig
    x.asin;
    x.acos;
    x.atan;

    // Hyperbolic
    x.sinh;
    x.cosh;
    x.tanh;

    // Inverse Hyperbolic
    x.asinh;
    x.acosh;
    x.atanh;
}

// // Exponentials, Logs, & Powers
// static foreach (func; ["exp", "fabs", "log", "log10"]) { // exp2, log2 NYI for Complex!T
//     mixin("static @fastmath Slice!(T*, N) " ~ func
//             ~ "(T, size_t N)(in Slice!(T*, N) x) pure nothrow @safe if (isNumeric!T) {
//         import std.math.exponential : "
//             ~ func ~ ";
//         import std.complex : " ~ func ~ ";

//         return x[].map!"
//             ~ func ~ ".slice;
//     }");
// }

// //
// pure @safe unittest {
//     import mir.ndslice.topology : as, iota;

//     const x = iota(10, 1).as!double.slice;

//     // Exponentials
//     x.exp;
//     x.log;
//     x.log10;

//     // Powers
//     x.fabs;
//     // x.pow(2);
// }

// Rounding
static foreach (func; ["ceil", "floor", "round", "trunc"]) { // TODO: fix, i.e. round towards zero
    mixin("static @fastmath Slice!(T*, N) " ~ func
            ~ "(T, size_t N)(in Slice!(T*, N) x) pure nothrow @safe if (isFloatingPoint!T) {
        import mir.math.common : " ~ func ~ ";

        return x[].map!" ~ func ~ ".slice;
    }");
}

//
@safe unittest { // TODO: Add pure, see https://github.com/libmir/mir-core/issues/47
    import mir.ndslice : fuse;

    const x = [1.1, 1.9, 2.0].fuse;

    assert(x.ceil == [2.0, 2.0, 2.0].fuse);
    assert(x.floor == [1.0, 1.0, 2.0].fuse);
    assert(x.round == [1.0, 2.0, 2.0].fuse);
    x.trunc;
}

// Equality and that
public import mir.math.common : approxEqual;

// Complex only
static foreach (func; ["abs", "arg", "proj", "sqAbs"]) { // N.B. sqAbs is implements for isFloatingPoint!T
    mixin("static @fastmath Slice!(T*, N) " ~ func
            ~ "(T, size_t N)(in Slice!(T*, N) x) pure nothrow @safe if (isComplex!T) {
        import std.complex : " ~ func ~ ";

        return x[].map!" ~ func ~ ".slice;
    }");
}

// //
// pure @safe unittest {
//     import mir.ndslice : fuse;


//     x.abs;
//     x.arg;
// }

pure @safe unittest {
    import mir.complex : Complex;

    // assert(approxEqual([Complex!double(0, 1)].fuse, [Complex!double(0, -1)].fuse.conj));
}

/// Convert degrees to radians
@fastmath T deg2rad(T)(in T x) pure nothrow @safe if (isFloatingPoint!T) {
    import std.math : PI;
    import std.conv : to;

    enum conversionFactor = ((2.0 * PI) / 360.0).to!T;
    return conversionFactor * x;
}

/// Convert radians to degrees
@fastmath T rad2deg(T)(in T x) pure nothrow @safe if (isFloatingPoint!T) {
    import std.math : PI;
    import std.conv : to;

    enum conversionFactor = (360.0 / (2.0 * PI)).to!T;
    return conversionFactor * x;
}

// FloatingPoint only
static foreach (func; ["deg2rad", "rad2deg"]) {
    mixin("static @fastmath Slice!(T*, N) " ~ func
            ~ "(T, size_t N)(in Slice!(T*, N) x) pure nothrow @safe if (isFloatingPoint!T) {
        return x[].map!" ~ func ~ ".slice;
    }");
}

// }

// pure @safe unittest {
//     import std.math : PI;

//     assert(deg2rad([0., 90.0, -270.0].fuse).approxEqual([0., 0.5 * PI, -1.5 * PI].fuse));
// }

// pure @safe unittest {
//     import std.math : PI;

//     assert(rad2deg([0., 0.5 * PI, -1.5 * PI].fuse).approxEqual([0., 90.0, -270.0].fuse));
// }

/// Returns maximum element of a given slice, if any element is +/- NaN, it is ignored.
T max(T, size_t N)(Slice!(T*, N) x) @fastmath nothrow @safe pure 
        if (isFloatingPoint!T) {
    import mir.algorithm.iteration : reduce;
    import std.math.operations : fmax;

    return reduce!fmax(-T.max, x);
}

///
pure @safe unittest {
    assert(max([-1.0, 3.5, 10.].fuse) == 10.);
    assert(max([[-1.0, 3.5], [10., 20.]].fuse) == 20.0);
}

/// Maximum element-wise
Slice!(T*, N) maximum(T, size_t N)(Slice!(T*, N) x, Slice!(T*, N) y) @fastmath nothrow @safe pure
        if (isFloatingPoint!T) {
    import std.math.operations : fmax;
    import mir.ndslice.topology : map;

    return zip(x, y).map!((a, b) => fmax(a, b)).slice;
}

///
pure @safe unittest {
    assert(maximum([-1.0, 3.5, 10.0].fuse, [0.0, 0.0, 0.0].fuse) == [
            0.0, 3.5, 10.0
            ].fuse);
}

/// Returns minimum element of a given slice, if any element is +/- NaN, it is ignored.
T min(T, size_t N)(Slice!(T*, N) x) @fastmath nothrow @safe pure 
        if (isFloatingPoint!T) {
    import mir.algorithm.iteration : reduce;
    import std.math.operations : fmin;

    return reduce!fmin(T.max, x);
}

///
@safe pure unittest {
    assert(min([-1.0, 3.5, 10.].fuse) == -1.0);
    assert(min([[-1.0, 3.5], [10., 20.]].fuse) == -1.0);
}

/// Minimum element-wise
Slice!(T*, N) minimum(T, size_t N)(Slice!(T*, N) x, Slice!(T*, N) y) @fastmath nothrow @safe pure
        if (isFloatingPoint!T) {
    import std.math.operations : fmin;
    import mir.ndslice.topology : map;

    return zip(x, y).map!((a, b) => fmin(a, b)).slice;
}

///
pure @safe unittest {
    assert(minimum([-1.0, 3.5, 10.0].fuse, [0.0, 0.0, 0.0].fuse) == [
            -1.0, 0.0, 0.0
            ].fuse);
}

public import mir.algorithm.iteration : all, any;

// From mir.algorithm.iteration:
// -[ ] all
// -[ ] any
// -[ ] Slice == Slice
// -[ ] Slice approxEquals Slice

// TODO: Binary Operations:
// static foreach (func; ["expi", "fromPolar"]) {
// }

/++
    Clamp a number between two values
+/
T clamp(T)(T x, T min = -T.max, T max = T.max) @fastmath nothrow @safe pure @nogc
        if (isReal!T)
in {
    assert(max >= min, "Max cannot be less than min");
}
do {
    auto t = x < min ? min : x;
    return t > max ? max : t;
}

///
pure @safe unittest {
    assert(clamp(3.5) == 3.5);
    assert(clamp(3.5, 3.) == 3.5);
    assert(clamp(3.5, 4.) == 4.0);
    assert(clamp(3, -2, 0) == 0);
    assert(clamp(3.0, -double.max, 0.) == 0.0);

    // TODO: Waiting on <https://github.com/dlang/projects/issues/76>
    // assert(clamp(3.0, max: 2.0) == 2.0);
}

/// Clamp element-wise
Slice!(T*, N) clamp(T, size_t N)(Slice!(T*, N) x, T min = -T.max, T max = T.max) @fastmath nothrow @safe pure
        if (isFloatingPoint!T) {
    import mir.ndslice.topology : map;

    return x.map!(a => clamp(a, min, max)).slice;
}

///
pure @safe unittest {
    assert(clamp([-1.0, 3.5, 10.].fuse, 0, 5) == [-0., 3.5, 5.0].fuse);
}

/++
    Sum of all elements in x

    TODO: Add axis
+/
T sum(T, size_t N)(Slice!(T*, N) x) {
    import mir.math.sum : sum;

    return x.sum;
}

///
pure @safe unittest {
    assert(sum([0, 1, 2].fuse) == 3);
    assert(sum(iota(3, 2).slice) == 15); // 0 + 1 + 2 + 3 + 4 + 5
}

/++
    Mean of x

    TODO: Add axis
+/
T mean(T, size_t N)(Slice!(T*, N) x) {
    import std.conv : to;
    return x.sum / x.elementCount.to!T;
}

///
pure @safe unittest {
    import std.math : sqrt;

    assert(mean([9, 10, 12, 13, 13, 13, 15, 15, 16, 16, 18, 22, 23, 24, 24, 25].as!double.fuse) == 16.75);
    assert(mean([[0, 1], [-1, 4]].fuse) == 1);
}
