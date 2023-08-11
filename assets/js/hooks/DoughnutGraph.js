import { Chart } from 'chart.js/auto'
const circleMarkCokir = '#0EA895'
const triangleMarkCokir = '#14D6BE'
const noneMarkCokir = '#EFF0F0'
const myDoughnut = null
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

export const DoughnutGraph = {
  mounted() {
    console.log("mounted")
    const element = this.el
    const dataset = element.dataset
    const data = JSON.parse(dataset.data)

    const ctx = document.querySelector('#' + element.id + ' canvas')
    myDoughnut = new Chart(ctx, createChartFromJSON(data))
    myDoughnut.canvas.parentNode.style.height = '80px'
    myDoughnut.canvas.parentNode.style.width = '80px'
    console.log(window)
  },
  updated() {
    if(myDoughnut != null) myDoughnut.destroy()
    const element = this.el
    const dataset = element.dataset
    const data = JSON.parse(dataset.data)

    const ctx = document.querySelector('#' + element.id + ' canvas')
    myDoughnut = new Chart(ctx, createChartFromJSON(data))
    myDoughnut.canvas.parentNode.style.height = '80px'
    myDoughnut.canvas.parentNode.style.width = '80px'

  }
}
