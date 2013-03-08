$(document).ready ->
  loadWithPjax = ->
    # update the position of the caret
    $("li.build.selected").removeClass "selected"
    a = $(this)
    li = a.parent("li.build").addClass("selected")
    $.pjax
      url: a.attr("href")
      container: ".latest-build"
      timeout: 3000
      success: -> # update the list entry that was clicked
        status = $(".latest-build .project_status").text()
        a.text a.text().replace(/[^\d\s]+/, status)
        li.removeAttr("class").attr "class", "build selected " + status
    false

  $("li.build").click ->
    loadWithPjax.call $(this).find("a")[0]

  $(".build a").click loadWithPjax
