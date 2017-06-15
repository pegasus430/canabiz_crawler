// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require bootstrap
//= require jquery.infinitescroll
//= require social-share-button
//= require_tree .

//method used to display a stock image in the article index
function dispIndexImageError(image) {
  image.onerror = "";
  image.src = "<%= asset_path 'homepage/news-substitute.jpg' %>"
  return true;
}

//change the sorting method
function changeSort(stringValue) {
    if (stringValue == 'Popular') 
    {
        $("#article-index-views").css("display", "block");
        $(".article-index-views-pagination").css("display", "block");
        $("#article-index-new").css("display", "none");
        $(".article-index-new-pagination").css("display", "none");
        
        $("#newest-button").removeClass('active-header-button');
        $("#newest-button").addClass('inactive-header-button');
        $("#popular-button").removeClass('inactive-header-button');
        $("#popular-button").addClass('active-header-button');
    } 
    else if (stringValue == 'Newest') 
    {
        $("#article-index-views").css("display", "none");
        $(".article-index-views-pagination").css("display", "none");
        $("#article-index-new").css("display", "block");
        $(".article-index-new-pagination").css("display", "block");
        
        $("#newest-button").removeClass('inactive-header-button');
        $("#newest-button").addClass('active-header-button');
        $("#popular-button").removeClass('active-header-button');
        $("#popular-button").addClass('inactive-header-button');
    }
}

//sticky header on article pages
$(window).scroll(function() {
    
    var stick = $("#mobile-sticky-header");
    var logo = $("#mobile-sticky-logo"); 
    var header = $(".header-area");
    var meanBar = $(".mean-bar");

    if (stick.length && meanBar.length) {

        if ($(window).scrollTop() > (header.height() - 52)) {
            stick.addClass('fix-search');
            meanBar.addClass('fix-bar');
            logo.addClass('fix-logo');
            $(".mobile-search-form").css({"position": "fixed"});
            $(".mobile-search-btn").css({"position": "fixed"});
        }
        else {
            stick.removeClass('fix-search');
            meanBar.removeClass('fix-bar');
            logo.removeClass('fix-logo');
            $(".mobile-search-form").css({"position": "absolute"});
            $(".mobile-search-btn").css({"position": "absolute"});
        }
    }
});


//endless scrolling
$(window).scroll(function() {

    if ($('.pagination').length) {  

        if ($('#article-index-new').css('display') == 'block') {
            
            if ($('.article-index-new-pagination .pagination li.next.next_page').hasClass('disabled'))
            {
                $('.article-index-new-pagination .pagination').text("No More Content");
            } 
            else 
            {
                var url = $('.article-index-new-pagination .pagination li.next.next_page a').attr('href');
                
                if (url && $(window).scrollTop() > $(document).height() - $(window).height() - 150) 
                {
                    $('.article-index-new-pagination .pagination').text("Loading More News...");
                    return $.getScript(url);
                }                
            }

        }
        else if ($('#article-index-views').css('display') == 'block') {
            
            if ($('.article-index-views-pagination .pagination li.next.next_page').hasClass('disabled'))
            {
                $('.article-index-views-pagination .pagination').text("No More Content");
            }
            else 
            {
                var url = $('.article-index-views-pagination .pagination li.next.next_page a').attr('href');

                if (url && $(window).scrollTop() > $(document).height() - $(window).height() - 150) 
                {
                    $('.article-index-views-pagination .pagination').text("Loading More News...");
                    return $.getScript(url);
                }
            }
        }
    }
});

//make all links within article body be target _blank 
$(document).ready(function(){
  $('.zm-post-content a').attr('target', '_blank');
});

//SELECT ALL ON ADMIN PAGES
function selectAllCheckboxes(elem) {

    var div = document.getElementById("admin-table");
    var chk = div.getElementsByTagName('input');
    var len = chk.length;

    for (var i = 0; i < len; i++) {
        if (chk[i].type === 'checkbox') {
            chk[i].checked = elem.checked;
        }
    }
}

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