# 🧰 vim-dirvish-dovish

> The file manipulation commands for [vim-dirvish][dirvish] that you've always wanted

Have only tested on MacOS and Neovim, but it should work with Vim.

## Installation

Make sure [dirvish.vim][dirvish] is installed, and install with your favorite package manager:

```vim
Plug 'justinmk/vim-dirvish'
Plug 'roginfarrer/vim-dirvish-dovish'
```

## Mappings


| Function                                | Default | Key                               |
| --------------------------------------- | ------- | --------------------------------- |
| Create file                             | `n`     | `<Plug>(dovish_create_file)`      |
| Create directory                        | `N`     | `<Plug>(dovish_create_directory)` |
| Delete under cursor                     | `dd`    | `<Plug>(dovish_delete)`           |
| Rename under cursor                     | `r`     | `<Plug>(dovish_rename)`           |
| Yank under cursor (or visual selection) | `yy`    | `<Plug>(dovish_yank)`             |
| Copy file to current directory          | `pp`    | `<Plug>(dovish_copy)`             |
| Move file to current directory          | `PP`    | `<Plug>(dovish_move)`             |

You can unmap all of the maps above and set your own (mine are below). Add this to `ftplugin/dirvish.vim`:

```vim
" unmap all default mappings
let g:dirvish_dovish_map_keys = 0

" unmap dirvish default
unmap <buffer> p

" Your preferred mappings
nmap <silent><buffer> n <Plug>(dovish_create_file)
nmap <silent><buffer> N <Plug>(dovish_create_directory)
nmap <silent><buffer> dd <Plug>(dovish_delete)
nmap <silent><buffer> r <Plug>(dovish_rename)
nmap <silent><buffer> yy <Plug>(dovish_yank)
xmap <silent><buffer> yy <Plug>(dovish_yank)
nmap <silent><buffer> p <Plug>(dovish_copy)
nmap <silent><buffer> P <Plug>(dovish_move)
```

[dirvish]: https://github.com/justinmk/vim-dirvish
