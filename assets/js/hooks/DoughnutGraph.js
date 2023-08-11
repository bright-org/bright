import { Chart } from 'chart.js/auto'
const circleMarkCokir = '#0EA895'
const triangleMarkCokir = '#14D6BE'
const noneMarkCokir = '#EFF0F0'

const createDoughnutData = (data) => {
  return {
    datasets: [
      {
        data: data,
        backgroundColor: [
          circleMarkCokir,
          triangleMarkCokir,
          noneMarkCokir
        ],
        borderWidth: 0
      },
    ]
  }
};

const createChartFromJSON = (data) => {
  return (
    {
      type: "doughnut",
      data: createDoughnutData(data),
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
        }
      }
    }
  )
}

export const drawDoughnutGraph = {
  drawDoughnutGraph(element) {
    const dataset = element.dataset
    const data = JSON.parse(dataset.data)
    const ctx = document.querySelector('#' + element.id + ' canvas')
    this.myDoughnut = new Chart(ctx, createChartFromJSON(data))
    this.myDoughnut.canvas.parentNode.style.height = '80px'
    this.myDoughnut.canvas.parentNode.style.width = '80px'
  },
  mounted() {
    drawDoughnutGraph(this.el)
  },
  updated() {
    this.myDoughnut.destroy()
    drawDoughnutGraph(this.el)
  }
}
