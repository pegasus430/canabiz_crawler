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
//= require bootstrap-sprockets
//= require jquery.infinitescroll
//= require social-share-button
//= require gmaps/google
//= require toastr
//= require owl.carousel

// $(".owl-carousel").owlCarousel();
// bootstrap
// bootstrap-modal
// bootstrap-modalmanager

// change homepage sorting method
function changeHomeSort(stringValue) {
    if (stringValue == 'News') 
    {
        $(".homepage-recent-news").css("display", "block");
        $(".homepage-recent-products").css("display", "none");
        
        $("#news-button").removeClass('inactive-header-button');
        $("#news-button").addClass('active-header-button');
        $("#product-button").removeClass('active-header-button');
        $("#product-button").addClass('inactive-header-button');
    } 
    else if (stringValue == 'Products') 
    {
        $(".homepage-recent-news").css("display", "none");
        $(".homepage-recent-products").css("display", "block");
        
        $("#news-button").removeClass('active-header-button');
        $("#news-button").addClass('inactive-header-button');
        $("#product-button").removeClass('inactive-header-button');
        $("#product-button").addClass('active-header-button');
    }    
}

// change searchpage sorting method
function changeSearchSort(stringValue) {
    if (stringValue == 'News') 
    {
        $("#article-search-results").css("display", "block");
        $(".article-pagination").css("display", "block");
        $("#product-search-results").css("display", "none");
        $(".product-pagination").css("display", "none");
        
        $("#news-button").removeClass('inactive-header-button');
        $("#news-button").addClass('active-header-button');
        $("#product-button").removeClass('active-header-button');
        $("#product-button").addClass('inactive-header-button');
    } 
    else if (stringValue == 'Products') 
    {
        $("#article-search-results").css("display", "none");
        $(".article-pagination").css("display", "none");
        $("#product-search-results").css("display", "block");
        $(".product-pagination").css("display", "block");
        
        $("#news-button").removeClass('active-header-button');
        $("#news-button").addClass('inactive-header-button');
        $("#product-button").removeClass('inactive-header-button');
        $("#product-button").addClass('active-header-button');
    }
}

// ****INDEX PAGES (Mostly Product)**

//when user selects an option state
function setSelectedState(value) {
	jQuery('[id$=state_search]').val(value);
}

//when user selects an option category
function setSelectedCategory(value) {
	jQuery('[id$=category_search]').val(value);
} 

//when user selects an option a-z value
function selectSelectedAZValue(value) {
	jQuery('[id$=az_search]').val(value);
}

// ****DISPENSARY ALL PRODUCTS ***
function changeProductCategory(value) {
	
	//hide other product displays
	$(".product-section-class").css("display", "none");
	
	//show this product display
	$("." + value).css("display", "block");
    
    //make all others buttons inactive
    $(".header-button").removeClass('active-header-button');
    $(".header-button").addClass('inactive-header-button');
    
    //make this button active
    $("." + value + "-button").addClass('active-header-button');
    $("." + value + "-button").removeClass('inactive-header-button');
    
}

// *** STATE PAGE **

function changeStateView(value) {
	if (value == 'News') {
		$("#state-news-button").addClass('active-header-button');
		$("#state-news-button").removeClass('inactive-header-button');
		$("#state-products-button").addClass('inactive-header-button');
		$("#state-products-button").removeClass('active-header-button');
		$(".state-products-section").css("display", "none");
		$(".state-news-section").css("display", "block");
		$("#article-index-new").css("display", "block");
	}
	else if (value == 'Products') {
		$("#state-products-button").addClass('active-header-button');
		$("#state-products-button").removeClass('inactive-header-button');
		$("#state-news-button").addClass('inactive-header-button');
		$("#state-news-button").removeClass('active-header-button');
		$(".state-products-section").css("display", "block");
		$(".state-news-section").css("display", "none");
		$("#article-index-new").css("display", "none");
	}
}

// Both - Clear Values
function clearFormValues() {
	jQuery('[id$=state_search]').val('');
	jQuery('[id$=category_search]').val('');
	jQuery('[id$=az_search]').val('');
	jQuery('[id$=name_search]').val('');
	jQuery('[id$=location_search]').val('');
	
	var stateLists = document.getElementsByClassName("state-dropdown");
	for (var i = 0; i < stateLists.length; i++) {
		stateLists[i].selectedIndex = 0;
	}
	
	var categoryLists = document.getElementsByClassName("category-dropdown");
	for (var i = 0; i < categoryLists.length; i++) {
		categoryLists[i].selectedIndex = 0;
	}
	
	var azLists = document.getElementsByClassName("az-dropdown");
	for (var i = 0; i < azLists.length; i++) {
		azLists[i].selectedIndex = 0;
	}
}

//collapsible option thing
$('.plus-minus').click(function(){
    $(this).text(function(i,old){
        return old=='(+)' ?  '(-)' : '(+)';
    });
});

//don't collapse on desktop, collapse on mobile
$(window).resize(function() {
	if ($(window).width() < 991) {
	    $('#option-div').removeClass('in');
	    $('.plus-minus').text('(+)');
	} else {
	    $('#option-div').addClass('in');
	    $('.plus-minus').text('(-)');
	}
});

//on load collapse on mobile
$( document ).ready(function() {
	if ($(window).width() < 991) {
	    $('#option-div').removeClass('in');
	    $('.plus-minus').text('(+)');
	} else {
	    $('#option-div').addClass('in');
	    $('.plus-minus').text('(-)');
	}
});

//toggle product table rows
// $('.state-name-row').click(function(){
// 	$(this).nextUntil('tr.state-name-row').slideToggle(200);
// 	$(this).find('.pm').text(function(_, value){return value=='(-)'?'(+)':'(-)'});
// });

//start some rows collapsed
// $( document ).ready(function() {
// 	$('.dont').nextUntil('tr.state-name-row').hide();
// 	$(this).find('.pm').text(function(_, value){return value=='(-)'?'(+)':'(-)'});
// });

//dispensary end

