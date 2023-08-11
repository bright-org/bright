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

const resizeDoughnutGraph = (myDoughnut) => {
  myDoughnut.canvas.parentNode.style.height = '80px'
  myDoughnut.canvas.parentNode.style.width = '80px'
}

const initDoughnutGraph = (element) => {
  const dataset = element.dataset
  const data = JSON.parse(dataset.data)

  const ctx = document.querySelector('#' + element.id + ' canvas')
  createChartFromJSON(data)
  return ({ ctx: ctx, json: createChartFromJSON(data) })
}

export const DoughnutGraph = {
  mounted() {
    const init = initDoughnutGraph(this.el)
    this.myDoughnut = new Chart(init.ctx, init.json)
    resizeDoughnutGraph(this.myDoughnut)
  },
  updated() {
    if (this.myDoughnut != null) this.myDoughnut.destroy()
    const init = initDoughnutGraph(this.el)
    this.myDoughnut = new Chart(init.ctx, init.json)
    resizeDoughnutGraph(this.myDoughnut)
  }
}
