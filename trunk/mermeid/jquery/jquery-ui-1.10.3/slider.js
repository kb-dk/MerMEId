$(function () {
/* instantiates the year range selection slider  */ 
    var min_year = 1880;
    var max_year = 1931
    $("#year_slider").slider({
        range: true,
        min: min_year,
        max: max_year,
        values: [ $("#notbefore").val() || min_year, $("#notafter").val() || max_year],
        slide: function (event, ui) {
            $("#notbefore").val(ui.values[0]);
            $("#notafter").val(ui.values[1]);
        }
    });
    $("#notbefore").val($("#year_slider").slider("values",0));
    $("#notafter").val($("#year_slider").slider("values",1));
});

function setYearSlider(notbefore, notafter) {
/* call without arguments to update slider according to notebefore/notafter inputs   */
/* or call with year values to set or change selected range                          */
    notbefore = notbefore || $("#notbefore").val();
    notafter  = notafter  || $("#notafter").val();
    $("#year_slider").slider( "values", [ notbefore, notafter ] );
    $("#notbefore").val(notbefore);
    $("#notafter").val(notafter);
}