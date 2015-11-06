$(document).ready ->
  $('.selection-box').click (evt) ->
    target_num = $(this).data('target')
    target_id = '#databox-' + target_num
    $('.databox').hide 'drop',
      direction: 'up', easing: 'easeInOutQuint',
    750

    $(target_id).show 'drop',
      direction: 'down', easing: 'easeInOutQuint',
    750
    
    
