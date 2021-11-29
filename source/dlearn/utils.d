module dlearn.utils;

private {
    import std.traits : Unqual;
}

enum isInteger(T) = is(Unqual!T == short) || is(Unqual!T == ushort)
    || is(Unqual!T == int) || is(Unqual!T == uint) || is(Unqual!T == long) || is(Unqual!T == ulong);

enum isFloatingPoint(T) = is(Unqual!T == float) || is(Unqual!T == double) || is(Unqual!T == real); // || is(Unqual!T == cent) || is(Unqual!T == ucent);

enum isContinuous(T) = isComplex!(Unqual!T) || isFloatingPoint!(Unqual!T);

enum isNumeric(T) = isInteger!(Unqual!T) || isFloatingPoint!(Unqual!T) || isComplex!(Unqual!T);

enum isReal(T) = isInteger!(Unqual!T) || isFloatingPoint!(Unqual!T);

public import mir.internal.utility : isComplex;
