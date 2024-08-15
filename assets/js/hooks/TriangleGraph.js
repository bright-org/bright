const beginnerColor = "#1DA091";
const normalColor = "#3CC0A8";
const skilledColor = "#72EAD9";
const textColor = "#000000";
const maxPercent = 100;

export const TriangleGraph = {
  drawTriangleGraph(element) {
    const dataset = element.dataset;
    const data = JSON.parse(dataset.data);
    const canvas = document.querySelector("#" +  element.id + " canvas")
    const ctx = canvas.getContext('2d');
    drawTriangleGraph(ctx, data)


    function drawTriangleGraph (ctx, data) {
      let total = data.beginner + data.normal + data.skilled
      let beginnerPercent = data.beginner / total * maxPercent
      let normalPercent = data.normal / total * maxPercent
      let skilledPercent = data.skilled / total * maxPercent

      drawTriangle(ctx, maxPercent, beginnerColor);
      drawTriangle(ctx, maxPercent - beginnerPercent,  normalColor);
      drawTriangle(ctx, skilledPercent,  skilledColor);

      ctx.fillStyle = textColor;
      ctx.fillText("ベテラン " + data.beginner + "人 " +  Math.floor(skilledPercent) + "%",210, 10);
      ctx.fillText("平均 " + data.normal + "人 " +  Math.floor(normalPercent) + "%" ,210, 40);
      ctx.fillText("見習い " + data.skilled + "人 " + Math.floor(beginnerPercent)+ "%",210, 90);
    }

    function drawTriangle(ctx, l, c) {
      let f = 100 - l;
      ctx.beginPath();
      ctx.moveTo(l + f , 0);
      ctx.lineTo(0 + f, l);
      ctx.lineTo(l * 2 + f, l);
      ctx.closePath();
      ctx.fillStyle = c;
      ctx.fill();
    }
  },
  mounted() {
    this.drawTriangleGraph(this.el);
  },
  updated() {
    this.drawTriangleGraph(this.el);
  },
};
