" Insert or delete brackets, parens, quotes in pairs.
" Maintainer:	JiangMiao <jiangfriend@gmail.com>
" Contributor: camthompson
" Last Change:  2017-06-17
" Version: 1.3.3
" Homepage: http://www.vim.org/scripts/script.php?script_id=3599
" Repository: https://github.com/jiangmiao/auto-pairs
" License: MIT

if exists('g:AutoPairsLoaded') || &cp
  finish
end
let g:AutoPairsLoaded = 1

let s:PairsDict = {'(': ')', '[': ']', '{': '}', "'": "'", '"': '"', '`': '`'}

" 7.4.849 support <C-G>U to avoid breaking '.'
" Issue talk: https://github.com/jiangmiao/auto-pairs/issues/3
" Vim note: https://github.com/vim/vim/releases/tag/v7.4.849
let s:Go = "\<C-G>U"

let s:Left = s:Go."\<LEFT>"
let s:Right = s:Go."\<RIGHT>"


" Will auto generated {']' => '[', ..., '}' => '{'}in initialize.
let g:AutoPairsClosedPairs = {}


function! AutoPairsInsert(key)
  if !b:autopairs_enabled
    return a:key
  end

  let line = getline('.')
  let pos = col('.') - 1
  let before = strpart(line, 0, pos)
  let after = strpart(line, pos)
  let next_chars = split(after, '\zs')
  let current_char = get(next_chars, 0, '')
  let next_char = get(next_chars, 1, '')
  let prev_chars = split(before, '\zs')
  let prev_char = get(prev_chars, -1, '')

  let eol = 0
  if col('$') -  col('.') <= 1
    let eol = 1
  end

  " Ignore auto close if prev character is \
  if prev_char == '\'
    return a:key
  end

  " The key is difference open-pair, then it means only for ) ] } by default
  if !has_key(s:PairsDict, a:key)
    let b:autopairs_saved_pair = [a:key, getpos('.')]

    " Skip the character if current character is the same as input
    if current_char == a:key
      return s:Right
    end

      " Skip the character if next character is space
      if current_char == ' ' && next_char == a:key
        return s:Right.s:Right
      end

      " Skip the character if closed pair is next character
      if current_char == ''
        let next_char = matchstr(line, '\s*\zs.')
        if next_char == a:key
          return "\<ESC>e^a"
        endif
      endif

    " Insert directly if the key is not an open key
    return a:key
  end

  let open = a:key
  let close = s:PairsDict[open]

  if current_char == close && open == close
    return s:Right
  end

  " Ignore auto close ' if follows a word
  " MUST after closed check. 'hello|'
  if a:key == "'" && prev_char =~ '\v\w'
    return a:key
  end

  " support for ''' ``` and """
  if open == close
    " The key must be ' " `
    let pprev_char = line[col('.')-3]
    if pprev_char == open && prev_char == open
      " Double pair found
      return repeat(a:key, 4) . repeat(s:Left, 3)
    end
  end

  let quotes_num = 0
  " Ignore comment line for vim file
  if &filetype == 'vim' && a:key == '"'
    if before =~ '^\s*$'
      return a:key
    end
    if before =~ '^\s*"'
      let quotes_num = -1
    end
  end

  " Smart quotes
  " Keep quote number is odd.
  " Because quotes should be matched in the same line in most of situation
  if open == close
    " Remove \\ \" \'
    let cleaned_line = substitute(line, '\v(\\.)', '', 'g')
    let n = quotes_num
    let pos = 0
    while 1
      let pos = stridx(cleaned_line, open, pos)
      if pos == -1
        break
      end
      let n = n + 1
      let pos = pos + 1
    endwhile
    if n % 2 == 1
      return a:key
    endif
  endif

  return open.close.s:Left
endfunction

function! AutoPairsDelete()
  if !b:autopairs_enabled
    return "\<BS>"
  end

  let line = getline('.')
  let pos = col('.') - 1
  let current_char = get(split(strpart(line, pos), '\zs'), 0, '')
  let prev_chars = split(strpart(line, 0, pos), '\zs')
  let prev_char = get(prev_chars, -1, '')
  let pprev_char = get(prev_chars, -2, '')

  if pprev_char == '\'
    return "\<BS>"
  end

  " Delete last two spaces in parens, work with MapSpace
  if has_key(s:PairsDict, pprev_char) && prev_char == ' ' && current_char == ' '
    return "\<BS>\<DEL>"
  endif

  if has_key(s:PairsDict, prev_char)
    let close = s:PairsDict[prev_char]
    if match(line,'^\s*'.close, col('.')-1) != -1
      " Delete (|___)
      let space = matchstr(line, '^\s*', col('.')-1)
      return "\<BS>". repeat("\<DEL>", len(space)+1)
    elseif match(line, '^\s*$', col('.')-1) != -1
      " Delete (|__\n___)
      let nline = getline(line('.')+1)
      if nline =~ '^\s*'.close
        if &filetype == 'vim' && prev_char == '"'
          " Keep next line's comment
          return "\<BS>"
        end

        let space = matchstr(nline, '^\s*')
        return "\<BS>\<DEL>". repeat("\<DEL>", len(space)+1)
      end
    end
  end

  return "\<BS>"
endfunction

" string_chunk cannot use standalone
let s:string_chunk = '\v%(\\\_.|[^\1]|[\r\n]){-}'
let s:ss_pattern = '\v''' . s:string_chunk . ''''
let s:ds_pattern = '\v"'  . s:string_chunk . '"'

func! s:RegexpQuote(str)
  return substitute(a:str, '\v[\[\{\(\<\>\)\}\]]', '\\&', 'g')
endf

func! s:RegexpQuoteInSquare(str)
  return substitute(a:str, '\v[\[\]]', '\\&', 'g')
endf

" Search next open or close pair
func! s:FormatChunk(open, close)
  let open = s:RegexpQuote(a:open)
  let close = s:RegexpQuote(a:close)
  let open2 = s:RegexpQuoteInSquare(a:open)
  let close2 = s:RegexpQuoteInSquare(a:close)
  if open == close
    return '\v'.open.s:string_chunk.close
  else
    return '\v%(' . s:ss_pattern . '|' . s:ds_pattern . '|' . '[^'.open2.close2.']|[\r\n]' . '){-}(['.open2.close2.'])'
  end
endf

" Fast wrap the word in brackets
function! AutoPairsFastWrap()
  let line = getline('.')
  let current_char = line[col('.')-1]
  let next_char = line[col('.')]
  let open_pair_pattern = '\v[({\[''"]'
  let at_end = col('.') >= col('$') - 1
  normal! x
  " Skip blank
  if next_char =~ '\v\s' || at_end
    call search('\v\S', 'W')
    let line = getline('.')
    let next_char = line[col('.')-1]
  end

  if has_key(s:PairsDict, next_char)
    let followed_open_pair = next_char
    let inputed_close_pair = current_char
    let followed_close_pair = s:PairsDict[next_char]
    if followed_close_pair != followed_open_pair
      " TODO replace system searchpair to skip string and nested pair.
      " eg: (|){"hello}world"} will transform to ({"hello})world"}
      call searchpair('\V'.followed_open_pair, '', '\V'.followed_close_pair, 'W')
    else
      call search(s:FormatChunk(followed_open_pair, followed_close_pair), 'We')
    end
    return s:Right.inputed_close_pair.s:Left
  else
    normal! he
    return s:Right.current_char.s:Left
  end
endfunction

function! AutoPairsMap(key)
  " | is special key which separate map command from text
  let key = a:key
  if key == '|'
    let key = '<BAR>'
  end
  let escaped_key = substitute(key, "'", "''", 'g')
  " use expr will cause search() doesn't work
  execute 'inoremap <buffer> <silent> '.key." <C-R>=AutoPairsInsert('".escaped_key."')<CR>"

endfunction

function! AutoPairsToggle()
  if b:autopairs_enabled
    let b:autopairs_enabled = 0
    echo 'AutoPairs Disabled.'
  else
    let b:autopairs_enabled = 1
    echo 'AutoPairs Enabled.'
  end
  return ''
endfunction

function! AutoPairsReturn()
  if b:autopairs_enabled == 0
    return ''
  end
  let line = getline('.')
  let pline = getline(line('.')-1)
  let prev_char = pline[strlen(pline)-1]
  let cmd = ''
  let cur_char = line[col('.')-1]
  if has_key(s:PairsDict, prev_char) && s:PairsDict[prev_char] == cur_char
    " If equalprg has been set, then avoid call =
    " https://github.com/jiangmiao/auto-pairs/issues/24
    if &equalprg != ''
      return "\<ESC>".cmd."O"
    endif

    return "\<ESC>".cmd."=ko"
  end
  return ''
endfunction

function! AutoPairsInit()
  let b:autopairs_loaded  = 1
  if !exists('b:autopairs_enabled')
    let b:autopairs_enabled = 1
  end
  let b:AutoPairsClosedPairs = {}

  " buffer level map pairs keys
  for [open, close] in items(s:PairsDict)
    call AutoPairsMap(open)
    if open != close
      call AutoPairsMap(close)
    end
    let b:AutoPairsClosedPairs[close] = open
  endfor

  " Still use <buffer> level mapping for <BS> <SPACE>
    " Use <C-R> instead of <expr> for issue #14 sometimes press BS output strange words
    execute 'inoremap <buffer> <silent> <BS> <C-R>=AutoPairsDelete()<CR>'

  execute 'inoremap <buffer> <silent> <c-e> <C-R>=AutoPairsFastWrap()<CR>'

endfunction

function! s:ExpandMap(map)
  let map = a:map
  let map = substitute(map, '\(<Plug>\w\+\)', '\=maparg(submatch(1), "i")', 'g')
  return map
endfunction

function! AutoPairsTryInit()
  if exists('b:autopairs_loaded')
    return
  end

  " for auto-pairs starts with 'a', so the priority is higher than supertab and vim-endwise
  "
  " vim-endwise doesn't support <Plug>AutoPairsReturn
  " when use <Plug>AutoPairsReturn will cause <Plug> isn't expanded
  "
  " supertab doesn't support <SID>AutoPairsReturn
  " when use <SID>AutoPairsReturn  will cause Duplicated <CR>
  "
  " and when load after vim-endwise will cause unexpected endwise inserted.
  " so always load AutoPairs at last

  " Buffer level keys mapping
  " comptible with other plugin
      let info = maparg('<CR>', 'i', 0, 1)
      if empty(info)
        let old_cr = '<CR>'
        let is_expr = 0
      else
        let old_cr = info['rhs']
        let old_cr = s:ExpandMap(old_cr)
        let old_cr = substitute(old_cr, '<SID>', '<SNR>' . info['sid'] . '_', 'g')
        let is_expr = info['expr']
        let wrapper_name = '<SID>AutoPairsOldCRWrapper73'
      endif

    if old_cr !~ 'AutoPairsReturn'
      if is_expr
        " remap <expr> to `name` to avoid mix expr and non-expr mode
        execute 'inoremap <buffer> <expr> <script> '. wrapper_name . ' ' . old_cr
        let old_cr = wrapper_name
      end
      " Always silent mapping
      execute 'inoremap <script> <buffer> <silent> <CR> '.old_cr.'<SID>AutoPairsReturn'
    end
  call AutoPairsInit()
endfunction

" Always silent the command
inoremap <silent> <SID>AutoPairsReturn <C-R>=AutoPairsReturn()<CR>
imap <script> <Plug>AutoPairsReturn <SID>AutoPairsReturn


au BufEnter * :call AutoPairsTryInit()
