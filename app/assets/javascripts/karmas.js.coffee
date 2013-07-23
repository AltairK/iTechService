jQuery ->
  $('.user_karma_link').each (i, el)->
    $(el).tooltip
      html: true
      title: $(this).data('comment')

$(document).on 'click', '.submit_karma_form', (event)->
  $('#user_karma_form').submit()
  showSpinner()
  event.preventDefault()

$(document).on 'click', '.close_karma_popover_button', (event)->
  $owner = $($(this).data('owner'))
  $owner.popover('destroy')
  event.preventDefault()

window.close_karma_popovers = ->
  $('.new_karma_link,.user_karma_link').popover('destroy')