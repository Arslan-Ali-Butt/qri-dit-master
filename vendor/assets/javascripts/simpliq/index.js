$(document).ready(function(){
    var startFunctions = true;
    $('#main-menu-toggle').click(function(){
        if ($(this).hasClass('open')) {
            $(this).removeClass('open').addClass('close');

            var span = $('#content').attr('class');
            var spanNum = parseInt(span.replace( /^\D+/g, ''));
            var newSpanNum = spanNum + 2;
            var newSpan = 'span' + newSpanNum;

            $('#content').addClass('full');
            $('.navbar-brand').addClass('noBg');
            $('#sidebar-left').hide();

        } else {
            $(this).removeClass('close').addClass('open');

            var span = $('#content').attr('class');
            var spanNum = parseInt(span.replace( /^\D+/g, ''));
            var newSpanNum = spanNum - 2;
            var newSpan = 'span' + newSpanNum;

            $('#content').removeClass('full');
            $('.navbar-brand').removeClass('noBg');
            $('#sidebar-left').show();
        }
    });
});
