#!/usr/bin/env dub
/+ dub.json:
{
    "dependencies": {"dlearn": "*"}
}
+/

import dlearn;
import std : writeln;

void main() {
    dlearn.iota([2], 3).writeln;
}
