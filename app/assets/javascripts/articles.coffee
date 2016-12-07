# app/assets/javascripts/articles.js.coffee

ready = ->
  $(".wrap .article-index").infinitescroll
    navSelector: "nav.pagination" # selector for the paged navigation (it will be hidden)
    nextSelector: "nav.pagination a[rel=next]" # selector for the NEXT link (to page 2)
    itemSelector: ".wrap .article" # selector for all items you'll retrieve

$(document).ready(ready)
$(document).on('page:load', ready)
$(document).on('turbolinks:load', ready)

# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# (document).ready 