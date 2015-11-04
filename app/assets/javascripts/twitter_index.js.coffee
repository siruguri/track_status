$(document).ready ->
  $('.selection-box').click (evt) ->
    target_num = $(this).data('target')
    target_id = '#databox-' + target_num
    $('.databox').hide()
    $(target_id).show({
      effect: 'fade',
      easing: 'easeInOutQuint',
      duration: 750
      });
    
