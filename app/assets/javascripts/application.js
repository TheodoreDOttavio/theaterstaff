//= require jquery
//= require bootstrap
//= require turbolinks
//= require cocoon

$(document).on('page:load', function() {
  $("#performance_closeing").datepicker({
    dateFormat: 'yy-mm-dd'
  });
  $("#performance_opening").datepicker({
    dateFormat: 'yy-mm-dd'
  });
});