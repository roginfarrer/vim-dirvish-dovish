# 🧰 vim-dirvish-doish

> The file manipulation commands for [vim-dirvish](https://github.com/justinmk/vim-dirvish) that you've always wanted

## Available Commands

* `:CreateFile`: Create a new file with a given name in the current buffer's directory
* `:DeleteItemUnderCursor`: Delete the file under the cursor and refresh the filelist
* `:RenameItemUnderCursor`: Rename the file under the cursor and refresh the filelist

## Usage

Example bindings that are mapped only within a dirvish buffer

```vim
function! s:dirvish_maps()
  nnoremap <silent><buffer> I :CreateFile<CR>
  nnoremap <silent><buffer> dd :DeleteItemUnderCursor<CR>
  nnoremap <silent><buffer> cc :RenameItemUnderCursor<CR>
endfunction

augroup dirvish_config
  autocmd!
  autocmd FileType dirvish call s:dirvish_maps()
augroup END
```
