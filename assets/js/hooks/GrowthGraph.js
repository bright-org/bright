import { Chart } from 'chart.js/auto'

const createData = () => {
  return{
    labels: ["2020.12", "2021.3", "2021.6", "2021.9","2011.12"],
    datasets: [
      {
        label: 'test1',
        data: [10, 10, 10, 45, null],
        borderColor: '#C063CD',
        pointRadius: 8,
        pointBackgroundColor: '#C063CD',
        pointBorderColor: '#C063CD',
        fill: false,
        tension: 0.1
     },
     {
        label: 'test1',
        data: [null, null, null, 45, 70],
        borderColor: '#2E3A3A',
        borderDash: [5, 5],
        pointRadius: 8,
        pointBackgroundColor: '#C063CD',
        pointBorderColor: '#C063CD',
        fill: false,
        tension: 0.1
     },
     {
        label: 'test',
        data: [0, 35, 45, 55, null],
        borderColor: '#40DEC6',
        pointRadius: 8,
        pointBackgroundColor: '#40DEC6',
        pointBorderColor: '#40DEC6',
        fill: true,
        backgroundColor: '#40DEC6AA',
        tension: 0.1
     },
     {
        label: 'test',
        data: [null, null, null, 55, 60],
        borderColor: '#2E3A3A',
        borderDash: [5, 5],
        pointRadius: 8,
        pointBackgroundColor: '#40DEC6',
        pointBorderColor: '#40DEC6',
        fill: false,
        tension: 0.1
    }
    ]
  }
}

const beforeDatasetsDraw = (chart, ease) => {
  var context = chart.ctx
  x1 = chart.scales.x.getPixelForValue(0)
  x4 = chart.scales.x.getPixelForValue(4)
  y = chart.scales.y.getPixelForValue(40)
  context.beginPath()
  context.lineWidth = 2
  context.setLineDash([5, 5])
  context.strokeStyle = '#C063CD'
  context.moveTo(x1, y)
  context.lineTo(x4, y)
  y = chart.scales.y.getPixelForValue(60)
  context.moveTo(x1, y)
  context.lineTo(x4, y)
  context.stroke()

  x3 = chart.scales.x.getPixelForValue(3)

  diff_x = x4 - x3
  now_x = x3 + (diff_x / 2)

  context.beginPath()
  context.lineWidth = 2
  context.setLineDash([2, 0])
  context.strokeStyle = '#FF0000'
  y = chart.scales.y.getPixelForValue(0)
  y2 = chart.scales.y.getPixelForValue(60)
  y3 = chart.scales.y.getPixelForValue(55)
  y4 = chart.scales.y.getPixelForValue(100)
  context.moveTo(now_x, y)
  context.lineTo(now_x, y4)
  context.moveTo(x3, y3)
  context.lineTo(now_x, y2)
  context.stroke()
  context.arc(now_x, y2, 8, 0 * Math.PI / 180, 360 * Math.PI / 180, false )
  context.fillStyle = "rgba(255,0,0,0.8)"
  context.fill()
}

const createChartFromJSON = (labels, datasets) => {
  const color = "#0000FF"
  return ({
    type: 'line',
    data:createData(),
    options: {
      animation: false,
      plugins: {
        legend: {
          display: false
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
    const datasets = []
    datasets.push(createData(data[0]))

    if (data[1] !== undefined) {
      datasets.push(createData(data[1]))
    }

    const ctx = document.querySelector('#' + element.id + ' canvas')
    const myChart = new Chart(ctx, createChartFromJSON(labels, datasets))
    myChart.canvas.parentNode.style.height =  '426px'
    myChart.canvas.parentNode.style.width =   '426px'

  }
}
