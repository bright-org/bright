// iFrameを現在のウインドウサイズに沿って拡大
const IframeSizeFitting = {
  mounted() {
    const iframeWidth = 0.7 * document.documentElement.clientWidth
    const iframeHeight = 0.7 * document.documentElement.clientHeight

    this.el.style.width = iframeWidth + "px"
    this.el.style.height = iframeHeight + "px"
  }
}

export default IframeSizeFitting
