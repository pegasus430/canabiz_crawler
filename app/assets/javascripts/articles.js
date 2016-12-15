var elHeight = document.getElementById("main-title").style.height;
var offsetHeight = (elHeight/2) - elHeight;

document.getElementById("main-title").style.marginTop = offsetHeight;


//make all links within article body be target _blank 
$(document).ready(function(){
  $('.article-body a').attr('target', '_blank');
});

//ajax call to track the article views
$(document).on('click', ".article-source-link", function () {
	
	console.log('this has been clicked!');
	
});

/*
function saveExternalArticleClick(articleId, articleURL) {
	console.log(articleId);
	console.log(articleURL);
}
*/
/*

	$(".edit").click(function(){  
	  if ($(this).hasClass("update")){     
	    $.ajax({
	      type: "PUT",
	      url: "/sections/<%= section.id %>"
	    });
	  } else {
	    //do something else 
	  }; 
	})
*/
