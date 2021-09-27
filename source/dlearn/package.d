module dlearn;

public import dlearn.allocation : diag, empty, emptyLike, eye, full, fullLike,
    iota, linspace, ones, onesLike, rand, randn, zeros, zerosLike;

public import dlearn.math : abs, acos, acosh, arg, asin, asinh, atan, atanh,
    ceil, clamp, cos, cosh, deg2rad, floor, max, maximum, mean, min, minimum,
    proj, rad2deg, round, sin, sinh, sqAbs, sum, tan, tanh, trunc;

public import dlearn.linalg : dot, matrixMultiply, trace;

public import dlearn.fft : fft, fftshift, ifft, ifftshift, roll;
