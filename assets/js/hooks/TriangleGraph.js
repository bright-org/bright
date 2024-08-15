const beginnerColor = "#1DA091";
const normalColor = "#3CC0A8";
const skilledColor = "#72EAD9";
const textColor = "#000000";
const maxPercent = 100;

const drawTriangle = (ctx, percent, color) => {
  let xDiff = 100 - percent;
  ctx.beginPath();
  ctx.moveTo(percent + xDiff, 0);
  ctx.lineTo(0 + xDiff, percent);
  ctx.lineTo(percent * 2 + xDiff, percent);
  ctx.closePath();
  ctx.fillStyle = color;
  ctx.fill();
}

const getPercent = (number, total) => {
  return Math.floor(number / total * maxPercent)
}

const drawLevel = (ctx, levelText, number, percent, x, y) => {
  ctx.fillStyle = textColor;
  ctx.fillText(levelText + " " + number + "人 " + percent + "%", x, y);
}

const drawTriangleGraph = (element) => {
  const dataset = element.dataset;
  const data = JSON.parse(dataset.data);
  const canvas = document.querySelector("#" + element.id + " canvas")
  const ctx = canvas.getContext('2d');

  let total = data.beginner + data.normal + data.skilled;
  let beginnerPercent = getPercent(data.beginner, total);
  let normalPercent = getPercent(data.normal, total);
  let skilledPercent = maxPercent - beginnerPercent - normalPercent

  drawTriangle(ctx, maxPercent, beginnerColor);
  drawTriangle(ctx, maxPercent - beginnerPercent, normalColor);
  drawTriangle(ctx, skilledPercent, skilledColor);

  drawLevel(ctx, "ベテラン", data.beginner, beginnerPercent, 210, 10);
  drawLevel(ctx, "平均", data.normal, normalPercent, 210, 40);
  drawLevel(ctx, "見習い", + data.skilled, skilledPercent, 210, 90)
}

export const TriangleGraph = {
  mounted() {
    drawTriangleGraph(this.el);
  },
  updated() {
    drawTriangleGraph(this.el);
  }
};
