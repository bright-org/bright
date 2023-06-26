import { Chart } from 'chart.js/auto';
export const gemHooks = {
  gem: {
    mounted() {
      gem(this.el);
    },
    updated() {
      gem(this.el);
    },
  }
};

const gem = (element) => {
  const dataset = element.dataset;
  const labels = JSON.parse(dataset.labels);
  const data = JSON.parse(dataset.data);
  let data2 = undefined;
  const color = getColorPattern(data.length, ["#72EAD9C0", "#3CC0A8C0", "#1DA091C0"]);
  const color2 = getColorPattern(data.length, ["#E4BDE9AA", "#C063CDAA", "#9510B1AA"]);
  const datasets = [];
  datasets.push(createData(data));

  if (dataset.data2.length != 0) {
    data2 = JSON.parse(dataset.data2);
    datasets.push(createData(data2));
  }

  const chartJson = {
    type: 'radar',
    data: {
      labels: labels,
      datasets: datasets
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
          backgroundColor: '#D4F9F7',
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

  const ctx = document.querySelector('#' + element.id + ' canvas');
  const myChart = new Chart(ctx, chartJson);

  function beforeDatasetsDraw(chart) {
    const context = chart.ctx;
    const data = chart.data.datasets[0].data;

    if (data2 !== undefined) {
      for (var i = 0; i < data2.length; i++) {
        fillSurface(chart, data2, i, color2[i]);
      }
    }

    for (let i = 0; i < data.length; i++) {
      fillSurface(chart, data, i, color[i]);
    }

    for (let i = 1; i < 5; i++) {
      drawGridline(chart, 20 * i, data.length);
    }

    const img = new Image();
    img.src = "/images/icon_001.png";

    ///padding rightで拡張しないと、一番右にに表示するアイコンが削れる
    img.onload = function () {
      for (let i = 0; i < data.length; i++) {
        let label = chart.scales.r.getPointLabelPosition(i);
        context.drawImage(img, label.right + 2, label.top - 5, 20, 20);
      }
    }

    for (let i = 0; i < data.length; i++) {
      drawUnderline(chart, i)
    }
  }

  function fillSurface(chart, data, index, color) {
    const context = chart.ctx;

    const startValue = data[(index % data.length)];
    const endValue = data[((index + 1) % data.length)];
    const endIndex = ((index + 1) % data.length);

    const v0 = chart.scales.r.getPointPositionForValue(0, 0);
    const v1 = chart.scales.r.getPointPositionForValue(index, startValue);
    const v2 = chart.scales.r.getPointPositionForValue(endIndex, endValue);
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
    const context = chart.ctx;
    const v0 = chart.scales.r.getPointPositionForValue(0, value);
    context.beginPath();
    context.moveTo(v0.x, v0.y);
    context.strokeStyle = "#FFFFFF44";

    for (let i = 1; i < length; i++) {
      chart.scales.r.getPointPositionForValue(i, value);
      let v1 = chart.scales.r.getPointPositionForValue(i, value);
      context.lineTo(v1.x, v1.y);
    }
    context.lineTo(v0.x, v0.y);
    context.stroke();
  }

  function drawUnderline(chart, i) {
    const context = chart.ctx;
    const label = chart.scales.r.getPointLabelPosition(i);
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
    for (let i = 0; i < length; i++) {
      let label = myChart.scales.r.getPointLabelPosition(i);
      let judge = (x >= label.left) && (x <= label.right) && (y >= label.top) && (y <= label.bottom)
      if (judge) { alert('リンククリック：' + myChart.data.labels[i]) }
    }

    // アイコン判定例
    for (let i = 0; i < length; i++) {
      let label = myChart.scales.r.getPointLabelPosition(i);
      let judge = (x >= label.right + 2) && (x <= label.right + 20 + 2) && (y >= label.top - 5) && (y <= label.top + 20 - 5)
      if (judge) { alert('アイコンクリック：' + myChart.data.labels[i]) }
    }

  });

  function getColorPattern(length, colors) {
    const pattern = [];
    // lengthが3未満は描画できない前提

    // lengthが4の時は先頭から2色の交互
    if (length == 4) {
      for (let i = 0; i < length; i++) {
        pattern.push(colors[i % 2]);
      }
      return pattern;
    }

    // lengthが3で割り切れる時
    if (length % 3 == 0) {
      for (let i = 0; i < length; i++) {
        pattern.push(colors[i % colors.length]);
      }
      return pattern;
    }

    // lengthが3で割り切れるない時は3色の繰り返しで、最後は先頭から2番目の色を代入
    for (let i = 0; i < length - 1; i++) {
      pattern.push(colors[i % colors.length]);
    }
    pattern.push(colors[1]);
    return pattern;
  }

  function createData(data) {
    return {
      label: '',
      data: data,
      borderColor: '#FFFFFF00',
      backgroundColor: '#FFFFFF00',
      borderWidth: 0,
      pointRadius: 0,
    }
  }
};

