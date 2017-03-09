//tabs
$('ul.tabs li').click(function(){
	var tab_id = $(this).attr('data-tab');

	$('ul.tabs li').removeClass('current');
	$('.tab-content').removeClass('current');

	$(this).addClass('current');
	$("#"+tab_id).addClass('current');
})


//set the articleId on the close modal
function setRemoveArticleId(articleId) {
	jQuery('[id$=articleRemoveId]').val(articleId);
}

//remove the saved article
function removeSavedArticle() {
	var articleId = document.getElementById('articleRemoveId').value;
	console.log(articleId);
	$.ajax({
        type: "PUT",
        url: "/user_article_save/" + articleId,
        beforeSend: function() {
			// start spinner
			$(".ajax-spinner").css('display', 'block');
		},
        success: function() {
        	$("#tab-2").load(location.href+" #tab-2>*", function() {
        		//remove the ajax spinner
        		$(".ajax-spinner").css('display', 'none');
        	});
        }
    });
}