//javascript for sidebar check on and off

function showOrHideArticles(checkbox) {
  
  if (checkbox.checked) {
    
    $('.' + checkbox.id.replace("_checkbox", "")).css('display', 'block');
    
  } else {
    
    $('.' + checkbox.id.replace("_checkbox", "")).css('display', 'none');
  }
  
}