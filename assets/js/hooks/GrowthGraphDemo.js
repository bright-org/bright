import { Chart } from "chart.js/auto";
const dash = [5, 3];
const padding = 70;
const dashColor = "#97ACAC";
const myselfBorderColor = "#52CCB5";
const myselfPointColor = "#96D1B7";
const myselfSelectedColor = "#008971";
const myselfFillStartColor = "#B6F1E7FF";
const myselfFillEndColor = "#B6F1E700";
const otherBorderColor = "#C063CD";
const otherPointColor = "#E4BDE9";
const otherSelectedColor = "#9510B1";
const roleBorderColor = "#A9BABA";
const rolePointColor = "#D5DCDC";
const futurePointColor = "#FFFFFF";
const nowColor = "#B77285";
const nowSelectColor = "#B71225";

const dataDivision = (data, futureDisplay) => {
  if (data === undefined) return [[], []];

  // index:0はグラフ上にない1つ過去なので除去（別途描画で使う）
  data = data.slice(1);

  // 未来表示状態でなければ、そのまま返す。通常ロジックで全データを描画できる
  if (!futureDisplay) return [data, []];

  // 未来表示状態は間に「現在」が入るので描画しないようにデータを分離
  const past = data.map((x, index) => (index > 3 ? null : x));
  const future = data.map((x, index) => (index < 3 ? null : x));

  return [past, future];
};

const createDataset = (
  data,
  borderColor,
  pointBackgroundColor,
  pointBorderColor,
  isFuture
) => {
  return {
    data: data,
    borderColor: borderColor,
    pointRadius: 8,
    pointBackgroundColor: pointBackgroundColor,
    pointBorderColor: pointBorderColor,
    borderDash: isFuture ? dash : [],
  };
};

const createData = (data) => {
  const futureDisplay = data["futureDisplay"] === undefined ? true : data["futureDisplay"]
  const otherFutureDisplay = data["otherFutureDisplay"] === undefined ? true : data["otherFutureDisplay"]
  const roleFutureDisplay = data["roleFutureDisplay"] === undefined ? true : data["roleFutureDisplay"]

  const [myselfData, myselfFuture] = dataDivision(data["myself"], futureDisplay);
  const [otherData, otherFuture] = dataDivision(data["other"], otherFutureDisplay);
  const [roleData, roleFuture] = dataDivision(data["role"], roleFutureDisplay);
  const datasets = [];

  datasets.push(
    createDataset(
      myselfData,
      myselfBorderColor,
      myselfPointColor,
      myselfPointColor,
      false
    )
  );
  // TODO: α版では未来非表示
  // if (futureDisplay) {
  //   datasets.push(createDataset(myselfFuture, myselfBorderColor, futurePointColor, myselfPointColor, true))
  // }
  datasets.push(
    createDataset(
      otherData,
      getOtherBorderColor(data),
      getOtherPointColor(data),
      getOtherPointColor(data),
      false
    )
  );
  // TODO: α版では未来非表示
  // if (futureDisplay) {
  //   datasets.push(createDataset(otherFuture, otherBorderColor, futurePointColor, otherPointColor, true))
  // }
  datasets.push(
    createDataset(
      roleData,
      roleBorderColor,
      rolePointColor,
      rolePointColor,
      false
    )
  );
  // TODO: α版では未来非表示
  // if (futureDisplay) {
  //   datasets.push(createDataset(roleFuture, roleBorderColor, futurePointColor, rolePointColor, true))
  // }

  return {
    labels: data.labels,
    datasets: datasets,
  };
};

const drawvVerticalLine = (context, scales, verticalPoints) => {
  const y = scales.y;
  const x = scales.x;

  context.lineWidth = 0.5;
  const upY = y.getPixelForValue(100);
  const downY = y.getPixelForValue(0);
  context.setLineDash(dash);
  context.strokeStyle = dashColor;

  context.beginPath();
  for (let i = 0; i < 5; i++) {
    const verticalX = x.getPixelForValue(i);
    const verticalValue = verticalPoints[i];

    if(verticalValue) {
      context.moveTo(verticalX, upY);
      context.lineTo(verticalX, downY);
    }
  }
  context.stroke();
};
const drawHorizonLine = (context, scales) => {
  // 見習い、平均、ベテランの線
  const y = scales.y;
  const x = scales.x;

  const startX = x.getPixelForValue(0) - padding;
  const endX = x.getPixelForValue(4) + padding;
  const downY = y.getPixelForValue(0);
  const normalY = y.getPixelForValue(40);
  const skilledY = y.getPixelForValue(60);
  context.lineWidth = 0.5;
  context.setLineDash([]);
  context.strokeStyle = dashColor;
  context.beginPath();
  // 下の線
  context.moveTo(startX, downY);
  context.lineTo(endX, downY);
  context.stroke();

  context.setLineDash(dash);

  // 平均の線
  context.beginPath();
  context.moveTo(startX, normalY);
  context.lineTo(endX, normalY);

  // ベテランの線
  context.moveTo(startX, skilledY);
  context.lineTo(endX, skilledY);
  context.stroke();
};

const drawMyselfNow = (chart, scales) => {
  const dataset = chart.canvas.parentNode.dataset;
  const data = JSON.parse(dataset.data)
  const now = data["myselfNow"]

  if (now === undefined || now === null) return;

  // 未来分も除いているためインデックス添え字の-1と合わせて-2
  // また数値をいれずに幅をとっているケースがあるので値が入っている個所までさかのぼる
  const futureIndex = data["myself"].length - 1
  let prevIndex = data["myself"].length - 2
  while(data["myself"][prevIndex] == null && prevIndex != 0) {
    prevIndex -= 1
  }

  drawNow(chart, scales, {
    nowValue: now,
    prevValue: data["myself"][prevIndex],
    futureIndex: futureIndex,
    prevIndex: prevIndex,
    values: data["myselfRecentSteps"],
    selected: (data["myselfSelected"] === "now"),
    axisColor: (data["myselfSelected"] === "now") ? nowSelectColor : nowColor,
    borderColor: myselfBorderColor,
    fillByGradation: true
  })
}

const drawOtherNow = (chart, scales) => {
  const dataset = chart.canvas.parentNode.dataset;
  const data = JSON.parse(dataset.data)
  const now = data["otherNow"]

  if (now === undefined || now === null) return;

  // 未来分も除いているためインデックス添え字の-1と合わせて-2
  const futureIndex = data["other"].length - 1
  let prevIndex = data["other"].length - 2
  while(data["other"][prevIndex] == null && prevIndex != 0) {
    prevIndex -= 1
  }

  drawNow(chart, scales, {
    nowValue: now,
    prevValue: data["other"][prevIndex],
    futureIndex: futureIndex,
    prevIndex: prevIndex,
    values: data["otherRecentSteps"],
    selected: (data["otherSelected"] === "now"),
    axisColor: (data["otherSelected"] === "now") ? nowSelectColor : nowColor,
    borderColor: getOtherBorderColor(data),
    fillByGradation: false
  })
}

const drawNow = (chart, scales, state) => {
  const context = chart.ctx;
  const y = scales.y;
  const x = scales.x;
  const drawNowColor = state.selected ? nowSelectColor : nowColor;

  context.setLineDash([2, 0]);
  context.strokeStyle = state.axisColor;
  const zeroY = y.getPixelForValue(0);
  const nowY = y.getPixelForValue(state.nowValue);
  const pastY = y.getPixelForValue(state.prevValue);


  // 各点取得
  // 取得時の差し値はグラフ上なのでprevIndexよりさらに-1した値
  // グラフ上に最初の過去点はないため
  const pastX = x.getPixelForValue(state.prevIndex - 1)
  const futureX = x.getPixelForValue(state.futureIndex - 1)
  const diffSize = state.futureIndex - state.prevIndex

  const diffPrevX = futureX - pastX
  const nowX = futureX - diffPrevX / (diffSize * 2)
  const diffX = nowX - pastX

  // 「現在」縦線
  context.lineWidth = state.selected ? 4 : 2
  context.beginPath()
  context.moveTo(nowX, zeroY)
  context.lineTo(nowX, nowY)
  context.stroke()

  // 過去から現在の描画点(x)を決める
  // 仮にsize: 1なら「現在」点のみ
  // 仮にsize: 2なら「現在」までの間にステップ点が1つ
  const size = state.values.length
  const stepX = diffX / size

  // 現在点に値を入れておく。現在の赤い点の描画のため
  const lastIndex = state.values.findLastIndex(v => v)
  const lastValue = state.values[lastIndex]
  state.values[size - 1] = lastValue

  // 線 直近の過去から現在まで
  let currentX = pastX
  let currentY = pastY
  let stepSize = 1

  state.values.forEach((value, index) => {
    if(value == null) {
      // 値がないのでスキップして次へ
      // 次の幅を大きく取るためにstepSizeで調整
      stepSize += 1
      return
    }

    const nextX = currentX + stepSize * stepX
    const nextY = y.getPixelForValue(value)

    context.lineWidth = 2;
    context.strokeStyle = state.borderColor;
    context.beginPath()
    context.moveTo(currentX, currentY)
    context.lineTo(nextX, nextY)
    context.stroke()

    // 直近から現在の点までの下側グラデーション
    // 現在の点描画前に実行しないと点がかすむためここで処理
    if(state.fillByGradation) {
      fillGradationPointToPoint(chart, scales, {x: currentX, y: currentY}, {x: nextX, y: nextY})
    }

    stepSize = 1
    currentX = nextX
    currentY = nextY
  })

  // 点 直近の過去から現在まで
  currentX = pastX
  currentY = pastY
  stepSize = 1

  state.values.forEach((value, index) => {
    if(value == null) {
      stepSize += 1
      return
    }

    const nextX = currentX + stepSize * stepX
    const nextY = y.getPixelForValue(value)
    const nowValue = (index == size - 1)
    const nowFocus = nowValue && state.selected

    context.beginPath();
    context.arc(
      nextX,
      nextY,
      nowFocus ? 8.5 : 4,
      (0 * Math.PI) / 180,
      (360 * Math.PI) / 180,
      false
    );
    // context.fillStyle = drawNowColor;
    // TODO: ↓仮実装のため比較先の色を考慮していない
    context.fillStyle = nowValue ? drawNowColor : myselfPointColor;
    context.fill();

    stepSize = 1
    currentX = nextX
    currentY = nextY
  })
};

// 2点の下側をグラデーションで塗る処理
const fillGradationPointToPoint = (chart, scales, p1, p2) => {
  const context = chart.ctx
  const gradient = context.createLinearGradient(0, 0, 0, 300)
  gradient.addColorStop(0, myselfFillStartColor)
  gradient.addColorStop(1, myselfFillEndColor)

  // zeroY XYグラフ上のy=0にあたる位置のy座標
  const zeroY = scales.y.getPixelForValue(0)

  // 1つ前の過去から現在を四角形で囲んでいる
  context.lineWidth = 1
  context.fillStyle = gradient;
  context.beginPath()
  context.moveTo(p1.x, zeroY)
  context.lineTo(p1.x, p1.y)
  context.lineTo(p2.x, p2.y)
  context.lineTo(p2.x, zeroY)
  context.lineTo(p1.x, zeroY)
  context.closePath()
  context.fill()
}

const drawSelectedLine = (chart, scales, dataname, selectedColor, index) => {
  if (index < 0) return;
  const context = chart.ctx;
  const dataset = chart.canvas.parentNode.dataset;
  // 現在のスコア
  const data = JSON.parse(dataset.data);
  let drawData = data[dataname];

  if (drawData === undefined) return;
  drawData = drawData.slice(1);

  const y = scales.y;
  const x = scales.x;
  const curentData = drawData[index];

  context.lineWidth = 4;
  context.setLineDash([]);
  context.strokeStyle = selectedColor;
  const selectedX = x.getPixelForValue(index);
  const selectedYDown = y.getPixelForValue(0);
  const selectedYUp = y.getPixelForValue(curentData);

  // 「選択している」縦線
  context.beginPath();
  context.moveTo(selectedX, selectedYDown);
  context.lineTo(selectedX, selectedYUp);
  context.stroke();
};

const drawSelectedPoint = (chart, scales, dataname, selectedColor, index) => {
  if (index < 0) return;

  const context = chart.ctx;
  const dataset = chart.canvas.parentNode.dataset;
  // 現在のスコア
  const data = JSON.parse(dataset.data);
  let drawData = data[dataname];

  if (drawData === undefined) return;
  drawData = drawData.slice(1);

  const y = scales.y;
  const x = scales.x;
  const curentData = drawData[index];

  context.lineWidth = 4;
  context.setLineDash([]);
  context.strokeStyle = selectedColor;
  const selectedX = x.getPixelForValue(index);
  const selectedYUp = y.getPixelForValue(curentData);

  // 「選択している」ポイント
  context.beginPath();
  context.arc(
    selectedX,
    selectedYUp,
    8.5,
    (0 * Math.PI) / 180,
    (360 * Math.PI) / 180,
    false
  );
  context.fillStyle = selectedColor;
  context.fill();
};

const drawfastDataLine = (chart, scales, name, color) => {
  const context = chart.ctx;
  const dataset = chart.canvas.parentNode.dataset;
  const data = JSON.parse(dataset.data);
  const drawData = data[name];
  if (drawData === undefined) return;
  if (drawData[0] === null) return;
  context.lineWidth = 3;
  context.setLineDash([]);
  const y = scales.y;
  const x = scales.x;

  const startX = x.getPixelForValue(0) - padding;
  const endX = x.getPixelForValue(0);
  const stratY = y.getPixelForValue(drawData[0]);
  const endY = y.getPixelForValue(drawData[1]);

  context.strokeStyle = color;
  context.beginPath();
  context.moveTo(startX, stratY);
  context.lineTo(endX, endY);
  context.stroke();
};

// 習得値より下側をグラデーションで塗る処理
// - グラデーションを塗るために各点を通る線を引いてその中をfillしている
// - 「現在」以降はロジックが異なるためここでは対象外
const fillMyselfData = (chart, scales) => {
  const context = chart.ctx;
  const dataset = chart.canvas.parentNode.dataset;
  const data = JSON.parse(dataset.data);
  let drawData = data["myself"];
  if (drawData === undefined) return;
  // 表示期間外のデータを描画するかを判定
  // - 配列の先頭は期間外のデータ
  // - 期間外のデータが存在する場合は、期間外から期間内に入る部分も塗る必要がある
  const isDrawBefore = drawData[0] !== null;
  const futureDisplay = data.futureDisplay;

  // 期間外のデータがない（nullの場合）は簡単化のため予め除外しておく。
  // 期間内のデータと処理が分かれるため、こうすることで、drawDataを期間内のグリッド処理対象のみとしている。
  drawData = isDrawBefore ? drawData : drawData.slice(1);
  context.lineWidth = 1;
  context.setLineDash([]);
  const x = scales.x;
  const y = scales.y;

  // getPixelForValue()でグラフ描画中アイテムの各座標位置が取れる
  const startX = x.getPixelForValue(0) - padding;
  const startY = y.getPixelForValue(0);

  const gradient = context.createLinearGradient(0, 0, 0, 300);
  gradient.addColorStop(0, myselfFillStartColor);
  gradient.addColorStop(1, myselfFillEndColor);

  context.fillStyle = gradient;
  context.beginPath();
  context.moveTo(startX, startY);

  if (isDrawBefore) {
    // 期間外のデータの時はグリッドでx座標を管理していない為x座標計算結果(startX)を代入
    let pointY = y.getPixelForValue(drawData[0]);
    context.lineTo(startX, pointY);
  }

  const startIndex = isDrawBefore ? 1 : 0;

  // 「現在」があるならば最後の点（未来）は別ロジックのため除外
  const drawDataKLength = futureDisplay
    ? drawData.length - 1
    : drawData.length;

  // 最後のx(endX)は描画可能な点までにしている
  // そうすることで0で描画されるのを避けている
  let endX
  const endY = y.getPixelForValue(0)

  for (let i = startIndex; i < drawDataKLength; i++) {
    let pointX = x.getPixelForValue(i - startIndex);
    let pointY = y.getPixelForValue(drawData[i]);

    // データがnilの場合は処理をスキップ
    if(!isNaN(pointY)) {
      context.lineTo(pointX, pointY);
      endX = x.getPixelForValue(i - startIndex)
    }
  }
  context.lineTo(endX, endY);
  context.lineTo(startX, startY);
  context.closePath();
  context.fill();
};

const beforeDatasetsDraw = (chart, ease) => {
  const context = chart.ctx;
  const scales = chart.scales;
  const dataset = chart.canvas.parentNode.dataset;
  const data = JSON.parse(dataset.data);

  const myselfSelected = (element) => element == data["myselfSelected"];
  const myselfSelectedIndex = data.labels.findIndex(myselfSelected);

  const otherSelected = (element) => element == data["otherSelected"];
  const otherSelectedIndex = (data["otherLabels"] || []).findIndex(otherSelected);

  // labels配列がnilの部分には縦補助線を引かない
  // nilで挟まれた日付範囲の描画領域を大きく取っている
  const verticalPoints = data.labels;

  drawvVerticalLine(context, scales, verticalPoints);
  drawHorizonLine(context, scales);
  fillMyselfData(chart, scales);
  drawMyselfNow(chart, scales);
  drawOtherNow(chart, scales);
  drawSelectedLine(
    chart,
    scales,
    "myself",
    myselfSelectedColor,
    myselfSelectedIndex
  );
  drawSelectedLine(
    chart,
    scales,
    "other",
    getOtherSelectedColor(data),
    otherSelectedIndex
  );
  drawfastDataLine(chart, scales, "role", roleBorderColor);
  drawfastDataLine(chart, scales, "other", otherBorderColor);
  drawfastDataLine(chart, scales, "myself", myselfBorderColor);
};

const afterDatasetsDraw = (chart, ease) => {
  const context = chart.ctx;
  const scales = chart.scales;
  const dataset = chart.canvas.parentNode.dataset;
  const data = JSON.parse(dataset.data);

  const myselfSelected = (element) => element == data["myselfSelected"];
  const myselfSelectedIndex = data.labels.findIndex(myselfSelected);

  const otherSelected = (element) => element == data["otherSelected"];
  const otherSelectedIndex = (data["otherLabels"] || []).findIndex(otherSelected);

  drawSelectedPoint(
    chart,
    scales,
    "myself",
    myselfSelectedColor,
    myselfSelectedIndex
  );
  drawSelectedPoint(
    chart,
    scales,
    "other",
    getOtherSelectedColor(data),
    otherSelectedIndex
  );
};

const createChartFromJSON = (data, size) => {
  let pad = size === "md" ? padding : 10;
  return {
    type: "line",
    data: createData(data),
    options: {
      animation: false,
      hover: {
        mode: null,
      },
      layout: {
        padding: {
          right: pad,
          left: pad,
        },
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
        y: {
          min: -3, //丸いポイントが削れるため-3ずらしてる
          max: 103, //丸いポイントが削れるため+3ずらしてる
          display: false,
          grid: {
            display: false,
          },
          ticks: {
            display: false,
          },
        },
        x: {
          display: false,
          grid: {
            display: false,
          },
        },
      },
    },
    plugins: [
      {
        beforeDatasetsDraw: beforeDatasetsDraw,
        afterDatasetsDraw: afterDatasetsDraw,
      },
    ],
  };
};

const getOtherBorderColor = (data) => {
  if(data["comparedOther"]) {
    return otherBorderColor
  } else {
    return myselfBorderColor
  }
}

const getOtherPointColor = (data) => {
  if(data["comparedOther"]) {
    return otherPointColor
  } else {
    return myselfPointColor
  }
}

const getOtherSelectedColor = (data) => {
  if(data["comparedOther"]) {
    return otherSelectedColor
  } else {
    return myselfSelectedColor
  }
}

export const GrowthGraphDemo = {
  drawGrowthGraph(element) {
    const dataset = element.dataset;
    const size = element.dataset.size;
    const data = JSON.parse(dataset.data);
    const ctx = document.querySelector("#" + element.id + " canvas");

    this.myChart = new Chart(ctx, createChartFromJSON(data, size));
    if (size === "md") {
      this.myChart.canvas.parentNode.style.height = "357px";
      this.myChart.canvas.parentNode.style.width = "714px";
    } else {
      this.myChart.canvas.parentNode.style.height = "178px";
      this.myChart.canvas.parentNode.style.width = "256px";
    }
  },
  mounted() {
    this.drawGrowthGraph(this.el);
  },
  updated() {
    this.myChart.destroy();
    this.drawGrowthGraph(this.el);
  },
};
