" Neovim configuration - Cognitify
" (c) 2026 Ramon Brooker <rbrooker@aeo3.io>
" Installed only when Neovim is present. Requires xclip (X11) or wl-clipboard (Wayland).

" Source shared vimrc for common settings (number, hlsearch, etc.)
if filereadable(expand("~/.vimrc"))
    source ~/.vimrc
endif

" Use system clipboard for yank/paste (requires xclip or wl-clipboard)
set clipboard+=unnamedplus

" Ensure line numbers and search highlight (in case vimrc not present)
set number
set hlsearch
