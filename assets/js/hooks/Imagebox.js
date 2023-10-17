// イメージを画面全体に表示するオーバーレイ制御用Hook
//
// Example
//
//  <div
//    id="imageboxContainer"
//    class="hidden fixed top-0 left-0 z-50 w-screen h-screen bg-black/70 flex justify-center items-center"
//    phx-hook="Imagebox"
//    data-imagebox-container="my-field"
//    data-imagebox-img-target-class="my-img-class">
//    <img class="object-cover" />
//    <a class="btn-close-imagebox absolute z-50 top-6 right-8 text-white text-5xl font-bold">&times;</a>
//  </div>
//
const Imagebox = {
  mounted() {
    const containerEl = document.getElementById(this.el.dataset.imageboxContainer)
    const imageTarget = this.el.dataset.imageboxImgTargetClass
    const btnCloseEl = this.el.querySelector('.btn-close-imagebox')
    const imageEl = this.el.querySelector('img')

    containerEl.addEventListener('click', (e) => {
      // 動的なimg追加への対応として対象かどうかをイベント内で判定
      if(e.target.classList.contains(imageTarget)) {
        imageEl.src = e.target.src
        this.el.classList.remove('hidden')
      }
    })

    // 画像を再クリックで閉じる
    imageEl.addEventListener('click', (e) => {
      imageEl.src = ''
      this.el.classList.add('hidden')
    })

    // 閉じるボタン
    if(btnCloseEl) {
      btnCloseEl.addEventListener('click', (e) => {
        imageEl.src = ''
        this.el.classList.add('hidden')
      })
    }
  }
}

export default Imagebox
