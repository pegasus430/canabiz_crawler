/*-----------------------------------------------------------------------------------

    Template Name: CannaBiz for Blogging and News Sites. 
    Template URI: https://themeforest.net/user/nilartstudio
    Description: CannaBiz is a unique website template designed in html with a simple & beautiful look. There is an excellent solution for creating clean, wonderful and trending material design blog, magazine, news site or any other purposes websites.
    Author: Nilartstudio
    Author URI: http://Nilartstudio.com
    Version: 1.0

-----------------------------------------------------------------------------------*/

/*================================================
[  Table of contents  ]
================================================
	01. jQuery MeanMenu
    05. ScrollUp jquery
    19. ScrollUp jquery
======================================
[ End table content ]
======================================*/


(function($) {
    "use strict";

    /*-------------------------------------------
    	01. jQuery MeanMenu
    --------------------------------------------- */
    $('nav#mobile_dropdown').meanmenu({
        meanMenuContainer: '.mobile-menu-area',
        meanMenuCloseSize: "18px",
        meanScreenWidth: "991"
    });

    // /*-------------------------------------------
    //     05. ScrollUp jquery
    // --------------------------------------------- */
    $.scrollUp({
        scrollText: '<p class="up-carrot">^</i>',
        easingType: 'linear',
        scrollSpeed: 900,
        animation: 'slide'
    });

    // /*-------------------------------------------
    //     19. Mobile Search
    // --------------------------------------------- */
    $('.mobile-search-btn').on('click', function(){
        if($(this).siblings('.mobile-search-form').hasClass('active')){
            $(this).siblings('.mobile-search-form').removeClass('active').slideUp();
            $(this).removeClass('active');

            if ( $(this).find("i").hasClass('fa-search')){
                $(this).find("i").removeClass('fa-search').addClass('fa-times');
            }else{
                $(this).find("i").removeClass('fa-times').addClass('fa-search');
            }
        }
        else{
            $('.mobile-search-btn .mobile-search-form').removeClass('active').slideUp();
            $('.mobile-search-btn .mobile-search-form').removeClass('active');
            $(this).addClass('active');
            $(this).siblings('.mobile-search-form').addClass('active').slideDown();
            if ( $(this).find("i").hasClass('fa-search')){
                $(this).find("i").removeClass('fa-search').addClass('fa-times');
            }
            
            // remove the image and add the x
            // $('.mobile-search-btn active').replace(/<img[^>]*>/g,"");
        }
    });

})(jQuery);
