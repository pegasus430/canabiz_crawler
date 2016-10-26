//javascript for sidebar check on and off
<script type="text/javascript">
  $('li#retail').click(function() {
    $(".retailstore").css({"display": "inline-block", "-webkit-transition": "all 500ms ease", "-moz-transition": "all 500ms ease", "-ms-transition": "all 500ms ease", "-o-transition": "all 500ms ease", "transition": "all 500ms ease"});
    $(".officeType").css({"display": "none", "-webkit-transition": "all 500ms ease", "-moz-transition": "all 500ms ease", "-ms-transition": "all 500ms ease", "-o-transition": "all 500ms ease", "transition": "all 500ms ease"});
    $(".school").css({"display": "inline-block", "-webkit-transition": "all 500ms ease", "-moz-transition": "all 500ms ease", "-ms-transition": "all 500ms ease", "-o-transition": "all 500ms ease", "transition": "all 500ms ease"});
    $(".superm").css({"display": "none", "-webkit-transition": "all 500ms ease", "-moz-transition": "all 500ms ease", "-ms-transition": "all 500ms ease", "-o-transition": "all 500ms ease", "transition": "all 500ms ease"});
  });
  $('li#all').click(function() {
    $(".retailstore").css({"display": "inline-block", "-webkit-transition": "all 500ms ease", "-moz-transition": "all 500ms ease", "-ms-transition": "all 500ms ease", "-o-transition": "all 500ms ease", "transition": "all 500ms ease"});
    $(".officeType").css({"display": "inline-block", "-webkit-transition": "all 500ms ease", "-moz-transition": "all 500ms ease", "-ms-transition": "all 500ms ease", "-o-transition": "all 500ms ease", "transition": "all 500ms ease"});
    $(".school").css({"display": "inline-block", "-webkit-transition": "all 500ms ease", "-moz-transition": "all 500ms ease", "-ms-transition": "all 500ms ease", "-o-transition": "all 500ms ease", "transition": "all 500ms ease"});
    $(".superm").css({"display": "inline-block", "-webkit-transition": "all 500ms ease", "-moz-transition": "all 500ms ease", "-ms-transition": "all 500ms ease", "-o-transition": "all 500ms ease", "transition": "all 500ms ease"});
  });
  $('li#education').click(function() {
    $(".retailstore").css({"display": "none", "-webkit-transition": "all 500ms ease", "-moz-transition": "all 500ms ease", "-ms-transition": "all 500ms ease", "-o-transition": "all 500ms ease", "transition": "all 500ms ease"});
    $(".officeType").css({"display": "none", "-webkit-transition": "all 500ms ease", "-moz-transition": "all 500ms ease", "-ms-transition": "all 500ms ease", "-o-transition": "all 500ms ease", "transition": "all 500ms ease"});
    $(".superm").css({"display": "none", "-webkit-transition": "all 500ms ease", "-moz-transition": "all 500ms ease", "-ms-transition": "all 500ms ease", "-o-transition": "all 500ms ease", "transition": "all 500ms ease"});
    $(".school").css({"display": "inline-block", "-webkit-transition": "all 500ms ease", "-moz-transition": "all 500ms ease", "-ms-transition": "all 500ms ease", "-o-transition": "all 500ms ease", "transition": "all 500ms ease"});
  });   
  $('li#supermarkets').click(function() {
    $(".retailstore").css({"display": "none", "-webkit-transition": "all 500ms ease", "-moz-transition": "all 500ms ease", "-ms-transition": "all 500ms ease", "-o-transition": "all 500ms ease", "transition": "all 500ms ease"});
    $(".officeType").css({"display": "none", "-webkit-transition": "all 500ms ease", "-moz-transition": "all 500ms ease", "-ms-transition": "all 500ms ease", "-o-transition": "all 500ms ease", "transition": "all 500ms ease"});
    $(".school").css({"display": "none", "-webkit-transition": "all 500ms ease", "-moz-transition": "all 500ms ease", "-ms-transition": "all 500ms ease", "-o-transition": "all 500ms ease", "transition": "all 500ms ease"});
    $(".superm").css({"display": "inline-block", "-webkit-transition": "all 500ms ease", "-moz-transition": "all 500ms ease", "-ms-transition": "all 500ms ease", "-o-transition": "all 500ms ease", "transition": "all 500ms ease"});
  }); 
  $('li#office').click(function() {
    $(".retailstore").css({"display": "none", "-webkit-transition": "all 500ms ease", "-moz-transition": "all 500ms ease", "-ms-transition": "all 500ms ease", "-o-transition": "all 500ms ease", "transition": "all 500ms ease"});
    $(".officeType").css({"display": "inline-block", "-webkit-transition": "all 500ms ease", "-moz-transition": "all 500ms ease", "-ms-transition": "all 500ms ease", "-o-transition": "all 500ms ease", "transition": "all 500ms ease"});
    $(".school").css({"display": "none", "-webkit-transition": "all 500ms ease", "-moz-transition": "all 500ms ease", "-ms-transition": "all 500ms ease", "-o-transition": "all 500ms ease", "transition": "all 500ms ease"});
    $(".superm").css({"display": "none", "-webkit-transition": "all 500ms ease", "-moz-transition": "all 500ms ease", "-ms-transition": "all 500ms ease", "-o-transition": "all 500ms ease", "transition": "all 500ms ease"});
  });        
</script>