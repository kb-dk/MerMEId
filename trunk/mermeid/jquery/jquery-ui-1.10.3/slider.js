$(function () {
    $("#year_slider").slider({
        range: true,
        min: 1800,
        max: 1950,
        values:[1900, 1910],
        slide: function (event, ui) {
            $("#notbefore").val(ui.values[0]);
            $("#notafter").val(ui.values[1]);
        }
    });
    $("#notbefore").val($("#year_slider").slider("values", 0));
    $("#notafter").val($("#year_slider").slider("values", 1));
});

function setYearSlider() {
    $("#year_slider").slider( "values", [ document.getElementById("notbefore_hidden").value , document.getElementById("notafter_hidden").value ] );
    $("#notbefore").val($("#year_slider").slider("values", 0));
    $("#notafter").val($("#year_slider").slider("values", 1));
}