runtime! plugin/auto-pairs.vim

describe 'test'

  before
    filetype indent on
    set backspace=indent,eol,start
    new
  end

  after
    close!
  end

  it 'auto-closes parentheses'
    normal i(
    Expect getline(1) == '()'
  end

  it 'skips closing parenthesis'
    put! = 'something(arg)'
    execute 'normal f)'
    execute "normal i);\<esc>"
    Expect getline(1) == 'something(arg);'
  end

  it 'normally closes parenthesis'
    put! = 'something(arg'
    execute "normal A);\<esc>"
    Expect getline(1) == 'something(arg);'
  end

  it 'auto-deletes parentheses'
    execute "normal i(\<bs>"
    Expect getline(1) == ''
  end

  it '<cr> inserts extra new line'
    set filetype=javascript
    setlocal noexpandtab shiftwidth=4 tabstop=4
    execute "normal i{\<cr>test\<esc>"
    Expect getline(1) == '{'
    Expect getline(2) == "\ttest"
    Expect getline(3) == '}'
  end

  it '<cr> inserts extra new line (2)'
    set filetype=javascript
    setlocal noexpandtab shiftwidth=4 tabstop=4
    put! = 'if (a) {'
    put = 'debug;'
    put = '}'
    normal gg=G
    normal 2G
    execute "normal o{\<cr>test\<esc>"
    Expect getline(1) == 'if (a) {'
    Expect getline(2) == "\tdebug;"
    Expect getline(3) == "\t{"
    Expect getline(4) == "\t\ttest"
    Expect getline(5) == "\t}"
  end

end
