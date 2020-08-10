if exists("g:loaded_dirvish_doish") || &cp || v:version < 700
  finish
endif
let g:loaded_dirvish_doish = 1

command! CreateFile call s:createFile()
command! CreateDirectory call s:createDirectory()
command! RenameItemUnderCursor call s:renameItemUnderCursor()
command! DeleteItemUnderCursor call s:deleteItemUnderCursor()
command! CopyFilePathUnderCursor call s:copyFilePathUnderCursor()
command! CopyToDirectory call s:copyYankedItemToCurrentDirectory()
command! MoveToDirectory call s:moveYankedItemToCurrentDirectory()

" Not used right now
function! s:getVisualSelection()
    " Why is this not a built-in Vim script function?!
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
endfunction

function! s:createFile() abort
  " Prompt for new filename
  let filename = input('File name: ')
  if trim(filename) == ''
    return
  endif
  " Append filename to the path of the current buffer
  let filepath = expand("%") . filename
  " Create the file
  silent execute(printf(':!touch "%s"', filepath))
  " Reload the buffer
  normal! R
endf

function! s:createDirectory() abort
  let dirname = input('Directory name: ')
  if trim(dirname) == ''
    return
  endif
  let dirpath = expand("%") . dirname
  if isdirectory(dirpath)
    redraw
    echomsg printf('"%s" already exists.', dirpath)
    return
  endif
  let cmd = printf(':!mkdir "%s"', dirpath)
  silent execute(cmd)
  normal! R
endf

function! s:deleteItemUnderCursor() abort
  " Grab the line under the cursor. Each line is a filepath
  let target = trim(getline('.'))
  " Feed the filepath to a delete command like, rm or trash
  silent execute(printf(':!trash %s', target))
  " Reload the buffer
  normal! R
endfunction

function! s:renameItemUnderCursor() abort
  let target = trim(getline('.'))
  let filename = fnamemodify(target, ':t')
  let newname = input('Rename: ', filename)
  silent execute(printf(':!mv "%s" "%s"', target, expand("%") . newname))
  normal! R
endfunction

function! s:isPreviouslyYankedItemValid() abort
  return @d != ''
endfunction

function! s:promptUserForRenameOrSkip(filename) abort
  let renameOrSkip = confirm(a:filename." already exists.", "&Rename\n&Abort", 2)
  if renameOrSkip != 1
    return ''
  endif
  return input('Rename into: ', a:filename)
endfunction

function! s:moveYankedItemToCurrentDirectory() abort
  if !IsPreviouslyYankedItemValid()
    echomsg 'Select a path first!'
    return
  endif

  let cwd = getcwd()
  let destinationDir = expand("%")
  let item = @d
  let filename = fnamemodify(item, ':t')
  let directoryName = split(fnamemodify(item, ':p:h'), '/')[-1]

  if isdirectory(item)
    if (isdirectory(destinationDir . directoryName))
      let directoryName = s:promptUserForRenameOrSkip(directoryName)
      redraw
      if directoryName == ''
        return
      endif
    endif
    let cmd = printf(':!mv %s %s', item, destinationDir . directoryName)
  else
    if (!empty(glob(destinationDir . filename)))
      let filename = s:promptUserForRenameOrSkip(filename)
      redraw
      if filename == ''
        return
      endif
    endif

    let cmd = printf(':!mv %s %s', item, destinationDir . filename)
  endif

  silent execute(cmd)
  norm! R
endfunction

function! s:copyYankedItemToCurrentDirectory() abort
  if !IsPreviouslyYankedItemValid()
    echomsg 'Select a path first!'
    return
  endif

  let cwd = getcwd()
  let destinationDir = expand("%")
  let item = @d
  let filename = fnamemodify(item, ':t')
  let directoryName = split(fnamemodify(item, ':p:h'), '/')[-1]

  if isdirectory(item)
    if (isdirectory(destinationDir . directoryName))
      let directoryName = s:promptUserForRenameOrSkip(directoryName)
      redraw
      if directoryName == ''
        return
      endif
    endif
    let cmd = printf(':!cp -r %s %s', item, destinationDir . directoryName)
  else
    if (!empty(glob(destinationDir . filename)))
      let filename = s:promptUserForRenameOrSkip(filename)
      redraw
      if filename == ''
        return
      endif
    endif

    let cmd = printf(':!cp %s %s', item, destinationDir . filename)
  endif

  silent execute(cmd)
  norm! R
endfunction

function! s:copyFilePathUnderCursor() abort
  normal! ^"dy$
endfunction

function! s:visual() abort
  let lines = s:get_visual_selection()
  echomsg lines
endfunction

function! s:reload() abort
  if &filetype ==? 'dirvish'
    Dirvish %
  endif
endfunction
