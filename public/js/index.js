$(document).ready(function(){

    function injectProducts(data, node) {
        $.each(data, function(i, product) {
            $(node).append('<div class="col s6 m6 l3"><div class="card"><div class="card-image"><img src="' + product.image + '"></div><div class="card-content"><p>' + product.title + '</p></div><div class="card-action"><a href="' + product.url + '">Buy for ' + product.price + '</a></div></div></div>')
        })
    }

    function renderResults(data) {
        $('#results').empty();
        $('#results').append('<div class="row"><div class="s12"><ul class="tabs"><li class="tab col s3"><a href="#emag">eMAG</a></li><li class="tab col s3"><a href="#amazon">Amazon</a></li><li class="tab col s3"><a href="#olx">OLX</a></li></ul></div><div id="emag" class="col s12"><div class="row center"><h5>Results for ' + data.ro_keyword + '</h5></div></div><div id="amazon" class="col s12"><div class="row center"><h5>Results for ' + data.en_keyword + '</h5></div></div><div id="olx" class="col s12"><div class="row center"><h5>Results for ' + data.ro_keyword + '</h5></div></div></div>');
        injectProducts(data.emag, '#emag');
        injectProducts(data.amazon, '#amazon');
        injectProducts(data.olx, '#olx');
        $('.tabs').tabs();
        $('#main-form').show();
        $('#loader').hide();
    }

    function readFile(input) {
        $('#main-form').hide();
        $('#loader').show();
        if (input.files && input.files[0]) {
            var reader = new FileReader();
            reader.onload = function (e) {
                $('.upload-demo').addClass('ready');
                $.ajax({
                    type: 'POST',
                    url: '/find',
                    data: {image: e.target.result},
                    success: function(data) {
                        console.log(data);
                        if (data.status >= 0) {
                            renderResults(data)
                        } else {
                            $('#main-form h5').text(data.error);
                            $('#main-form').show();
                            $('#loader').hide();
                        }
                    }
                })
            }
            reader.readAsDataURL(input.files[0]);
        }
        else {
            console.warn("Sorry - you're browser doesn't support the FileReader API");
        }
    }

    $('#upload').on('change', function () { readFile(this); });

});
