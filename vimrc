" Enable syntax highlighting and file type detection
filetype plugin indent on
syntax on

" General settings
set nu
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent
set incsearch
set ruler

" Load rust.vim from the runtime path
if empty(glob("~/.vim/pack/plugins/start/rust.vim"))
  silent !mkdir -p ~/.vim/pack/plugins/start
  silent !git clone https://github.com/rust-lang/rust.vim ~/.vim/pack/plugins/start/rust.vim
endif
set runtimepath+=~/.vim/pack/plugins/start/rust.vim

" Function to check and install coc.nvim if it's not already installed
function! InstallCocNvim()
  if !isdirectory(expand("~/.vim/pack/plugins/start/coc.nvim"))
    echo "Installing coc.nvim..."
    silent !mkdir -p ~/.vim/pack/plugins/start
    silent !git clone --branch release https://github.com/neoclide/coc.nvim.git ~/.vim/pack/plugins/start/coc.nvim
    echo "Installing coc.nvim dependencies..."
    silent !cd ~/.vim/pack/plugins/start/coc.nvim && npm install
  endif
endfunction

" Ensure coc-settings.json exists with necessary configuration
function! EnsureCocSettings()
  let s:settings_file = expand("~/.vim/coc-settings.json")
  if filereadable(s:settings_file)
    let l:settings = readfile(s:settings_file)
  else
    let l:settings = []
  endif

  let l:updated_settings = [
        \ "{",
        \ "  \"rust-analyzer.cargo.loadOutDirsFromCheck\": true,",
        \ "  \"rust-analyzer.procMacro.enable\": true,",
        \ "  \"rust-analyzer.checkOnSave.command\": \"clippy\",",
        \ "  \"rust-analyzer.checkOnSave.extraArgs\": [\"--\", \"-W\", \"clippy::pedantic\"],",
        \ "  \"rust-analyzer.assist.importGranularity\": \"module\",",
        \ "  \"rust-analyzer.assist.importPrefix\": \"by_crate\",",
        \ "  \"rust-analyzer.completion.autoimport.enable\": true,",
        \ "  \"suggest.floatConfig\": {",
        \ "    \"maxWidth\": 120,",
        \ "    \"maxHeight\": 120",
        \ "  },",
        \ "  \"rust-analyzer.lens.enable\": true,",
        \ "  \"rust-analyzer.lens.methodReferences\": true,",
        \ "  \"rust-analyzer.lens.references\": true,",
        \ "  \"rust-analyzer.lens.debug\": true,",
        \ "  \"rust-analyzer.inlayHints.enable\": true,",
        \ "  \"rust-analyzer.inlayHints.typeHints\": true,",
        \ "  \"rust-analyzer.inlayHints.parameterHints\": true,",
        \ "  \"rust-analyzer.inlayHints.chainingHints\": true,",
        \ "  \"rust-analyzer.inlayHints.returnHints\": true",
        \ "}"
        \ ]

  if len(l:settings) == 0 || l:settings != l:updated_settings
    call writefile(l:updated_settings, s:settings_file)
  endif
endfunction

" Run the installation and configuration functions on Vim startup
autocmd VimEnter * call InstallCocNvim()
autocmd VimEnter * call EnsureCocSettings()

" Load coc.nvim from the Vim runtime path
set runtimepath^=~/.vim/pack/plugins/start/coc.nvim

" Set up coc.nvim for Rust
let g:coc_global_extensions = ["coc-rust-analyzer"]

" Key mappings for coc.nvim
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Auto-complete
inoremap <silent><expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <silent><expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"

" Show diagnostics on cursor hold
autocmd CursorHold * silent call CocActionAsync("diagnosticInfo")

" Automatically format on save with coc.nvim
autocmd BufWritePre *.rs :call CocAction("format")

" Key mappings to scroll the documentation window
" Insert mode scrolling
inoremap <silent><expr> <C-f> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(1)\<CR>" : "\<C-f>"
inoremap <silent><expr> <C-b> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(0)\<CR>" : "\<C-b>"
" Normal mode scrolling
nnoremap <silent><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <silent><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
" Visual mode scrolling
vnoremap <silent><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
vnoremap <silent><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"

" Set colorscheme to gruvbox
if empty(glob("~/.vim/pack/plugins/start/gruvbox"))
  silent !mkdir -p ~/.vim/pack/plugins/start
  silent !git clone https://github.com/morhetz/gruvbox ~/.vim/pack/plugins/start/gruvbox
endif
colorscheme gruvbox

" Function to toggle rust-analyzer inlay hints
function! ToggleInlayHints()
  let hints_enabled = get(g:, "rust_analyzer_inlay_hints", 1)
  if hints_enabled
    call coc#config("rust-analyzer.inlayHints.typeHints", v:false)
    call coc#config("rust-analyzer.inlayHints.parameterHints", v:false)
    call coc#config("rust-analyzer.inlayHints.chainingHints", v:false)
    call coc#config("rust-analyzer.inlayHints.returnHints", v:false)
    let g:rust_analyzer_inlay_hints = 0
  else
    call coc#config("rust-analyzer.inlayHints.typeHints", v:true)
    call coc#config("rust-analyzer.inlayHints.parameterHints", v:true)
    call coc#config("rust-analyzer.inlayHints.chainingHints", v:true)
    call coc#config("rust-analyzer.inlayHints.returnHints", v:true)
    let g:rust_analyzer_inlay_hints = 1
  endif
  execute "CocRestart"
endfunction

" Key bindings to toggle type hints
nnoremap <leader>th :call ToggleInlayHints()<CR>

" Key binding to trigger code actions (including auto-import)
nnoremap <leader>ai :call CocActionAsync("codeAction")<CR>

