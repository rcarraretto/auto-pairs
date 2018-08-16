Auto Pairs
==========
Insert or delete brackets, parens, quotes in pair.

Installation
------------
copy plugin/auto-pairs.vim to ~/.vim/plugin

or if you are using `pathogen`:

```git clone git://github.com/jiangmiao/auto-pairs.git ~/.vim/bundle/auto-pairs```

Features
--------
*   Insert in pair

        input: [
        output: [|]

*   Delete in pair

        input: foo[<BS>]
        output: foo

*   Insert new indented line after Return

        input: {|} (press <CR> at |)
        output: {
            |
        }

*   Skip ' when inside a word

        input: foo| (press ' at |)
        output: foo'

*   Skip closed bracket.

        input: []
        output: []

*   Ignore auto pair when previous character is \

        input: "\'
        output: "\'"

*   Fast Wrap

        input: |'hello' (press (<M-e> at |)
        output: ('hello')

        wrap string, only support c style string
        input: |'h\\el\'lo' (press (<M-e> at |)
        output ('h\\ello\'')

        input: |[foo, bar()] (press (<M-e> at |)
        output: ([foo, bar()])

*   Quick move char to closed pair

        input: (|){["foo"]} (press <M-}> at |)
        output: ({["foo"]}|)

        input: |[foo, bar()] (press (<M-]> at |)
        output: ([foo, bar()]|)

*   Quick jump to closed pair.

        input:
        {
            something;|
        }

        (press } at |)

        output:
        {

        }|

*   Support ``` ''' and """

        input:
            '''

        output:
            '''|'''

*   Delete Repeated Pairs in one time

        input: """|""" (press <BS> at |)
        output: |

        input: {{|}} (press <BS> at |)
        output: |

        input: [[[[[[|]]]]]] (press <BS> at |)
        output: |

Shortcuts
---------

    System Shortcuts:
        <CR>  : Insert new indented line after return if cursor in blank brackets or quotes.
        <BS>  : Delete brackets in pair
        <M-p> : Toggle Autopairs (g:AutoPairsShortcutToggle)
        <M-e> : Fast Wrap (g:AutoPairsShortcutFastWrap)
        <M-n> : Jump to next closed pair (g:AutoPairsShortcutJump)
        <M-b> : BackInsert (g:AutoPairsShortcutBackInsert)

    If <M-p> <M-e> or <M-n> conflict with another keys or want to bind to another keys, add

        let g:AutoPairsShortcutToggle = '<another key>'

    to .vimrc, if the key is empty string '', then the shortcut will be disabled.

Options
-------
*   g:AutoPairs

        Default: {'(':')', '[':']', '{':'}',"'":"'",'"':'"', '`':'`'}

*   b:AutoPairs

        Default: g:AutoPairs

        Buffer level pairs set.

*   g:AutoPairsShortcutToggle

        Default: '<M-p>'

        The shortcut to toggle autopairs.

*   g:AutoPairsShortcutFastWrap

        Default: '<M-e>'

        Fast wrap the word. all pairs will be consider as a block (include <>).
        (|)'hello' after fast wrap at |, the word will be ('hello')
        (|)<hello> after fast wrap at |, the word will be (<hello>)

*   g:AutoPairsShortcutJump

        Default: '<M-n>'

        Jump to the next closed pair

*   g:AutoPairsMapBS

        Default : 1

        Map <BS> to delete brackets, quotes in pair
        execute 'inoremap <buffer> <silent> <BS> <C-R>=AutoPairsDelete()<CR>'

*   g:AutoPairsMapCh

        Default : 1

        Map <C-h> to delete brackets, quotes in pair

*   g:AutoPairsMapCR

        Default : 1

        Map <CR> to insert a new indented line if cursor in (|), {|} [|], '|', "|"
        execute 'inoremap <buffer> <silent> <CR> <C-R>=AutoPairsReturn()<CR>'

*   g:AutoPairsCenterLine

        Default : 1

        When g:AutoPairsMapCR is on, center current line after return if the line is at the bottom 1/3 of the window.

*   g:AutoPairsMultilineClose

        Default : 1

        When you press the key for the closing pair (e.g. `)`) it jumps past it.
        If set to 1, then it'll jump to the next line, if there is only whitespace.
        If set to 0, then it'll only jump to a closing pair on the same line.

*   g:AutoPairsShortcutBackInsert

        Default : <M-b>

        Work with FlyMode, insert the key at the Fly Mode jumped postion

*   g:AutoPairsMoveCharacter

        Default: "()[]{}\"'"

        Map <M-(> <M-)> <M-[> <M-]> <M-{> <M-}> <M-"> <M-'> to
        move character under the cursor to the pair.

Buffer Level Pairs Setting
--------------------------

Set b:AutoPairs before BufEnter

eg:

    " When the filetype is FILETYPE then make AutoPairs only match for parenthesis
    au Filetype FILETYPE let b:AutoPairs = {"(": ")"}

TroubleShooting
---------------
    The script will remap keys ([{'"}]) <BS>,
    If auto pairs cannot work, use :imap ( to check if the map is corrected.
    The correct map should be <C-R>=AutoPairsInsert("\(")<CR>
    Or the plugin conflict with some other plugins.
    use command :call AutoPairsInit() to remap the keys.


* How to insert parens purely

    There are 3 ways

    1. use Ctrl-V ) to insert paren without trigger the plugin.

    2. use Alt-P to turn off the plugin.

    3. use DEL or <C-O>x to delete the character insert by plugin.

* Swedish Character Conflict

    Because AutoPairs uses Meta(Alt) key as shortcut, it is conflict with some Swedish character such as å.
    To fix the issue, you need remap or disable the related shortcut.

Known Issues
-----------------------
Breaks '.' - [issue #3](https://github.com/jiangmiao/auto-pairs/issues/3)

    Description: After entering insert mode and inputing `[hello` then leave insert
                 mode by `<ESC>`. press '.' will insert 'hello' instead of '[hello]'.
    Reason: `[` actually equals `[]\<LEFT>` and \<LEFT> will break '.'.
            After version 7.4.849, Vim implements new keyword <C-G>U to avoid the break
    Solution: Update Vim to 7.4.849+

Contributors
------------
* [camthompson](https://github.com/camthompson)

## Developing

### Tests

Make sure `rbenv` is installed and configured, so the system ruby is not being used.

Then `bundle install`.

- `rake test` or
- Install the [vim-test](https://github.com/janko-m/vim-test) plugin and e.g. call `:TestSuite` on a test file

License
-------

Copyright (C) 2011-2013 Miao Jiang

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
