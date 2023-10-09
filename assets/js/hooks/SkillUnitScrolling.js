// スキルパネル画面 SPサイズのスキルテーブル中のスキルユニットにアンカーリンクで移動するためのHook
// スキルジェムからは`#unit-x`で遷移があり、本Hookで`#unit-sp-x`位置にスクロールしている

const SkillUnitScrolling = {
  mounted() {
    const spEl = document.getElementById("sp-size")
    const isSP = getComputedStyle(spEl).display !== 'none'
    const anchor = location.hash || ''
    const spAnchor = anchor + '-sp'

    if(isSP) {
      const targetEl = document.querySelector(spAnchor)

      if(targetEl) {
        // 固定されたheaderに隠れないように調整
        const headerSize = document.querySelector('#user-header').offsetHeight
        const targetTop = targetEl.getBoundingClientRect().top - headerSize

        // スクロール
        // そのままだとピッタリのため、5ほど余白を取っている
        window.scroll({top: targetTop - 5, behavior: 'smooth'})
      }
    }
  }
}

export default SkillUnitScrolling
