if exists("g:loaded_tea_plugin")
  finish
endif

let g:loaded_tea_plugin = 1

let g:tea_enabled = 0
let g:tea_timer_id = -1


function! Tea(timer)
    if &modified
        silent! up!
    endif
    let l:pos = getpos(".")
    silent! e!
    call setpos(".", l:pos)
endfunction

function! TeaEnable()
  if g:tea_enabled
    echo "Tea plugin is already enabled!"
 else
    let g:tea_enabled = 1
    echo "Tea plugin enabled!"
    let g:tea_timer_id = timer_start(3000, 'Tea', {'repeat': -1})
  endif
endfunction

function! TeaDisable()
  if !g:tea_enabled
    echo "Tea plugin is already disabled!"
  else
    let g:tea_enabled = 0
    echo "Tea plugin disabled!"

    if g:tea_timer_id != -1
      call timer_stop(g:tea_timer_id)
      let g:tea_timer_id = -1
    endif
  endif
endfunction

command! TeaEnable call TeaEnable()
command! TeaDisable call TeaDisable()
command! Tea call Tea(0)
