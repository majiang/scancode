module scancode;

import std.algorithm, std.array, std.range;
import std.ascii;

enum yen = '\xa5';

version (unittest)
{
    import std.format;
    import std.stdio : stderr;
}
enum Scancode : ushort
{
    graveUS = 0x29,
    zenhanJP = 0x29,
    n1 = 0x2, n2, n3, n4, n5, n6, n7, n8, n9, n0,
    hyphen,
    equalUS = 0xd,
    caretJP = 0xd,
    _unusedUS0 = 0x0,
    yenJP = 0x7d,
    q = 0x10, w, e, r, t, y, u, i, o, p,
    openBracUS = 0x1a, closeBracUS,
    atJP = 0x1a, openBracJP,
    capsLock = 0x3a,
    a = 0x1e, s, d, f, g, h, j, k, l,
    semicolon = 0x27,
    quoteUS = 0x28,
    colonJP = 0x28,
    backslashUS = 0x2b,
    closeBracJP = 0x2b,
    z = 0x2c, x, c, v, b, n, m, comma, period, slash,
    _unusedUS1 = 0x0,
    backslashJP = 0x73,

    leftShift = 0x2a, rightShift = 0x36,
    control = 0x1d,
    alt = 0x38,

    muhenkan = 0x7b,
    henkan = 0x79,
    kanakana = 0x70,
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
Scancode[LetterKeys] usScancodes, jpScancodes, commonScancodes;
static this ()
{
    with (LetterKeys) commonScancodes = [
            hyphen: Scancode.hyphen,
            semicolon: Scancode.semicolon,
            comma: Scancode.comma,
            period: Scancode.period,
            slash: Scancode.slash,
    ];
    foreach (char digit; '0'..'9'+1)
        commonScancodes[['n', digit].to!LetterKeys] = ['n', digit].to!Scancode;
    foreach (char digit; 'a'..'z'+1)
        commonScancodes[[digit].to!LetterKeys] = [digit].to!Scancode;
    /*
    _unusedUS1 = 0x0,
    backslashJP = 0x73,
    */

    with (LetterKeys) jpScancodes = [
            // undefined: Scancode.zenhanJP,
            caretJP: Scancode.caretJP,
            yenJP: Scancode.yenJP,
            openBrac: Scancode.openBracJP,
            closeBrac: Scancode.closeBracJP,
            atJP: Scancode.atJP,
            colonJP: Scancode.colonJP,
            backslash: Scancode.backslashJP,
    ];
    with (LetterKeys) usScancodes = [
            graveUS: Scancode.graveUS,
            equalUS: Scancode.equalUS,
            // undefined: _unusedUS0,
            openBrac: Scancode.openBracUS,
            closeBrac: Scancode.closeBracUS,
            quoteUS: Scancode.quoteUS,
            backslash: Scancode.backslashUS,
            // undefined: _unusedUS1,
    ];
    foreach (kvp; commonScancodes.byKeyValue)
    {
        jpScancodes[kvp.key] = kvp.value;
        usScancodes[kvp.key] = kvp.value;
    }
}
///
unittest
{
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
///
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
