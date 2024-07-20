import { Chart } from "chart.js/auto";
const scalesBackgroundColor = "#D4F9F7";
const gridColor = "#FFFFFF44";
const myselfColorPattern = ["#72EAD9C0", "#1DA091C0", "#3CC0A8C0"];
const otherColorPattern = ["#D659F0AA", "#7B0D92AA", "#BC14E0AA"];
const pastColorPattern = ["#FFFFFF55", "#FFFFFF55", "#FFFFFF55"];
const linkColor = "#0000FF";
const backgroundColor = "#FFFFFF";
const minValue = -5;
const gemSizeSet = {
  // サイズと主な使用箇所
  // sm: スキル検索(スキルジェム), マイページ(スキルバランス)
  // sp: スマートフォン用途 スキルジェム
  // md: チームスキル分析
  "default": {width: "535px", height: "450px"},
  "sm": {width: "250px", height: "165px"},
  "sp": {width: "340px", height: "300px"},
  "md": {width: "450px", height: "400px"}
}
const labelFontSet = {
  "default": {size: 12},
  "sm": {size: 10},
  "sp": {size: 12},
  "md": {size: 12}
}

const getColorPattern = (length, colors) => {
  const pattern = [];
  if (length < 3) return;

  // lengthが4の時は先頭から2色（薄い、濃い）の交互
  if (length === 4) {
    for (let i = 0; i < length; i++) {
      pattern.push(colors[i % 2]);
    }
    return pattern;
  }

  // lengthが3で割り切れる時
  if (length % 3 === 0) {
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
};

const createData = (data) => {
  return {
    label: "",
    data: data,
    borderColor: "#FFFFFF00",
    backgroundColor: "#FFFFFF00",
    borderWidth: 0,
    pointRadius: 0,
  };
};

const fillSurface = (chart, data, index, color) => {
  const context = chart.ctx;

  const startValue = data[index % data.length];
  const endValue = data[(index + 1) % data.length];
  const endIndex = (index + 1) % data.length;

  const v0 = chart.scales.r.getPointPositionForValue(0, minValue);
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
};

const fillSurfaces = (chart, data, color) => {
  for (let i = 0; i < data.length; i++) {
    fillSurface(chart, data, i, color[i]);
  }
};
const drawGridline = (chart, value, length) => {
  const context = chart.ctx;
  const v0 = chart.scales.r.getPointPositionForValue(0, value);
  context.beginPath();
  context.moveTo(v0.x, v0.y);
  context.strokeStyle = gridColor;

  for (let i = 1; i < length; i++) {
    chart.scales.r.getPointPositionForValue(i, value);
    const v1 = chart.scales.r.getPointPositionForValue(i, value);
    context.lineTo(v1.x, v1.y);
  }
  context.lineTo(v0.x, v0.y);
  context.stroke();
};

const drawUnderline = (chart, i) => {
  const context = chart.ctx;
  const label = chart.scales.r.getPointLabelPosition(i);
  context.beginPath();
  context.lineWidth = 1;
  context.strokeStyle = linkColor;
  context.moveTo(label.left, label.bottom);
  context.lineTo(label.right, label.bottom);
  context.stroke();
};

const beforeDraw = (chart) => {
  const context = chart.ctx;
  context.fillStyle=backgroundColor;
  context.fillRect(0,0,context.canvas.width, context.canvas.height);
};

const beforeDatasetsDraw = (chart) => {
  const context = chart.ctx;
  const colorTheme = chart.canvas.parentNode.dataset.colorTheme;
  const myselfData = chart.data.datasets[0].data;
  const diffData =
    chart.data.datasets[1] !== undefined ? chart.data.datasets[1].data : [];
  const myselfColor = getColorPattern(myselfData.length, myselfColorPattern);
  const otherColor = getColorPattern(myselfData.length, otherColorPattern);
  const pastColor = getColorPattern(myselfData.length, pastColorPattern);
  const diffColor = colorTheme === "myself" ? pastColor : otherColor;
  const isLink = JSON.parse(context.canvas.parentElement.dataset.displayLink);


  if (colorTheme === "myself") {
    fillSurfaces(chart, myselfData, myselfColor);
    fillSurfaces(chart, diffData, diffColor);
  } else {
    fillSurfaces(chart, diffData, diffColor);
    fillSurfaces(chart, myselfData, myselfColor);
  }

  for (let i = 1; i < 5; i++) {
    drawGridline(chart, 20 * i, myselfData.length);
  }

  // リンク非表示はこれ以降は処理をしない
  if (!isLink) return;

  // α版はskill_upを表示しない
  // const img = new Image()
  // img.src = "/images/icon_up_green.svg"

  // const iconWidth = 21
  // const iconHeight = 21

  // // padding rightで拡張しないと、一番右にに表示するアイコンが削れる
  // img.onload = function () {

  //   for (let i = 0; i < myselfData.length; i++) {
  //     const label = chart.scales.r.getPointLabelPosition(i);
  //     context.drawImage(img, label.right + 2, label.top - 4, iconWidth, iconHeight)
  //   }
  // }

  for (let i = 0; i < myselfData.length; i++) {
    drawUnderline(chart, i);
  }
};

const afterDatasetsDraw = (chart, ease) => {
    const context = chart.ctx;
    // グラフ生成後のイメージ作成
    let growth_graph_data = document.getElementById("growth_graph_data");
    if (growth_graph_data == null) return;
    if (context.canvas.width > 714) return;
    let og_image = document.getElementById("og_image");
    if (og_image == null) return;
    html2canvas(document.querySelector("#og_image")).then(canvas => {
      console.log(canvas)
      let growth_graph_data = document.getElementById("growth_graph_data");
      if (growth_graph_data == null) return;
      growth_graph_data.value = canvas.toDataURL("image/png");
      growth_graph_data.click();
    });

};

const createChartFromJSON = (labels, datasets, isLink, labelFont) => {
  const color = isLink ? linkColor : "#000000";
  const rightPadding = isLink ? 22 : 0;
  const pointLabelsPadding = isLink ? 25 : 5;
  return {
    type: "radar",
    data: {
      labels: labels,
      datasets: datasets,
    },
    options: {
      animation: false,
      responsive: true,
      maintainAspectRatio: false,
      layout: {
        padding: {
          right: rightPadding,
        },
      },
      gridLines: {
        circular: true,
      },
      plugins: {
        legend: {
          display: false,
        },
        tooltip: {
          enabled: false,
        },
      },
      scales: {
        r: {
          min: minValue,
          max: 100,
          backgroundColor: scalesBackgroundColor,
          grid: {
            display: false,
          },
          angleLines: {
            display: false,
          },
          ticks: {
            stepSize: 20,
            display: false,
          },
          // see: https://www.chartjs.org/docs/latest/axes/radial/linear.html#point-label-options
          // font 指定なしでデフォルト12とあるが画面をみるともっと小さく10あたりにみえる
          pointLabels: {
            color: color,
            backdropPadding: 5,
            padding: pointLabelsPadding,
            font: labelFont
          },
        },
      },
    },
    plugins: [{ beforeDraw: beforeDraw,
                beforeDatasetsDraw: beforeDatasetsDraw,
                afterDatasetsDraw: afterDatasetsDraw,
              }
    ],
  };
};

export const SkillGem = {
  drawRaderGraph(element) {
    if (window.myRadar == undefined) window.myRadar = [];
    const dataset = element.dataset;
    const labels = JSON.parse(dataset.labels);
    const data = JSON.parse(dataset.data);
    const gemSize = gemSizeSet[dataset.size] || gemSizeSet["default"]
    const labelFont = labelFontSet[dataset.size] || labelFontSet["default"]
    const isLink = JSON.parse(dataset.displayLink);
    const datasets = [];

    if (labels.length < 3) return;

    datasets.push(createData(data[0]));

    if (data[1] !== undefined) {
      datasets.push(createData(data[1]));
    }

    this.ctx = document.querySelector("#" + element.id + " canvas");
    window.myRadar[element.id] = new Chart(
      this.ctx,
      createChartFromJSON(labels, datasets, isLink, labelFont)
    );
    window.myRadar[element.id].canvas.parentNode.style.width = gemSize.width;
    window.myRadar[element.id].canvas.parentNode.style.height = gemSize.height;

    this.ctx.addEventListener("click", this.clickEvent);
  },
  clickEvent(event) {
    const element = event.target.parentElement;
    const ctx = event.target;
    const dataset = element.dataset;
    const isLink = JSON.parse(dataset.displayLink);
    if (!isLink) return;

    if (dataset.links === undefined) return;
    const links = JSON.parse(dataset.links);

    // padding rightで拡張した部分がクリック判定できるようにする
    const rect = ctx.getBoundingClientRect();
    const x = event.clientX - rect.left;
    const y = event.clientY - rect.top;
    const length = window.myRadar[element.id].data.labels.length;

    // リンクの判定例
    for (let i = 0; i < length; i++) {
      const label =
        window.myRadar[element.id].scales.r.getPointLabelPosition(i);
      const judge =
        x >= label.left &&
        x <= label.right &&
        y >= label.top &&
        y <= label.bottom;
      if (judge) {
        location.href = links[i];
        return;
      }
    }

    // α版はskill_upを表示しない
    // // アイコン判定例
    // for (let i = 0; i < length; i++) {
    //   const label = window.myRadar[element.id].scales.r.getPointLabelPosition(i)
    //   const judge = (x >= label.right + 2) && (x <= label.right + 20 + 2) && (y >= label.top - 5) && (y <= label.top + 20 - 5)
    //   if (judge) { alert('アイコンクリック：' + window.myRadar[element.id].data.labels[i]) }
    // }
  },
  mounted() {
    this.drawRaderGraph(this.el);
  },
  updated() {
    if (window.myRadar[this.el.id] == undefined) return;
    window.myRadar[this.el.id].destroy();
    this.ctx.removeEventListener("click", this.clickEvent);
    this.drawRaderGraph(this.el);
  },
};
