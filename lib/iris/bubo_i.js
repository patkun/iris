function getagree(e) {
    var classList = e.className.split(/\s+/);
    var r = /^cong[0-9a-z-]+$/;
    for (var i = 0; i < classList.length; i++) {
        if (r.test(classList[i])) {
            m = r.exec(classList[i]);
            return m[0];
        }
    }
}


$(function(){
    $(document).tooltip();

    $('span.agree').hover(function(){
        var c = 'span.' + getagree(this);
        console.log(c);
        $(c).css({"text-decoration":"underline"});
    },function(){
        var c = '.' + getagree(this);
        $(c).css({"text-decoration":"none"});
    });
})
