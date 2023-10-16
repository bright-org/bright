// LocalStorageにデータを保存するHook
// LiveView接続切れによる入力内容損失への備えに使用

const LocalStorageBackup = {
  restore() {
    const data = sessionStorage.getItem(this.key)
    if(data) {
      if(this.target) {
        this.pushEventTo(this.target, 'reconnet_and_backup_existing', {local_data:  data})
      } else {
        this.pushEvent('reconnet_and_backup_existing', {local_data: data})
      }
    }
  },
  mounted() {
    // data属性より保存先キーと各イベント送信先を取得する
    this.key = this.el.dataset.backupKey
    this.target = this.el.dataset.backupPhxTarget

    // 初期化
    // データが存在するならばサーバに送信
    this.restore()

    // 保存用イベントハンドル
    this.handleEvent(`backup_${this.key}`, ({data}) => {
      sessionStorage.setItem(this.key, data)
    })

    // 削除用イベントハンドル
    // keyに該当する場合に破棄する
    this.handleEvent(`remove_backup_${this.key}`, () => {
      sessionStorage.removeItem(this.key)
    })
  },
  updated() {
    // Nothing to do
  },
  destroyed() {
    // 正常終了時に入力内容削除
    sessionStorage.removeItem(this.key)
  },
  reconnected() {
    // 再接続(接続不良による通信断、submitエラー)時のリストア
    this.restore()
  }
}

export default LocalStorageBackup
