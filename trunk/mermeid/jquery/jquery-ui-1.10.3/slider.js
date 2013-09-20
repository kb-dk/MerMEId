$(function () {
/* instantiates the year range selection slider  */ 
    $("#year_slider").slider({
        range: true,
        min: 1800,
        max: 1950,
        values: [ document.getElementById("notbefore").value, document.getElementById("notafter").value ],
        slide: function (event, ui) {
            $("#notbefore").val(ui.values[0]);
            $("#notafter").val(ui.values[1]);
        }
    });
});

function setYearSlider(notbefore, notafter) {
/* call without arguments to update slider according to notebefore/notafter inputs   */
/* or call with year values to set or change selected range                          */
    notbefore = notbefore || document.getElementById("notbefore").value;
    notafter  = notafter  || document.getElementById("notafter").value;
    $("#year_slider").slider( "values", [ notbefore, notafter ] );
    $("#notbefore").val(notbefore);
    $("#notafter").val(notafter);
}