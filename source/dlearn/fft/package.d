// Written in the D programming language.

/++
Fourier Transform methods and helper functions

Copyright: Copyright (c) 2021 John Kilpatrick

License: MIT

Authors: John Kilpatrick
+/
module dlearn.fft;

import mir.ndslice;

private {
    import mir.math.common : fastmath;
    import dlearn.utils;
}

enum Normalization {
    forward,     // 1
    orthonormal, // 1 / sqrt(N)
    backward,    // 1 / N
}

/**
    Calculates the one-dimensional fourier transform of a Slice.

    Here could be a longer paragraph that
    elaborates on the great win for
    society for having a function that is actually
    able to calculate a square root of a given
    number.

    correct order is `fftshift(fft(ifftshift(x)))`


    Example:
    ---
    double sq = sqrt(4);
    ---
    Params:
        x =             array to fourier transform
        normalization = method to normalize it    

    Returns: 1D FFT of the input.
*/
Slice!(T*, N) fft(T, size_t N)(const Slice!(T*, N) x, Normalization normalization = Normalization.forward)
        if (N >= 1 && isFloatingPoint!T) {
    import dlearn.allocation : emptyLike;

    auto y = emptyLike(x);

    // TODO: Add implementation code

    switch (normalization) {
    case Normalization.orthonormal:
        import std.math : sqrt;
        import std.conv : signed;

        // y[] /= sqrt(x.length.signed); // TODO: Generalize to higher dim numbers
        break;
    case Normalization.backward:
        y[] /= x.length; // TODO: Generalize to higher dim numbers
        break;
    case Normalization.forward:
        break;
    default:
        import std.format;

        throw new Exception(format("Unknown normalization: %s", normalization));
    }

    return y;
}

/**
    Calculates the one-dimensional inverse fourier transform of a Slice.

    correct order is `fftshift(fft(ifftshift(x)))`


    Example:
    ---
    double sq = sqrt(4);
    ---
    Params:
        x =             array to fourier transform
        normalization = method to normalize it    

    Returns: 1D IFFT of the input.
*/
Slice!(T*, N) ifft(T, size_t N)(const Slice!(T*, N) x, Normalization normalization = Normalization.backward)
        if (N >= 1 && isFloatingPoint!T) {
    import dlearn.allocation : emptyLike;

    auto y = emptyLike(x);

    // TODO: Add implementation code

    switch (normalization) {
    case Normalization.orthonormal:
        import std.math : sqrt;
        import std.conv : signed;

        // y[] /= sqrt(x.length.signed); // TODO: Generalize to higher dim numbers
        break;
    case Normalization.backward:
        y[] /= x.length; // TODO: Generalize to higher dim numbers
        break;
    case Normalization.forward:
        break;
    default:
        import std.format;

        throw new Exception(format("Unknown normalization: %s", normalization));
    }

    return y;
}

/// TODO
// Slice!(T*, N) fft(T, N)(Slice!(T*, N) x, string normalization = "ortho") if (N >= 1 && isComplex!T) {
// return 
// }

/**
    Toroidal roll Slice elements along a given axis.

    Example:
    ---
    auto vec = 3.iota.slice; // [1, 2, 3]
    roll(vec, 1); // [3, 1, 2]
    ---
    Params:
        x =     array to roll
        shift = zero-indexed amount to shift to the left.

    Throws: throws nothing.
    Returns: cyclically permuted input.
*/
static @fastmath auto roll(T, size_t N)(Slice!(T*, N) x, long shift) pure nothrow @safe
        if (isNumeric!T && N >= 1)
in {
    auto length = cast(long) x.length;
    assert((shift < length) && (shift > -length),
            "The absolute value of shift must be less than the length of the desired array");
}
do { // TODO: Add axis
    import mir.ndslice.concatenation : concatenation;
    import std.conv : unsigned, signed;

    const length = x.length.signed;

    shift %= length;
    auto idx = ((shift < 0) ? (shift + length) : shift).unsigned;

    return concatenation(x[$ - idx .. $], x[0 .. $ - idx]).slice;
}

///
pure @safe unittest {
    import mir.ndslice : fuse;
    import mir.ndslice.topology : as;

    auto vec = 3.iota.as!double.slice; // [0, 1, 2]
    assert(vec.roll(1) == [2, 0, 1].fuse);
    assert(vec.roll(0) == 3.iota.as!double.slice);
    assert(vec.roll(2) == [1, 2, 0].fuse);

    // Negative indices
    assert(vec.roll(-1) == [1, 2, 0].fuse);
}

/++
    Shifts zero-frequency component to the center of the spectrum.

	Returns: A slice with all zero elements
    
    See_Also:
        iffshift, fft
	Throws: throws nothing.
+/
static @fastmath auto fftshift(T, size_t N)(Slice!(T*, N) x) pure @safe if (N >= 1) {
    import std.math.rounding : floor;
    import std.conv : to;

    return roll(x, ((x.length.to!double) / 2.0).floor.to!int);
}

///
pure @safe unittest {
    auto x = 4.iota.as!double.slice; // [0, 1, 2, 3]
    assert(fftshift(x) == [2, 3, 0, 1].fuse);

    auto y = 5.iota.as!double.slice; // [0, 1, 2, 3, 4]
    assert(fftshift(y) == [3, 4, 0, 1, 2].fuse);
}

/++
    Shifts natural order [-1, 0, 1] to fft ready order [0, 1, -1].

    I.e. Negative frequencies, DC component, Positive frequencies ->
    DC component, Positive Frequencies, Negative frequencies

    correct order is `fftshift(fft(ifftshift(x)))`

    See_Also:
        ffshift, fft
+/
static @fastmath auto ifftshift(T, size_t N)(Slice!(T*, N) x) pure @safe if (N >= 1) {
    import std.math.rounding : ceil;
    import std.conv : to;

    return roll(x, ((x.length.to!double) / 2.0).ceil.to!int);
}

///
pure @safe unittest {
    auto x = 4.iota.as!double.slice; // [0, 1, 2, 3]
    assert(ifftshift(x) == [2, 3, 0, 1].fuse);

    auto y = 5.iota.as!double.slice; // [0, 1, 2, 3, 4]
    assert(ifftshift(y) == [2, 3, 4, 0, 1].fuse);
}

// Assert fftshift and ifftshift are inverses of each other
pure @safe unittest {
    auto x = 5.iota.as!double.slice; // [0, 1, 2, 3, 4]
    assert(ifftshift(fftshift(x)) == x);
    assert(fftshift(ifftshift(x)) == x);
}
