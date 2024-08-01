const ScrollPos = {
  mounted() {
    const cf = document.getElementById("wants_job_panel").children;

    const pos = [
      cf[0].clientHeight,
      cf[1].clientHeight,
      cf[2].clientHeight,
      cf[3].clientHeight,
      cf[4].clientHeight,
    ];

    document.addEventListener("scroll", () => {
      const y = window.scrollY;
      if (y < pos[0]) {
        this.pushEvent("position", { pos: cf[0].id });
      } else if (y < pos[0] + pos[1]) {
        this.pushEvent("position", { pos: cf[1].id });
      } else if (y < pos[0] + pos[1] + pos[2]) {
        this.pushEvent("position", { pos: cf[2].id });
      } else if (y < pos[0] + pos[1] + pos[2] + pos[3]) {
        this.pushEvent("position", { pos: cf[3].id });
      } else {
        this.pushEvent("position", { pos: cf[4].id });
      }
    });
  },
};

export default ScrollPos;
