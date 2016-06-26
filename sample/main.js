$(document).ready(function(){
  var image = null;

  $('#select-file').change(function(e){
    var canvas = document.getElementById('canvas-input');
    if (!canvas || !canvas.getContext) {
      return
    }
    var ctx = canvas.getContext('2d');
    if (e.target.files.length === 0) {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      return
    }

    var file = e.target.files;
    var reader = new FileReader();
    reader.readAsDataURL(file[0]);
    reader.onload = function(){
      var img = new Image();
      img.src = reader.result;
      var width = img.naturalWidth;
      var height = img.naturalHeight;

      $(canvas).prop('width', width);
      $(canvas).prop('height', height);
      ctx.drawImage(img, 0, 0, width, height);
      image = ctx.getImageData(0, 0, width, height)
    };
  });


  $('.contrast').click(function(e){
    if (image === null) {
      alert('先に画像を読み込んでください。');
      return
    }

    var canvas = document.getElementById('canvas-output');
    if (!canvas || !canvas.getContext) {
      return
    }
    var ctx = canvas.getContext('2d');
    $(canvas).prop('width', image.width);
    $(canvas).prop('height', image.height);

    // パラメータ取得
    var contrastMin = parseFloat($('.contrast-min').val());
    var contrastMax = parseFloat($('.contrast-max').val());
    if (isNaN(contrastMin) || isNaN(contrastMax)) {
      alert("数字以外は入れないでください");
      return
    }
    if ( contrastMin >= contrastMax ) {
      alert("入力値を見直してください");
      return
    }

    // 画像処理開始
    var dst = IP.contrast(image, contrastMin, contrastMax);
    ctx.putImageData(dst, 0, 0);
  });

  $('.change-saturation').click(function(e){
    if (image === null) {
      alert('先に画像を読み込んでください。');
      return
    }

    var canvas = document.getElementById('canvas-output');
    if (!canvas || !canvas.getContext) {
      return
    }
    var ctx = canvas.getContext('2d');
    $(canvas).prop('width', image.width);
    $(canvas).prop('height', image.height);

    // パラメータ取得
    var color = $('#color-select').val();
    var colorRange = parseFloat($('#color-range').val());
    var c = parseFloat($('#saturation-c').val());
    if (isNaN(colorRange) || isNaN(c)) {
      alert("数字以外は入れないでください");
      return
    }

    // 画像処理開始
    var dst = IP.changeSaturation(image, color, colorRange, c);
    ctx.putImageData(dst, 0, 0);
  });


  $('.sharpening').click(function(e){
    if (image === null) {
      alert('先に画像を読み込んでください。');
      return
    }

    var canvas = document.getElementById('canvas-output');
    if (!canvas || !canvas.getContext) {
      return
    }
    var ctx = canvas.getContext('2d');
    $(canvas).prop('width', image.width);
    $(canvas).prop('height', image.height);

    // パラメータ取得
    var k = parseFloat($('#sharpening-value').val());
    if (isNaN(k)) {
      alert("数字以外は入れないでください");
      return
    }

    // 画像処理開始
    var filter = [
      -k/9, -k/9, -k/9,
      -k/9, 1+8*k/9, -k/9,
      -k/9, -k/9, -k/9
    ];
    var dst = IP.execConvolution(image, filter);
    ctx.putImageData(dst, 0, 0);
  });


  $('.smooth').click(function(e){
    if (image === null) {
      alert('先に画像を読み込んでください。');
      return
    }

    var canvas = document.getElementById('canvas-output');
    if (!canvas || !canvas.getContext) {
      return
    }
    var ctx = canvas.getContext('2d');
    $(canvas).prop('width', image.width);
    $(canvas).prop('height', image.height);

    // パラメータ取得
    var size = parseInt($('#smooth-size').val());
    if (isNaN(size)) {
      alert('数字以外は入れないでください');
      return
    }
    if (size % 2 == 0) {
      alert('奇数のみです');
      return
    }


    // 画像処理開始
    var filter = [];
    for (var i = 0; i < size*size; i++) {
      filter.push(1.0 / (size*size))
    }

    var dst = IP.execConvolution(image, filter);
    ctx.putImageData(dst, 0, 0);
  });

});
