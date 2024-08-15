
export const TriangleGraph = {
  drawTriangleGraph(element) {
    const dataset = element.dataset;
    const data = JSON.parse(dataset.data);
    console.log(data.data);
    const canvas = document.querySelector("#" +  element.id + " canvas")
    const ctx = canvas.getContext('2d');
    drawTriangleGraph(ctx, data.data)

    function drawTriangleGraph (ctx, x) {

      let total_x = x.reduce((a, v) => {
        return a + v;
      }, 0);

      let beginner = x[0] / total_x * 100
      let normal = x[1] / total_x * 100
      let skilled = x[2] / total_x * 100

      drawTriangle(ctx, 100, "#1DA091");
      drawTriangle(ctx, 100 - beginner,  "#3CC0A8");
      drawTriangle(ctx, skilled,  "#72EAD9");

      ctx.fillStyle ="#000000"
      ctx.fillText("ベテラン " + x[2] + "人 " +  Math.floor(skilled) + "%",210, 10);
      ctx.fillText("平均 " + x[1] + "人 " +  Math.floor(normal) + "%" ,210, 40);
      ctx.fillText("見習い " + x[0] + "人 " + Math.floor(beginner )+ "%",210, 90);
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
