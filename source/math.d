module math;

private {
import mir.ndslice;
import mir.ndslice.topology : map;

import allocation : isNumeric, isFloatingPoint, isInteger;
import mir.internal.utility : isComplex;
import mir.math.common: approxEqual;
}

// Trigonometric functions
static foreach(func; ["acos", "acosh", "asin", "asinh", "atan", "atanh", "cos", "cosh", "sin", "sinh", "tan", "tanh"]) { // atan2 NYI for  Complex!T
    mixin("auto " ~ func ~ "(T, size_t N)(in Slice!(T*, N) x) pure nothrow @trusted if (isNumeric!T) {
        import std.math.trigonometry : " ~ func ~ ";
        import std.complex : " ~ func ~ ";

        return x[].map!" ~ func ~ ".slice;
    }");
}

// Exponentials, Logs, & Powers
static foreach(func; ["exp", "log", "log10", "pow"]) { // exp2, log2 NYI for Complex!T
    mixin("auto " ~ func ~ "(T, size_t N)(in Slice!(T*, N) x) pure nothrow @trusted if (isNumeric!T) {
        import std.math.exponential : " ~ func ~ ";
        import std.complex : " ~ func ~ ";

        return x[].map!" ~ func ~ ".slice;
    }");
}

// Complex only
static foreach(func; ["abs", "arg", "conj", "expi", "fromPolar", "proj", "sqAbs"]) { // N.B. sqAbs is implements for isFloatingPoint!T
    mixin("auto " ~ func ~ "(T, size_t N)(in Slice!(T*, N) x) pure nothrow @trusted if (isComplex!T) {
        import std.complex : " ~ func ~ ";

        return x[].map!" ~ func ~ ".slice;
    }");
}


pure @safe unittest {
    import mir.complex : Complex;

    assert(approxEqual([Complex!double(0, 1)].fuse, [Complex!double(0, -1)].fuse.conj));
}

Slice!(T*, N) deg2rad(T, size_t N)(in Slice!(T*, N) x) pure nothrow @trusted if (isFloatingPoint!T) {
    import std.math : PI;
    import std.conv : to;
    enum conversionFactor = ((2.0 * PI) / 360.0).to!T;
    return (conversionFactor * x[]).slice;
}

pure @safe unittest {
    import std.math : PI;
    assert(approxEqual(deg2rad([0., 90.0, -270.0].fuse), [0., 0.5 * PI, -1.5 * PI].fuse));
}

Slice!(T*, N) rad2deg(T, size_t N)(in Slice!(T*, N) x) pure nothrow @trusted if (isFloatingPoint!T) {
    import std.math : PI;
    import std.conv : to;
    enum conversionFactor = (360.0 / (2.0 * PI)).to!T;
    return (conversionFactor * x[]).slice;
}

pure @safe unittest {
    import std.math : PI;
    assert(approxEqual(rad2deg([0., 0.5 * PI, -1.5 * PI].fuse), [0., 90.0, -270.0].fuse));
}

// TODO:
// -[ ] sum
// -[ ] min
// -[ ] max
// -[ ] cumsum
// -[ ] mean
// -[ ] median
// -[ ] std
