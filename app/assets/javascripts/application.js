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
//= require owl.carousel

$(".owl-carousel").owlCarousel({
    items: 2,
    nav: true,
    center: true,
    loop: true,
    dots: false,
    mouseDrag: true,
    stagePadding: 50,
    responsiveClass:true,
    responsive:{
        0:{
            items:1,
            stagePadding: 0,
        },
        480:{
            items:1,
            stagePadding: 0,
        },
        768:{
            items:2,
        },
        1024:{
            items:2,
        },
        1380:{
            items:3,
        },
        1580:{
            items:4,
        }
    }
});
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