# app/assets/javascripts/articles.js.coffee

ready = ->
    $(".wrap .article-index").infinitescroll
      navSelector: "nav.pagination" # selector for the paged navigation (it will be hidden)
      nextSelector: "nav.pagination a[rel=next]" # selector for the NEXT link (to page 2)
      itemSelector: ".wrap .article" # selector for all items you'll retrieve
      loading: {
        finishedMsg: 'Houston, we are out of weed.',
        msgText: "Repacking the Bong"
      }
    
ready2 = ->
    $(".wrap .article-index-views").infinitescroll
      navSelector: "nav.pagination" # selector for the paged navigation (it will be hidden)
      nextSelector: "nav.pagination a[rel=next]" # selector for the NEXT link (to page 2)
      itemSelector: ".wrap .article" # selector for all items you'll retrieve    
      loading: {
        finishedMsg: 'Houston, we are out of weed.',
        msgText: "Repacking the Bong"
      }