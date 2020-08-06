if exists("g:loaded_dirvish_doish") || &cp || v:version < 700
    finish
endif
let g:loaded_dirvish_doish = 1

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

function! s:deleteItemUnderCursor() abort
  " Grab the line under the cursor. Each line is a filepath
  let target = trim(getline('.'))
  " Feed the filepath to a delete command like, rm or trash
  silent execute(printf(':!trash %s', target))
  " Reload the buffer
  normal! R
endfunction

function! s:RenameItemUnderCursor() abort
  let target = trim(getline('.'))
  let filename = fnamemodify(target, ':t')
  let newname = input('Rename: ', filename)
  silent execute(printf(':!mv "%s" "%s"', target, expand("%") . newname))
  normal! R
endfunction

command! CreateFile call s:createFile()
command! DeleteItemUnderCursor call s:deleteItemUnderCursor()
command! RenameItemUnderCursor call s:renameItemUnderCursor()
