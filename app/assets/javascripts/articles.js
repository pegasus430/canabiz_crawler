var init_article_lookup;

init_article_lookup = function() {
  $('#article-lookup-form').on('ajax:before', function(event, data, status){
    show_spinner();
  });
  
  $('#article-lookup-form').on('ajax:after', function(event, data, status){
    hide_spinner();
  });
  
  $('#article-lookup-form').on('ajax:success', function(event, data, status){
    $('#article-lookup').replaceWith(data);
    init_article_lookup();
  });
  
  $('#article-lookup-form').on('ajax:error', function(event, xhr, status, error){
    hide_spinner();
    $('#article-lookup-results').replaceWith(' ');
    $('#article-lookup-errors').replaceWith('No Articles Found');
  });
}



$(document).ready(function() {
  init_article_lookup();
})