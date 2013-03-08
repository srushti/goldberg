class @Refresher
  constructor: (@url, @interval) ->

  setup_timestamp_refreshing: ->
    $(".timeago").timeago()

  setup_status_refreshing: ->
    url = @url
    $time = new Date()
    self = this
    setInterval (->
      $.ajax
        type: "GET"
        url: url
        error: (xhr, statusText) ->
          $(".error").remove()
          $("#all-projects").append "<p class='error'>connection to server failed, status was last updated at " + $time + ".</p>"
        success: self.success_callback
    ), @interval

    success_callback: (response) ->
      $(".error").remove()
      $("#all-projects").remove()
      $(".page").append response
      @setup_timestamp_refreshing()
