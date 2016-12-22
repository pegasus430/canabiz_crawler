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
//= require turbolinks
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
function changeSort(elem) {
    if (elem.innerHTML == 'Most Popular') 
    {
        $("#article-index-views").css("display", "block");
        $(".article-index-views-pagination").css("display", "block");
        $("#article-index-new").css("display", "none");
        $(".article-index-new-pagination").css("display", "none");
        $(".sort-button").html("Most Popular");
    } else if (elem.innerHTML == 'Newest') 
    {
        $(".article-index-views").css("display", "none");
        $(".article-index-views-pagination").css("display", "none");
        $("#article-index-new").css("display", "block");
        $(".article-index-new-pagination").css("display", "block");
        $(".sort-button").html("Newest");
    }
    //hide the overlay
    closeNav();
}


//endless scrolling?
$(document).ready(function() {
    
    if ($('.pagination').length) {
        $(window).scroll(function() {
            
            var url;
            if ($('#article-index-new').css('display') == 'block') {
                
                url = $('.article-index-new-pagination .pagination li.next.next_page a').attr('href');
                console.log('new');
            }
            else if ($('#article-index-views').css('display') == 'block') {
                
                url = $('.article-index-views-pagination .pagination li.next.next_page a').attr('href');
                console.log('views');
            }
            
            console.log('URL: ' + url);
            
            if (url && $(window).scrollTop() > $(document).height() - $(window).height() - 150) {
                $('.pagination').text("Repacking The Bong...");
                return $.getScript(url);
            }
        });
        
        return $(window).scroll();
    }
});



// $(document).ready(function() {
//     if ($('#article-index-new').css('display') == 'block') {

//         if ($('.pagination').length) {
//             $(window).scroll(function() {
//                 var url = $('article-index-new-pagination .pagination li.next.next_page a').attr('href');
//                 console.log('new');
                
//                 if (url && $(window).scrollTop() > $(document).height() - $(window).height() - 150) {
//                     $('.article-index-pagination .pagination').text("Repacking The Bong...");
//                     return $.getScript(url);
//                 }
//             });
            
//             return $(window).scroll();
//         }        
//     }
//     else if ($('article-index-views-pagination .pagination').length) {
//         $(window).scroll(function() {
//             var url = $('article-index-views-pagination .pagination li.next.next_page a').attr('href');
//             console.log('new');
            
//             if (url && $(window).scrollTop() > $(document).height() - $(window).height() - 150) {
//                 $('.article-index-pagination .pagination').text("Repacking The Bong...");
//                 return $.getScript(url);
//             }
//         });
        
//         return $(window).scroll();    
//     }
// });


      // console.log('URL: ' + url);
      // console.log('$(window).scrollTop() ' + $(window).scrollTop());
      // console.log('$(document).height() - $(window).height() - 50:   ' + ($(document).height() - $(window).height() - 50));