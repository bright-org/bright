// スクロールイベントの伝搬を止めるフック

const ScrollOccupancy = {
  mounted() {
    console.log('INNN')
    this.el.addEventListener("scroll", (e) => {
      console.log('IN')
      e.stopPropagation()
      console.log('IN2')
      return false
    });
    this.el.addEventListener('keydown', e => {

    document.addEventListener('keydown', e => {
      console.log(e.keyCode)
      if (e.keyCode == 40) {
        e.preventDefault()
        e.stopPropagation()
      }
      if (e.keyCode == 38) {
        e.preventDefault()
        e.stopPropagation()
      }
    })
  }
}

export default ScrollOccupancy
