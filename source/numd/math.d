module numd.math;

private {
    import mir.ndslice;
    import mir.ndslice.topology : map;

    import mir.internal.utility : isComplex;
    import mir.math.common : approxEqual, fastmath;

    import numd.allocation : isNumeric, isFloatingPoint, isInteger;
}

// Trigonometric & Hyperbolic functions
static foreach (func; [
        "acos", "acosh", "asin", "asinh", "atan", "atanh", "cos", "cosh",
        "sin", "sinh", "tan", "tanh"
    ]) { // atan2 NYI for  Complex!T
    mixin("static @fastmath Slice!(T*, N) " ~ func
            ~ "(T, size_t N)(in Slice!(T*, N) x) pure nothrow @trusted if (isNumeric!T) {
        import std.math.trigonometry : "
            ~ func ~ ";
        import std.complex : " ~ func ~ ";

        return x[].map!"
            ~ func ~ ".slice;
    }");
}

//
pure @safe unittest {
    import mir.ndslice.topology : iota;
    import mir.ndslice : fuse;

    const x = 10.iota!double.fuse;

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

// Exponentials, Logs, & Powers
static foreach (func; ["exp", "fabs", "log", "log10", "pow"]) { // exp2, log2 NYI for Complex!T
    mixin("static @fastmath Slice!(T*, N) " ~ func
            ~ "(T, size_t N)(in Slice!(T*, N) x) pure nothrow @trusted if (isNumeric!T) {
        import std.math.exponential : "
            ~ func ~ ";
        import std.complex : " ~ func ~ ";

        return x[].map!"
            ~ func ~ ".slice;
    }");
}

//
pure @safe unittest {
    import mir.ndslice.topology : iota;
    import mir.ndslice : fuse;

    const x = 10.iota!double(1).fuse;

    // Exponentials
    x.exp;
    x.log;
    x.log10;

    // Powers
    x.fabs;
    x.pow(2);
}

// Equality and that
public import mir.math.common : approxEqual;

// Complex only
static foreach (func; ["abs", "arg", "expi", "fromPolar", "proj", "sqAbs"]) { // N.B. sqAbs is implements for isFloatingPoint!T
    mixin("static @fastmath Slice!(T*, N) " ~ func
            ~ "(T, size_t N)(in Slice!(T*, N) x) pure nothrow @trusted if (isComplex!T) {
        import std.complex : " ~ func ~ ";

        return x[].map!" ~ func ~ ".slice;
    }");
}

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
            ~ "(T, size_t N)(in Slice!(T*, N) x) pure nothrow @trusted if (isFloatingPoint!T) {
        return x[].map!" ~ func ~ ".slice;
    }");
}

pure @safe unittest {
    import std.math : PI;

    assert(approxEqual(deg2rad([0., 90.0, -270.0].fuse), [
                0., 0.5 * PI, -1.5 * PI
            ].fuse));
}

pure @safe unittest {
    import std.math : PI;

    assert(approxEqual(rad2deg([0., 0.5 * PI, -1.5 * PI].fuse), [
                0., 90.0, -270.0
            ].fuse));
}

// TODO:
// -[ ] sum
// -[ ] min
// -[ ] max
// -[ ] cumsum
// -[ ] mean
// -[ ] median
// -[ ] std

// From mir.algorithm.iteration:
// -[ ] all
// -[ ] any
// -[ ] Slice == Slice
// -[ ] Slice approxEquals Slice
