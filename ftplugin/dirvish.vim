" Only do this when not done yet for this buffer
if exists("b:dovish_ftplugin") 
  finish
endif
let b:dovish_ftplugin = 1

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

  let output = system("touch " . filepath)
  if v:shell_error
    call s:logError(cmd)
  endif

  " Reload the buffer
  normal R
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

  let output = system("mkdir " . dirpath)
  if v:shell_error
    call s:logError(output)
  endif

  normal R
endf

function! s:deleteItemUnderCursor() abort
  " Grab the line under the cursor. Each line is a filepath
  let target = trim(getline('.'))
  let cmd = "trash " . target
  " Feed the filepath to a delete command like, rm or trash
  output = system("trash " . target)
  if v:shell_error
    call s:logError(output)
  endif
  " Reload the buffer
  normal R
endfunction

function! s:renameItemUnderCursor() abort
  let target = trim(getline('.'))
  let filename = fnamemodify(target, ':t')
  let newname = input('Rename: ', filename)
  let cmd = printf('mv "%s" "%s"', target, expand("%") . newname)
  let output = system(cmd)
  if v:shell_error
    call s:logError(output)
  endif
  normal R
endfunction

function! s:isPreviouslyYankedItemValid() abort
  if len(s:yanked) < 1
    return 0
  endif

  for target in s:yanked
    if target == ''
      return 0
    endif
  endfor

  return 1
endfunction

function! s:promptUserForRenameOrSkip(filename) abort
  let renameOrSkip = confirm(a:filename." already exists.", "&Rename\n&Abort", 2)
  if renameOrSkip != 1
    return ''
  endif
  return input('Rename to: ', a:filename)
endfunction

function! s:moveYankedItemToCurrentDirectory() abort
  if !s:isPreviouslyYankedItemValid()
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
      let cmd = printf('mv %s %s', item, destinationDir . directoryName)
    else
      if (!empty(glob(destinationDir . filename)))
        let filename = s:promptUserForRenameOrSkip(filename)
        redraw
        if filename == ''
          return
        endif
      endif
      let cmd = printf('mv %s %s', item, destinationDir . filename)
    endif

    let output = system(cmd)
    if v:shell_error
      call s:logError(output)
    endif
  endfor
  norm! R
endfunction

function! s:copyYankedItemToCurrentDirectory() abort
  if !s:isPreviouslyYankedItemValid()
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
      let cmd = printf('cp -r %s %s', item, destinationDir . directoryName)
    else
      if (!empty(glob(destinationDir . filename)))
        let filename = s:promptUserForRenameOrSkip(filename)
        redraw
        if filename == ''
          return
        endif
      endif

      let cmd = printf('cp %s %s', item, destinationDir . filename)
    endif

    let output = system(cmd)
    if v:shell_error
      call s:logError(output)
    endif
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

function! s:logError(error) abort
  " clear any current cmdline msg
  redraw
  echohl WarningMsg | echomsg a:error | echohl None
endfunction

nnoremap <silent><buffer> <Plug>(dovish_create_file) :<C-U> call <SID>createFile()<CR>
nnoremap <silent><buffer> <Plug>(dovish_create_directory) :<C-U> call <SID>createDirectory()<CR>
nnoremap <silent><buffer> <Plug>(dovish_rename) :<C-U> call <SID>renameItemUnderCursor()<CR>
nnoremap <silent><buffer> <Plug>(dovish_delete) :<C-U> call <SID>deleteItemUnderCursor()<CR>
nnoremap <silent><buffer> <Plug>(dovish_yank) :<C-U> call <SID>copyFilePathUnderCursor()<CR>
xnoremap <silent><buffer> <Plug>(dovish_yank) :<C-U> call <SID>copyVisualSelection()<CR>
nnoremap <silent><buffer> <Plug>(dovish_copy) :<C-U> call <SID>copyYankedItemToCurrentDirectory()<CR>
nnoremap <silent><buffer> <Plug>(dovish_move) :<C-U> call <SID>moveYankedItemToCurrentDirectory()<CR>

if !exists("g:dirvish_dovish_map_keys")
  let g:dirvish_dovish_map_keys = 1
endif

if g:dirvish_dovish_map_keys
  if !hasmapto('<Plug>(dovish_create_file)', 'n')
    execute 'nmap <silent><buffer> a <Plug>(dovish_create_file)'
  endif
  if !hasmapto('<Plug>(dovish_create_directory)', 'n')
    execute 'nmap <silent><buffer> A <Plug>(dovish_create_directory)'
  endif
  if !hasmapto('<Plug>(dovish_delete)', 'n')
    execute 'nmap <silent><buffer> dd <Plug>(dovish_delete)'
  endif
  if !hasmapto('<Plug>(dovish_rename)', 'n')
    execute 'nmap <silent><buffer> r <Plug>(dovish_rename)'
  endif
  if !hasmapto('<Plug>(dovish_yank)', 'n')
    execute 'nmap <silent><buffer> yy <Plug>(dovish_yank)'
  endif
  if !hasmapto('<Plug>(dovish_yank)', 'v')
    execute 'xmap <silent><buffer> yy <Plug>(dovish_yank)'
  endif
  if !hasmapto('<Plug>(dovish_copy)', 'n')
    execute 'nmap <silent><buffer> pp <Plug>(dovish_copy)'
  endif
  if !hasmapto('<Plug>(dovish_move)', 'n')
    execute 'nmap <silent><buffer> PP <Plug>(dovish_move)'
  endif
endif
