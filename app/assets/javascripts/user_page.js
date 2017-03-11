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
	
	if (articleId != null && articleId != '') {
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
}

//set the setting id on the modal
function setRemoveSourceSettingId(sourceId, sourceName) {
	jQuery('[id$=sourceRemoveId]').val(sourceId);
	document.getElementById('removalName').innerHTML = sourceName;
}

function setRemoveCategorySettingId(categoryId, categoryName) {
	jQuery('[id$=categoryRemoveId]').val(categoryId);
	document.getElementById('removalName').innerHTML = categoryName;
}

function setRemoveStateSettingId(stateId, stateName) {
	jQuery('[id$=stateRemoveId]').val(stateId);
	document.getElementById('removalName').innerHTML = stateName;
}

//remove saved source
function removeSavedSetting() {
	
	if (document.getElementById('sourceRemoveId').value != null && document.getElementById('sourceRemoveId').value != '') {
		//remove source	
		$.ajax({
	        type: "PUT",
	        url: "/user_source_save/" + document.getElementById('sourceRemoveId').value,
	        beforeSend: function() {
				// start spinner
				$(".ajax-spinner-source").css('display', 'block');
			},
	        success: function() {
	        	$("#tab-3").load(location.href+" #tab-3>*", function() {
	        		//remove the ajax spinner
	        		$(".ajax-spinner-source").css('display', 'none');
	        		
	        		//clear the modal variables
	        		document.getElementById('sourceRemoveId').value = null;
					document.getElementById('categoryRemoveId').value = null;
					document.getElementById('stateRemoveId').value = null;
	        	});
	        	
	        	//reload tab 1 to see article updates
	        	$("#tab-1").load(location.href+" #tab-1>*", function() {});
	        }
	    });
	}
	else if (document.getElementById('categoryRemoveId').value != null && document.getElementById('categoryRemoveId').value != '') {
		//remove category
		$.ajax({
	        type: "PUT",
	        url: "/user_category_save/" + document.getElementById('categoryRemoveId').value,
	        beforeSend: function() {
				// start spinner
				$(".ajax-spinner-category").css('display', 'block');
			},
	        success: function() {
	        	$("#tab-3").load(location.href+" #tab-3>*", function() {
	        		//remove the ajax spinner
	        		$(".ajax-spinner-category").css('display', 'none');
	        		
	        		//clear the modal variables
	        		document.getElementById('sourceRemoveId').value = null;
					document.getElementById('categoryRemoveId').value = null;
					document.getElementById('stateRemoveId').value = null;
	        	});
	        	
	        	//reload tab 1 to see article updates
	        	$("#tab-1").load(location.href+" #tab-1>*", function() {});
	        }
	    });
	}
	else if (document.getElementById('stateRemoveId').value != null && document.getElementById('stateRemoveId').value != '') {
		//remove state
		$.ajax({
	        type: "PUT",
	        url: "/user_state_save/" + document.getElementById('stateRemoveId').value,
	        beforeSend: function() {
				// start spinner
				$(".ajax-spinner-state").css('display', 'block');
			},
	        success: function() {
	        	$("#tab-3").load(location.href+" #tab-3>*", function() {
	        		//remove the ajax spinner
	        		$(".ajax-spinner-state").css('display', 'none');
	        		
	        		//clear the modal variables
	        		document.getElementById('sourceRemoveId').value = null;
					document.getElementById('categoryRemoveId').value = null;
					document.getElementById('stateRemoveId').value = null;
	        	});
	        	
	        	//reload tab 1 to see article updates
	        	$("#tab-1").load(location.href+" #tab-1>*", function() {});
	        }
	    });
	}	
	
}

//unset all of the modal variables so we don't accidentally remove any settings
function clearModalVariables () {
	
	// sourceRemoveId
	// categoryRemoveId
	// stateRemoveId
	document.getElementById('sourceRemoveId').value = null;
	document.getElementById('categoryRemoveId').value = null;
	document.getElementById('stateRemoveId').value = null;
	
}

//for adding sources / categories / states
function setSelectedSourceSave(value) {
	console.log(value);
	jQuery('[id$=sourceAddId]').val(value);
}

function addSavedSource() {
	
	if (document.getElementById('sourceAddId').value != null && document.getElementById('sourceAddId').value != '') {
		$.ajax({
	        type: "PUT",
	        url: "/user_source_save/" + document.getElementById('sourceAddId').value,
	        beforeSend: function() {
				// start spinner
				$(".ajax-spinner-source").css('display', 'block');
			},
	        success: function() {
	        	$("#tab-3").load(location.href+" #tab-3>*", function() {
	        		//remove the ajax spinner
	        		$(".ajax-spinner-source").css('display', 'none');
	        		
	        		//clear the variables
	        		document.getElementById('sourceAddId').value = null;
	        	});
	        	
	        	//reload tab 1 to see article updates
	        	$("#tab-1").load(location.href+" #tab-1>*", function() {});
	        }
	    });
	}
}

function setSelectedCategorySave(value) {
	console.log(value);
	jQuery('[id$=categoryAddId]').val(value);
}

function addSavedCategory() {
	
	if (document.getElementById('categoryAddId').value != null && document.getElementById('categoryAddId').value != '') {
		$.ajax({
	        type: "PUT",
	        url: "/user_category_save/" + document.getElementById('categoryAddId').value,
	        beforeSend: function() {
				// start spinner
				$(".ajax-spinner-category").css('display', 'block');
			},
	        success: function() {
	        	$("#tab-3").load(location.href+" #tab-3>*", function() {
	        		//remove the ajax spinner
	        		$(".ajax-spinner-category").css('display', 'none');
	        		
	        		//clear the variables
	        		document.getElementById('categoryAddId').value = null;
	        	});
	        	
	        	//reload tab 1 to see article updates
	        	$("#tab-1").load(location.href+" #tab-1>*", function() {});
	        }
	    });
	}
}

function setSelectedStateSave(value) {
	console.log(value);
	jQuery('[id$=stateAddId]').val(value);
}

function addSavedState() {
	
	if (document.getElementById('stateAddId').value != null && document.getElementById('stateAddId').value != '') {
		$.ajax({
	        type: "PUT",
	        url: "/user_state_save/" + document.getElementById('stateAddId').value,
	        beforeSend: function() {
				// start spinner
				$(".ajax-spinner-state").css('display', 'block');
			},
	        success: function() {
	        	$("#tab-3").load(location.href+" #tab-3>*", function() {
	        		//remove the ajax spinner
	        		$(".ajax-spinner-state").css('display', 'none');
	        		
	        		//clear the variables
	        		document.getElementById('stateAddId').value = null;
	        	});
	        	
	        	//reload tab 1 to see article updates
	        	$("#tab-1").load(location.href+" #tab-1>*", function() {});
	        }
	    });
	}
}
