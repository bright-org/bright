const Chat = {
  mounted() {
    this.handleEvent("scroll_bottom", () => {
      const obj = document.getElementById("messages");
      obj.scrollTop = obj.scrollHeight;
    });
  },
};

export default Chat;
