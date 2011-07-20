$(document).ready(function() {
  $("li.build").click(function (e) {
    window.location.href = $(this).find('a').attr('href');
  });
});
