function getagree(e) {
    var classList = e.className.split(/\s+/);
    var r = /^cong[0-9a-z-]+$/;
    var agreelist = new Array();
    for (var i = 0; i < classList.length; i++) {
        if (r.test(classList[i])) {
            m = r.exec(classList[i]);
            agreelist.push(m[0]);
        }
    }
    return agreelist
}

function getvocab(e) {
    var classList = e.className.split(/\s+/);
    var r = /^vocab([0-9]+)$/;
    for (var i = 0; i < classList.length; i++) {
        if (r.test(classList[i])) {
            m = r.exec(classList[i]);
            return m[1];
        }
    }
}

function getnota(e) {
    var classList = e.className.split(/\s+/);
    var r = /^nota([0-9]+)$/;
    for (var i = 0; i < classList.length; i++) {
        if (r.test(classList[i])) {
            m = r.exec(classList[i]);
            return m[1];
        }
    }
}


$(function(){
    $('span.agree').hover(function(){
        a = getagree(this);
        for (var i = 0; i < getagree(this).length; i++) {
            var c = 'span.' + a[i];
            $(c).css({"background-color":"wheat"});
            $(c+".subj").css({"background-color":"#FF3300"});
            $(c+".verb").css({"background-color":"lightblue"});
            $(c+".ablabs").css({"background-color":"#80E6B2"});
        }
    },function(){
        a = getagree(this);
        for (var i = 0; i < getagree(this).length; i++) {
            var c = '.' + a[i];
            $(c).css({"background-color":"white"});
        }
    });

    $('div#vocab_box').css({"margin-right":"10px"}).hide();
    $('div#nota_box').css({"background-color":"lightgray"}).hide();

    $('span.vocab_anchor').hover(
        function(){
            $('div#vocab_box').html(vocab[getvocab(this)]).show();
        },
        function(){
            $('div#vocab_box').hide();
        }
    );

    $('span.nota_anchor').hover(
        function(){
            $('div#nota_box').html(nota[getnota(this)]).show();
        },
        function(){
            $('div#nota_box').hide();
        }
    );
});
