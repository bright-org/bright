import { Chart } from 'chart.js/auto'
const dash = [3, 2]
const dashColor = '#A5B8B8'
const myselfBorderColor = '#52CCB5'
const myselfPointColor = '#B6F1E7'
const myselfFillColor = '#40DEC622'
const otherBorderColor = '#C063CD'
const otherPointColor = '#E4BDE9'
const roleBorderColor = '#A9BABA'
const rolePointColor = '#D5DCDC'
const futurePointColor = '#FFFFFF'
const currentColor = '#B71225'

const dataDivision = (data) => {
  const past = data.map((x, index) => index > 3 ? null : x)
  const future = data.map((x, index) => index < 3 ? null : x)
  return ([past, future])
}

const createData = (labels, data) => {
  const [myselfData, myselfFuture] = dataDivision(data['myself'])
  const [otherData, otherFuture] = dataDivision(data['other'])
  const [roleData, roleFuture] = dataDivision(data['role'])


  return {
    labels: labels,
    datasets: [
      {
        label: 'other',
        data: otherData,
        borderColor: otherBorderColor,
        pointRadius: 8,
        pointBackgroundColor: otherPointColor,
        pointBorderColor: otherPointColor,
        fill: false,
        tension: 0.1
      },
      {
        label: 'otherFuture',
        data: otherFuture,
        borderColor: dashColor,
        borderDash: dash,
        pointRadius: 8,
        pointBackgroundColor: futurePointColor,
        pointBorderColor: otherPointColor,
        fill: false,
        borderWidth: 2
      },
      {
        label: 'role',
        data: roleData,
        borderColor: roleBorderColor,
        pointRadius: 8,
        pointBackgroundColor: rolePointColor,
        pointBorderColor: rolePointColor,
        fill: false,
        tension: 0.1
      },
      {
        label: 'roleFuture',
        data: roleFuture,
        borderColor: dashColor,
        borderDash: dash,
        pointRadius: 8,
        pointBackgroundColor: futurePointColor,
        pointBorderColor: rolePointColor,
        fill: false,
        borderWidth: 2
      },
      {
        label: 'myself',
        data: myselfData,
        borderColor: myselfBorderColor,
        pointRadius: 8,
        pointBackgroundColor: myselfPointColor,
        pointBorderColor: myselfPointColor,
        fill: true,
        backgroundColor: myselfFillColor,
      },
      {
        label: 'myselfFuture',
        data: myselfFuture,
        borderColor: dashColor,
        borderDash: dash,
        pointRadius: 8,
        pointBackgroundColor: futurePointColor,
        pointBorderColor: myselfPointColor,
        fill: true,
        backgroundColor: myselfFillColor,
        borderWidth: 2
      }]
  }
}

const drawHorizonLine = (context, scales) => {
  // 見習い、平均、ベテランの線
  x1 = scales.x.getPixelForValue(0)
  x4 = scales.x.getPixelForValue(4)
  y = scales.y.getPixelForValue(40)
  context.beginPath()
  context.lineWidth = 1
  context.setLineDash(dash)
  context.strokeStyle = dashColor

  // ベテランの線
  context.moveTo(x1, y)
  context.lineTo(x4, y)
  y = scales.y.getPixelForValue(60)
  // 平均の線
  context.moveTo(x1, y)
  context.lineTo(x4, y)
  context.stroke()

  x3 = scales.x.getPixelForValue(3)

  diff_x = x4 - x3
  now_x = x3 + (diff_x / 2)
}

const drawCurrent = (context, scales) => {
  //　現在の縦線
  context.beginPath()
  context.lineWidth = 2
  context.setLineDash([2, 0])
  context.strokeStyle = currentColor
  y = scales.y.getPixelForValue(0)
  y2 = scales.y.getPixelForValue(60)
  y3 = scales.y.getPixelForValue(55)
  y4 = scales.y.getPixelForValue(100)
  context.moveTo(now_x, y)
  context.lineTo(now_x, y2)

  // 直近の過去から現在までの線
  context.moveTo(x3, y3)
  context.lineTo(now_x, y2)
  context.stroke()

  // 現在の点
  context.arc(now_x, y2, 8, 0 * Math.PI / 180, 360 * Math.PI / 180, false)
  context.fillStyle = currentColor
  context.fill()
}

const beforeDatasetsDraw = (chart, ease) => {
  const context = chart.ctx
  const scales = chart.scales
  drawHorizonLine(context, scales)
  drawCurrent(context, scales)

}

const createChartFromJSON = (labels, data) => {
  return ({
    type: 'line',
    data: createData(labels, data),
    options: {
      animation: false,
      hover: {
        mode: null
      },
      plugins: {
        legend: {
          display: false
        },
        tooltip: {
          enabled: false
        }
      },
      scales: {
        y: {
          min: 0,
          max: 100,
          grid: {
            display: false
          },
          ticks: {
            display: false
          }
        },
        x: {
          grid: {
            color: dashColor,
            lineWidth: 1,
          },
          border: {
            dash: dash
          }
        }
      }
    },
    plugins: [{ beforeDatasetsDraw: beforeDatasetsDraw }]
  })
}

export const GrowthGraph = {
  mounted() {
    const element = this.el
    const dataset = element.dataset
    const labels = JSON.parse(dataset.labels)
    const data = JSON.parse(dataset.data)

    const ctx = document.querySelector('#' + element.id + ' canvas')
    const myChart = new Chart(ctx, createChartFromJSON(labels, data))
    myChart.canvas.parentNode.style.height = '600px'
    myChart.canvas.parentNode.style.width = '800px'

  }
}
