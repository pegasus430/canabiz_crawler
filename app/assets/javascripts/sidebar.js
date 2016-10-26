//javascript for sidebar check on and off

function showOrHideArticles(checkbox) {
  
  //alert(checkbox.id);
  
  if (checkbox.checked) {
    
    $('.' + checkbox.id.replace("_checkbox", "")).css('display', 'block');
    
  } else {
    
    $('.' + checkbox.id.replace("_checkbox", "")).css('display', 'none');
  }
  
  //var res = checkbox.id.replace("_checkbox", "");
}