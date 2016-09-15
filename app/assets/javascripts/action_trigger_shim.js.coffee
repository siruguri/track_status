curtain_drop = (text) ->
  $('.toast').addClass('open').text text
  setTimeout ->
      $('.toast').text('').removeClass('open')
      true
      
    , 2000
    
spinner_div = ->
  return $('<div>').addClass('spinner')
  
shim_funcs = ->
  $('.action').click (evt) ->
    action_id = $(evt.target).data('action-id')
    if typeof action_id != 'undefined'
      $(evt.target).prepend spinner_div
      xhr = $.ajax(
        type: 'POST'
        url: '/ajax_api'
        data:
          payload: 'actions/trigger/' + action_id
      )
      
      xhr.done((d, s, x) ->
          curtain_drop d.data
      ).fail((d, s, x) ->
          # failure
          curtain_drop 'wtf'
      ).always( ->
        setTimeout( ->
            $(evt.target).find('.spinner').remove()
            true
          500
        )
      )
      
$(document).on('ready page:load', shim_funcs)
