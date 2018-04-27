//make all links within article body be target _blank 
$(document).ready(function(){
  $('.zm-post-content a').attr('target', '_blank');
});

//method used to display a stock image in the article index
function dispIndexImageError(image) {
  image.onerror = "";
  image.src = "<%= asset_path 'substitutes/news-substitute.jpg' %>"
  return true;
}

//change news the sorting method
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
;
