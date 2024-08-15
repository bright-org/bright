defmodule BrightWeb.BrightGraphComponents do
  @moduledoc """
  Graph
  """
  use Phoenix.Component

  @doc """
  Renders a TriangleGraph

  ## Examples

      <.TriangleGraph id="trianglegraph" />

  """
  attr :id, :string, required: true

  def triangle_graph(assigns) do
    ~H"""
    <div>
      <canvas id="myCanvas1" width="300" height="200"></canvas>
      <canvas id="myCanvas2" width="300" height="200"></canvas>
      <canvas id="myCanvas3" width="300" height="200"></canvas>

      <script>
        function main() {
          const canvas = document.getElementById('myCanvas1');
          const ctx = canvas.getContext('2d');
          drawTriangleGraph(ctx,[10, 30, 60])

          const canvas2 = document.getElementById('myCanvas2');
          const ctx2 = canvas2.getContext('2d');
          drawTriangleGraph(ctx2,[60, 30, 10] )

          const canvas3 = document.getElementById('myCanvas3');
          const ctx3 = canvas3.getContext('2d');
          drawTriangleGraph(ctx3,[30, 30, 30] )

        }

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
        main()
      </script>
    </div>
    """
  end
end
