module scancode;

import std.algorithm, std.array, std.range;
import std.ascii;

enum yen = '\xa5';

version (unittest)
{
    import std.format;
    import std.stdio : stderr;
}

enum LetterKeys
{
    n0='0', n1, n2, n3, n4, n5, n6, n7, n8, n9,
    a='a', b, c, d, e, f, g, h, i, j, k, l, m,
    n, o, p, q, r, s, t, u, v, w, x, y, z,
    hyphen='-',
    caretJP='^', yenJP=yen, atJP='@',
    openBrac='[', closeBrac=']',
    semicolon=';', colonJP=':',
    comma=',', period='.', slash='/', backslash='\\',
    equalUS='=', quoteUS='\'', graveUS='`'
}
import std.conv;
char[LetterKeys] usKeyboard, jpKeyboard;
static this ()
{
    with (LetterKeys) usKeyboard = [
            graveUS: '~',
            n1: '!', n2: '@', n3: '#', n4: '$',
            n5: '%', n6: '^', n7: '&', n8: '*',
            n9: '(', n0: ')',

            hyphen: '_', equalUS: '+',
            openBrac: '{', closeBrac: '}',
            semicolon: ':', quoteUS: '"',
            slash: '?', backslash: '|',
            comma: '<', period: '>'
        ];
    with (LetterKeys) jpKeyboard = [
            n1: '!', n2: '"', n3: '#', n4: '$',
            n5: '%', n6: '&', n7: '\'', n8: '(',
            n9: ')', n0: '\0',

            hyphen: '=', caretJP: '~', yenJP: '|',
            atJP: '`',
            openBrac: '{', closeBrac: '}',
            semicolon: '+', colonJP: '*',
            slash: '?', backslash: '_',
            comma: '<', period: '>'
        ];
    foreach (alphabet; 'a'..'z'+1)
    {
        usKeyboard[alphabet.to!LetterKeys] = cast(char)(alphabet.toUpper);
        jpKeyboard[alphabet.to!LetterKeys] = cast(char)(alphabet.toUpper);
    }
}

///
enum
    jpDvorak = [
    "\x001234567890[]\xa5",
        ":,.pyfgcrl/^",
        "aoeuidhtns-@",
        ";qjkxbmwvz\\"
    ].b,
    jpDvorakMinimal = [
    "\x001234567890-^\xa5",
        "/,.pyfgcrl@[",
        "aoeuidhtns:]",
        ";qjkxbmwvz\\"
    ].b,
    jpQwerty = [
    "\x001234567890-^\xa5",
        "qwertyuiop@[",
        "asdfghjkl;:]",
        "zxcvbnm,./\\"
    ].b,
    usDvorak = [
       "`1234567890[]\0",
        "',.pyfgcrl/=",
        "aoeuidhtns-\\",
        ";qjkxbmwvz\0"
    ].b,
    usQwerty = [
       "`1234567890-=\0",
        "qwertyuiop[]",
        "asdfghjkl;'\\",
        "zxcvbnm,./\0"
    ].b;

///
unittest
{
    // all layout: same physical keys
    foreach (pair; [
            jpDvorak, jpDvorakMinimal, jpQwerty, usQwerty, usDvorak
        ].adjacent)
        assert (pair[0].equal!isSameLength(pair[1]));
}
unittest
{
    // same language: same set of letters input without shift
    foreach (pair; [
            jpDvorak, jpDvorakMinimal, jpQwerty
        ].adjacent.chain([
            usQwerty, usDvorak
        ].adjacent))
        assert (pair[0].joiner.array.dup.sort.equal(pair[1].joiner.array.dup.sort));
}
///
unittest
{
    foreach (pair; [
            jpDvorak, jpDvorakMinimal, jpQwerty, usDvorak, usQwerty
            ].zip([jpKeyboard, jpKeyboard, jpKeyboard, usKeyboard, usKeyboard]))
    {
        auto _noShift = pair[0].noShift;
        // no duplicate non-null key.
        assert (_noShift.isStrictlyMonotonic);
        // all non-null keys can be shifted (result may be null, but must be defined)
        foreach (ns; _noShift)
            if (ns)
                assert ((cast(LetterKeys)ns) in pair[1]);
        // all shiftable keys is defined and non-null.
        foreach (ns; pair[1].byKeyValue)
            assert (!_noShift.find(ns.key).empty);

        auto _shifted = pair[0].shifted(pair[1]);
        // no duplicate shifted non-null key.
        assert (_shifted.isStrictlyMonotonic);
        // no shared non-null noShift and shifted key.
        assert (_noShift.setIntersection(_shifted).empty, "%(%02x %)".format(
                    _noShift.setIntersection(_shifted)));
    }
}
///
unittest
{
    auto jpKeys = [jpDvorak.noShift, jpDvorak.shifted(jpKeyboard)].multiwayUnion;
}
auto noShift(immutable(ubyte)[][] b)
{
    return b.joiner.filter!(_=>_).array.dup.sort;
}
auto shifted(immutable(ubyte)[][] b, char[LetterKeys] shift)
{
    return b.joiner.filter!(_=>_).map!(_=>cast(ubyte)(shift[cast(LetterKeys)_])).filter!(_=>_).array.sort;
}

private immutable (ubyte)[][] b(string[] str)
{
    return str.map!(_=>cast(immutable(ubyte)[])_.idup).array;
}

private auto adjacent(R)(R r)
{
    import std.typecons;
    alias T = ElementType!R;
    struct Result
    {
        this (T first, R r)
        {
            this.first = first;
            this.r = r;
        }
        bool empty() const @property
        {
            return r.empty;
        }
        Tuple!(T, T) front()
        {
            assert (!empty);
            return first.tuple(r.front);
        }
        void popFront()
        {
            assert (!empty);
            r.popFront;
        }
        T first;
        R r;
    }
    T first;
    if (!r.empty)
    {
        first = r.front;
        r.popFront;
    }
    return Result(first, r);
}
