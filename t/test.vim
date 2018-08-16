source plugin/auto-pairs.vim

describe 'test'

  before
    new
  end

  after
    close!
  end

  it 'closes parentheses'
    normal i(
    Expect getline(1) == '()'
  end

  it 'deletes parentheses'
    execute "normal i(\<bs>"
    Expect getline(1) == ''
  end

end
