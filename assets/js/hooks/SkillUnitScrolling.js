// スキルパネル画面 SPサイズのスキルテーブル中のスキルユニットにアンカーリンクで移動するためのHook
// スキルジェムからは`#unit-x`で遷移があり、本Hookで`#unit-sp-x`位置にスクロールしている

const SkillUnitScrolling = {
  mounted() {
    this.handleEvent("scroll_to_unit", () => {
      const spEl = document.getElementById("sp-size");
      const isSP = getComputedStyle(spEl).display !== "none";
      const anchor = location.hash || "";
      if (anchor === "") {
        return;
      }

      const headerSize = document.querySelector("#user-header").offsetHeight;

      let targetEl;

      if (isSP) {
        const spAnchor = anchor + "-sp";
        targetEl = document.querySelector(spAnchor);
        if (targetEl) {
          window.scroll({ top: 0 });
          // 固定されたheaderに隠れないように調整
          const targetTop = targetEl.getBoundingClientRect().top - headerSize;

          // スクロール
          // そのままだとピッタリのため、5ほど余白を取っている
          window.scroll({
            top: targetTop - 5,
            behavior: "smooth",
          });
        }
      } else {
        targetEl = document.querySelector(anchor);
        if (targetEl) {
          const table = document.getElementById("skills-table-field");
          if (table == null) {
            window.scroll({ top: 0 });
            const targetTop = targetEl.getBoundingClientRect().top;
            window.scroll({
              top: targetTop - headerSize,
              behavior: "smooth",
            });
          } else {
            window.scroll({ top: 0 });
            const tableTop = table.getBoundingClientRect().top;
            const targetTop = targetEl.getBoundingClientRect().top - tableTop;
            window.scroll({ top: tableTop, behavior: "smooth" });
            table.scroll({
              top: targetTop - headerSize - 5,
              behavior: "smooth",
            });
          }
        }
      }
    });
  },
};

export default SkillUnitScrolling;
