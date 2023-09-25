// 当該要素以外のスクロールをhidden扱いに変更する
// モーダル内などで全体スクロールにキー操作が反映される現象対応のために利用

const ScrollOccupancy = {
  classList: ['overflow-y-hidden', 'overflow-x-hidden', 'overflow-hidden'],
  disableScrolls(el) {
    targets = []
    let focus = el

    // bodyを含む親要素を探索
    while (focus && focus !== document.body) {
      focus = focus.parentElement

      if (focus && (focus.scrollHeight > focus.clientHeight || focus.scrollWidth > focus.clientWidth)) {
        // 対象を無効化
        focus.classList.add(...this.classList)
        targets.push(focus)
      }
    }

    return targets
  },
  enableScrolls(els) {
    els.forEach((el) => {
      el.classList.remove(...this.classList)

    })
  },
  mounted() {
    this.targetEls = this.disableScrolls(this.el)
  },
  destroyed() {
    this.enableScrolls(this.targetEls)
  }
}

export default ScrollOccupancy
