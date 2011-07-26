$(document).ready(function() {
  
  var loadWithPjax = function() {
    // update the position of the caret
    $('li.build.selected').removeClass('selected');
    var a = $(this), li = a.parent('li.build').addClass('selected');
    
    $.pjax({
      url: a.attr('href'), 
      container: '.latest-build', 
      timeout: 3000,
      success: function() { // update the list entry that was clicked
        var status = $('.latest-build .project_status').text();
        a.text(a.text().replace(/[^\d\s]+/, status));
        li.removeAttr('class').attr('class', 'build selected ' + status);
      }
    });
    return false;
  };
  
  $("li.build").click(function() {
    loadWithPjax.call($(this).find('a')[0]);
  });

  $('.build a').click(loadWithPjax);
  
  $('.timeago').timeago();
});
