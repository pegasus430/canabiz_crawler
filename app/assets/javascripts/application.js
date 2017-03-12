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
        // $(".sort-button").html("Most Popular");
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
        // $(".sort-button").html("Newest");
        $("#newest-button").removeClass('inactive-header-button');
        $("#newest-button").addClass('active-header-button');
        $("#popular-button").removeClass('active-header-button');
        $("#popular-button").addClass('inactive-header-button');
    }
    //hide the overlay
    //closeNav();
}


//endless scrolling
$(window).scroll(function() {
    
    // console.log('scrolling');
    if ($('.pagination').length) {  
        // console.log('pagination length');

        if ($('#article-index-new').css('display') == 'block') {
            
            // console.log('article index new');
            
            if ($('.article-index-new-pagination .pagination li.next.next_page').hasClass('disabled'))
            {
                console.log('if');
                $('.article-index-new-pagination .pagination').text("Houston, we are out of Weed!");
            } 
            else 
            {
                console.log('else');
                var url = $('.article-index-new-pagination .pagination li.next.next_page a').attr('href');
                console.log('url ' + url);
                console.log('window scroll top ' + $(window).scrollTop());
                console.log('document heightformula ' + $(document).height() - $(window).height() - 150);
                // console.log('url ' + url);
                
                
                if (url && $(window).scrollTop() > $(document).height() - $(window).height() - 150) 
                {
                    console.log('scroll top');
                    $('.article-index-new-pagination .pagination').text("Repacking The Bong...");
                    return $.getScript(url);
                }                
            }

        }
        else if ($('#article-index-views').css('display') == 'block') {
            
            if ($('.article-index-views-pagination .pagination li.next.next_page').hasClass('disabled'))
            {
                $('.article-index-views-pagination .pagination').text("Houston, we are out of Weed!");
            }
            else 
            {
                var url = $('.article-index-views-pagination .pagination li.next.next_page a').attr('href');

                if (url && $(window).scrollTop() > $(document).height() - $(window).height() - 150) 
                {
                    $('.article-index-views-pagination .pagination').text("Repacking The Bong...");
                    return $.getScript(url);
                }
            }
            
        }
    }
});



      // console.log('URL: ' + url);
      // console.log('$(window).scrollTop() ' + $(window).scrollTop());
      // console.log('$(document).height() - $(window).height() - 50:   ' + ($(document).height() - $(window).height() - 50));