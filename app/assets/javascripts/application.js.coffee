#= require jquery
#= require jquery_ujs
#= require twitter/bootstrap
#= require jquery.pjax
#= require_tree .

$ ->
  $('[title]').tooltip()

  $('[popover-title]').popover
    title: 'Просьба инвайта'
    content: ->
      $(@).attr('popover-title')
