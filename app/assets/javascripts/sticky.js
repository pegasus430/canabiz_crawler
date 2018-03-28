//mobile sticky headers
$(window).scroll(function() {
    
    var scrollTop = $(window).scrollTop();
    var stick = $("#mobile-sticky-header");
    var logo = $("#mobile-sticky-logo"); 
    var header = $(".header-area");
    var meanBar = $(".mean-bar");
    
    // different heights for different page types
    var productPage = $(".product-refine-buttons");
    var dispensaryPage = $(".dispensary-show-page");

    if (stick.length && meanBar.length) {

        var heightToAppear = 52;
        if (productPage.length) {
            heightToAppear = -400;
        }
        else if (dispensaryPage.length) {
            var elementOffset = $('.dispensary-product-categories').offset().top;
            var distance = (elementOffset - scrollTop);
            heightToAppear = distance;
        }

        if ((dispensaryPage.length && heightToAppear <= 0) || 
            ($(window).scrollTop() > (header.height() - heightToAppear))) {
        // if (heightToAppear <= 0) {
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