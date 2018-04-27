//endless scrolling on news page
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

// endless scroll on search page
$(window).scroll(function() {

    if ($('.pagination').length) {  

        if ($('#product-search-results').css('display') == 'block') {
            
            if ($('.product-pagination .pagination li.next.next_page').hasClass('disabled'))
            {
                $('.product-pagination .pagination').text("No More Content");
            } 
            else 
            {
                var url = $('.product-pagination .pagination li.next.next_page a').attr('href');
                
                if (url && $(window).scrollTop() > $(document).height() - $(window).height() - 150) 
                {
                    $('.product-pagination .pagination').text("Loading More Products...");
                    return $.getScript(url);
                }                
            }

        }
        else if ($('#article-search-results').css('display') == 'block') {
            
            if ($('.article-pagination .pagination li.next.next_page').hasClass('disabled'))
            {
                $('.article-pagination .pagination').text("No More Content");
            }
            else 
            {
                var url = $('.article-pagination .pagination li.next.next_page a').attr('href');

                if (url && $(window).scrollTop() > $(document).height() - $(window).height() - 150) 
                {
                    $('.article-pagination .pagination').text("Loading More News...");
                    return $.getScript(url);
                }
            }
        }
    }
});

//endless scrolling on product index - if mobile
$(window).scroll(function() {

    if ($('.product-index-pagination').length) {  
        
        if ($('.hidden-xs').css('display') == 'none') {
            
            if ($('.product-index-pagination .pagination li.next.next_page').hasClass('disabled'))
            {
                $('.product-index-pagination .pagination').text("No More Products");
            } 
            else 
            {
                var url = $('.product-index-pagination .pagination li.next.next_page a').attr('href');;
                
                if (url && $(window).scrollTop() > $(document).height() - $(window).height() - 150) 
                {
                    $('.product-index-pagination .pagination').text("Loading More Products...");
                    return $.getScript(url);
                }                
            }
        }
    }
});

//endless scrolling on vendor show - if mobile
$(window).scroll(function() {

    if ($('.vendor-show-pagination').length) {  
        
        if ($('.hidden-xs').css('display') == 'none') {
            
            if ($('.vendor-show-pagination .pagination li.next.next_page').hasClass('disabled'))
            {
                $('.vendor-show-pagination .pagination').text("No More Products");
            } 
            else 
            {
                var url = $('.vendor-show-pagination .pagination li.next.next_page a').attr('href');;
                
                if (url && $(window).scrollTop() > $(document).height() - $(window).height() - 150) 
                {
                    $('.vendor-show-pagination .pagination').text("Loading More Products...");
                    return $.getScript(url);
                }                
            }
        }
    }
});
