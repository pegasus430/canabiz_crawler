var elHeight = document.getElementById("main-title").style.height;
var offsetHeight = (elHeight/2) - elHeight;

document.getElementById("main-title").style.marginTop = offsetHeight;


//make all links within article body be target _blank 
$(document).ready(function(){
  $('.article-body a').attr('target', '_blank');
});
        