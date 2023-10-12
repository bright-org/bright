export const SnsFloatingShareButtons = {
  mounted() {
    window.addEventListener('resize', this.adjustShareButtonPosition.bind(this))
    this.updated()
  },
  updated() {
    this.adjustShareButtonPosition()
    this.el.classList.remove('hidden')
  },
  destroyed() {
    window.removeEventListener('resize', this.adjustShareButtonPosition.bind(this))
  },
  adjustShareButtonPosition() {
    const windowWidth = window.innerWidth
    const baseWidth = 1920

    if (windowWidth >= 1024 && windowWidth <= baseWidth) {
      const right_position = 32
      this.el.style.right = `${right_position}px`
    } else if (windowWidth >= 1024 && baseWidth < windowWidth) {
      const right_position = windowWidth - baseWidth + 31
      this.el.style.right = `${right_position}px`
    } else {
      this.el.style.right = '10px'
    }
  }
}
