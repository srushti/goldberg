// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function(){
  setup_timestamp_refreshing();
});

function setup_timestamp_refreshing() {
  $('.timeago').timeago();
}
