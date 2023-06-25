// TODO: chart.jsのimportの位置がここで良いか確認
// TODO: 直接gemのページを開かないと描画されない問題を解決すること
// TODO: storybookではhooksが動作しない問題を解決すること

import {Chart} from 'chart.js/auto';
export const gemHooks = {
  gem: {
    mounted() {
      gem();
    },
    updated() {
      gem();
    },
  }
};

const gem = () => {
  // TODO:データを受け渡せるようにする
  let element = document.getElementById('gem');
  var data =  JSON.parse(element.dataset.data);
  var labels = ['Elixir本体', 'ライブラリ', '環境構築', '関連スキル', 'デバッグ', 'テスト'];
  var color = ["#82FAE9", "#40DEC6", "#52CCB5", "#82FAE9", "#40DEC6", "#52CCB5"];

  var chartJson = {
    type: 'radar',
    data: {
      labels: labels,
      datasets: [{
        label: '',
        data: data,
        borderColor: '#FFFFFF00',
        backgroundColor: '#FFFFFF00',
        borderWidth: 0,
        pointRadius: 0,
      },
      ]
    },
    options: {
      animation: false,
      responsive: false,
      maintainAspectRatio: false,
      layout: {
        padding: {
          right: 22
        }
      },
      gridLines: {
        circular: true
      },
      plugins: {
        legend: {
          display: false
        },
        tooltip: {
          enabled: false,
        }
      },
      scales: {
        r: {
          min: 0,
          max: 100,
          backgroundColor: '#F6FDFD',
          grid: {
            display: false
          },
          angleLines: {
            display: false
          },
          ticks: {
            stepSize: 20,
            display: false
          },
          pointLabels: {
            color: '#0000FF',
            backdropPadding: 5,
            padding: 20,
          },
        },
      },
    },
    plugins: [{ beforeDatasetsDraw: beforeDatasetsDraw }]
  };

  var ctx = document.getElementById('mychart');
  var myChart = new Chart(ctx, chartJson);

  function beforeDatasetsDraw(chart) {
    var context = chart.ctx;
    var data = chart.data.datasets[0].data;

    for (var i = 0; i < data.length; i++) {
      fillSurface(chart, data, i, color[i]);
    }

    for (var i = 1; i < 5; i++) {
      drawGridline(chart, 20 * i, data.length);
    }

    var img = new Image();
    img.src = "/images/icon_001.png";

    ///padding rightで拡張しないと、一番右にに表示するアイコンが削れる
    img.onload = function () {
      for (var i = 0; i < data.length; i++) {
        let label = chart.scales.r.getPointLabelPosition(i);
        context.drawImage(img, label.right + 2, label.top -5, 20, 20);
      }
    }

    for (var i = 0; i < data.length; i++) {
      drawUnderline(chart, i)
    }
  }

  function fillSurface(chart, data, index, color) {
    var context = chart.ctx;

    startValue = data[(index % data.length)];
    endValue = data[((index + 1) % data.length)];
    endIndex = ((index + 1) % data.length);

    var v0 = chart.scales.r.getPointPositionForValue(0, 0);
    var v1 = chart.scales.r.getPointPositionForValue(index, startValue);
    var v2 = chart.scales.r.getPointPositionForValue(endIndex, endValue);
    context.beginPath();
    context.strokeStyle = color;
    context.moveTo(v0.x, v0.y);
    context.lineTo(v1.x, v1.y);
    context.lineTo(v2.x, v2.y);
    context.lineTo(v0.x, v0.y);
    context.fillStyle = color;
    context.fill();
  }

  function drawGridline(chart, value, length) {
    var context = chart.ctx;
    var v0 = chart.scales.r.getPointPositionForValue(0, value);
    context.beginPath();
    context.moveTo(v0.x, v0.y);
    context.strokeStyle = "#FFFFFF44";

    for (var i = 1; i < length; i++) {
      chart.scales.r.getPointPositionForValue(i, value);
      var v1 = chart.scales.r.getPointPositionForValue(i, value);
      context.lineTo(v1.x, v1.y);
    }
    context.lineTo(v0.x, v0.y);
    context.stroke();
  }

  function drawUnderline(chart, i) {
    var context = chart.ctx;
    var label = chart.scales.r.getPointLabelPosition(i);
    context.beginPath();
    context.lineWidth = 1;
    context.strokeStyle = '#0000ff';
    context.moveTo(label.left, label.bottom);
    context.lineTo(label.right, label.bottom);
    context.stroke();
  }

  ctx.addEventListener('click', function (event) {
    //padding rightで拡張した部分がクリック判定できるようにする

    const rect = ctx.getBoundingClientRect();
    const x = event.clientX - rect.left;
    const y = event.clientY - rect.top;

    length = myChart.data.labels.length;

    // リンクの判定例
    for (var i = 0; i < length; i++) {
      let label = myChart.scales.r.getPointLabelPosition(i);
      var judge = (x >= label.left) && (x <= label.right) && (y >= label.top) && (y <= label.bottom)
      if (judge) { alert('リンククリック：' + myChart.data.labels[i]) }
    }

    // アイコン判定例
    for (var i = 0; i < length; i++) {
      let label = myChart.scales.r.getPointLabelPosition(i);
      var judge = (x >= label.right + 2) && (x <= label.right + 20 + 2) && (y >= label.top - 5) && (y <= label.top + 20 - 5)
      if (judge) { alert('アイコンクリック：' + myChart.data.labels[i]) }
    }

  });

};

