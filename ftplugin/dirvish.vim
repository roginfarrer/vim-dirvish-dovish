if exists("g:loaded_dirvish_doish") || &cp || v:version < 700
  finish
endif
let g:loaded_dirvish_doish = 1

command! CreateFile call s:createFile()
command! CreateDirectory call s:createDirectory()
command! RenameItemUnderCursor call s:renameItemUnderCursor()
command! DeleteItemUnderCursor call s:deleteItemUnderCursor()
command! CopyFilePathUnderCursor call s:copyFilePathUnderCursor()
command! CopyVisualSelection call s:copyVisualSelection()
command! CopyToDirectory call s:copyYankedItemToCurrentDirectory()
command! MoveToDirectory call s:moveYankedItemToCurrentDirectory()

" https://stackoverflow.com/a/47051271
function! s:getVisualSelection()
  if mode()=="v"
        let [line_start, column_start] = getpos("v")[1:2]
        let [line_end, column_end] = getpos(".")[1:2]
    else
        let [line_start, column_start] = getpos("'<")[1:2]
        let [line_end, column_end] = getpos("'>")[1:2]
    end
    if (line2byte(line_start)+column_start) > (line2byte(line_end)+column_end)
        let [line_start, column_start, line_end, column_end] =
        \   [line_end, column_end, line_start, column_start]
    end
    let lines = getline(line_start, line_end)
    if len(lines) == 0
            return ''
    endif
    let lines[-1] = lines[-1][: column_end - 1]
    let lines[0] = lines[0][column_start - 1:]
    return lines
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
  if len(s:yanked) < 1
    return false
  endif

  for target in s:yanked
    if target == ''
      return false
    endif
  endfor

  return true
endfunction

function! s:promptUserForRenameOrSkip(filename) abort
  let renameOrSkip = confirm(a:filename." already exists.", "&Rename\n&Abort", 2)
  if renameOrSkip != 1
    return ''
  endif
  return input('Rename to: ', a:filename)
endfunction

function! s:moveYankedItemToCurrentDirectory() abort
  if !IsPreviouslyYankedItemValid()
    echomsg 'Select a path first!'
    return
  endif

  let cwd = getcwd()
  let destinationDir = expand("%")
  for i in s:yanked
    let item = i
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
  endfor
  norm! R
endfunction

function! s:copyYankedItemToCurrentDirectory() abort
  if !IsPreviouslyYankedItemValid()
    echomsg 'Select a path first!'
    return
  endif

  let cwd = getcwd()
  let destinationDir = expand("%")

  for i in s:yanked
    let item = i
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
  endfor

  norm! R
endfunction

function! s:copyFilePathUnderCursor() abort
  let s:yanked = [trim(getline('.'))]
endfunction

function! s:copyVisualSelection() abort
  let lines = s:getVisualSelection()
  let s:yanked = lines
endfunction
