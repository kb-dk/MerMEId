$(function () {
    $("#year_slider").slider({
        range: true,
        min: 1865,
        max: 1931,
        values:[1880, 1920],
        slide: function (event, ui) {
            $("#notbefore").val(ui.values[0]);
            $("#notafter").val(ui.values[1]);
        }
    });
    $("#notbefore").val($("#year_slider").slider("values", 0));
    $("#notafter").val($("#year_slider").slider("values", 1));
});
