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

" Use <C-G>U to avoid breaking '.'
" Issue talk: https://github.com/jiangmiao/auto-pairs/issues/3
" Vim note: https://github.com/vim/vim/releases/tag/v7.4.849
let s:Left = "\<C-G>U\<LEFT>"
let s:Right = "\<C-G>U\<RIGHT>"

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

  " Ignore auto close if prev character is \
  if prev_char == '\'
    return a:key
  end

  " The key is difference open-pair, then it means only for ) ] } by default
  if !has_key(s:PairsDict, a:key)
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
  let cur_char = line[col('.')-1]
  if has_key(s:PairsDict, prev_char) && s:PairsDict[prev_char] == cur_char
    " If equalprg has been set, then avoid call =
    " https://github.com/jiangmiao/auto-pairs/issues/24
    if &equalprg != ''
      return "\<ESC>O"
    endif
    return "\<ESC>=ko"
  end
  return ''
endfunction

function! AutoPairsInit()
  let b:autopairs_loaded  = 1
  if !exists('b:autopairs_enabled')
    let b:autopairs_enabled = 1
  end

  " buffer level map pairs keys
  for [open, close] in items(s:PairsDict)
    call AutoPairsMap(open)
    if open != close
      call AutoPairsMap(close)
    end
  endfor

  " Still use <buffer> level mapping for <BS> <SPACE>
  " Use <C-R> instead of <expr> for issue #14 sometimes press BS output strange words
  execute 'inoremap <buffer> <silent> <BS> <C-R>=AutoPairsDelete()<CR>'
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
