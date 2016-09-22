shown_time = {}
countdown_timer = null

rotate = (obj, prop, mod) ->
  # return whether there was a carry
  if obj.hasOwnProperty prop
    new_val = obj[prop] - 1
    if new_val == -1
      new_val = mod - 1
      ret = true
    else
      ret = false
  obj[prop] = new_val
  ret
  
rotate_time = (time_obj) ->
  carry = rotate(time_obj, 'secs', 60)
  if carry
    carry = rotate(time_obj, 'mins', 60)
    if carry
      carry = rotate(time_obj, 'hrs', 24)
      if carry
        # Stop the clock!
        clearInterval countdown_timer
  $('.countdown .hrs').text time_obj.hrs
  $('.countdown .mins').text time_obj.mins
  $('.countdown .secs').text time_obj.secs
  
  null
      
twitter_feed_functions = ->
  data_elt = $('.time_data')
  shown_time =
    hrs: data_elt.data('hrs')
    mins: data_elt.data('mins')
    secs: data_elt.data('secs')
  countdown_timer = setInterval rotate_time, 1000, shown_time  
    
$(document).on('page:load ready', twitter_feed_functions)
