defmodule Bright.SkillEvidences.MarkdownTest do
  use Bright.DataCase

  alias Bright.SkillEvidences

  describe "Format" do
    test "paragraph cases" do
      # 一行
      text =
        String.trim("""
        これはテストです
        """)

      html = SkillEvidences.make_content_as_html(text)

      assert html == "<p>これはテストです</p>"

      # 複数行 改行
      text =
        String.trim("""
        これはテストです
        これはテストです
        """)

      html = SkillEvidences.make_content_as_html(text)

      assert html == "<p>これはテストです<br>これはテストです</p>"

      # 複数行 一行空き
      text =
        String.trim("""
        これはテストです

        これはテストです
        """)

      html = SkillEvidences.make_content_as_html(text)

      assert html == "<p>これはテストです</p><p>これはテストです</p>"
    end

    test "code cases" do
      # インライン1
      text =
        String.trim("""
        `this is code`コードです
        """)

      html = SkillEvidences.make_content_as_html(text)

      assert html == "<p><code class=\"inline\">this is code</code>コードです</p>"

      # インライン2
      text =
        String.trim("""
        コードです`this is code`
        """)

      html = SkillEvidences.make_content_as_html(text)

      assert html == "<p>コードです<code class=\"inline\">this is code</code></p>"

      # インライン3
      text =
        String.trim("""
        コードです：
        `this is code`
        """)

      html = SkillEvidences.make_content_as_html(text)

      assert html == "<p>コードです：<br><code class=\"inline\">this is code</code></p>"

      # ブロック1
      text =
        String.trim("""
        ```
        this is
        code
        ```
        コードです
        """)

      html = SkillEvidences.make_content_as_html(text)

      assert html == "<pre><code>this is\ncode</code></pre><p>コードです</p>"

      # ブロック2
      text =
        String.trim("""
        コードです
        ```
        this is
        code
        ```
        """)

      html = SkillEvidences.make_content_as_html(text)

      assert html == "<p>コードです</p><pre><code>this is\ncode</code></pre>"
    end

    test "link cases" do
      # リンク書式
      text =
        String.trim("""
        これは[Google](https://google.com)です
        """)

      html = SkillEvidences.make_content_as_html(text)

      assert html == "<p>これは<a href=\"https://google.com\" target=\"_blank\">Google</a>です</p>"

      # リンク
      text =
        String.trim("""
        これはhttps://google.comです
        """)

      html = SkillEvidences.make_content_as_html(text)

      assert html ==
               "<p>これは<a href=\"https://google.com%E3%81%A7%E3%81%99\" target=\"_blank\">https://google.comです</a></p>"
    end

    test "blockquote cases" do
      # 引用1
      text =
        String.trim("""
        > ここは引用文です
        """)

      html = SkillEvidences.make_content_as_html(text)

      assert html == "<blockquote><p>ここは引用文です</p></blockquote>"

      # 引用2
      text =
        String.trim("""
        引用です
        > ここは引用文です
        """)

      html = SkillEvidences.make_content_as_html(text)

      assert html == "<p>引用です</p><blockquote><p>ここは引用文です</p></blockquote>"
    end

    test "list cases" do
      # リスト1
      text =
        String.trim("""
        - リストアイテム
        """)

      html = SkillEvidences.make_content_as_html(text)

      assert html == "<ul><li>リストアイテム</li></ul>"

      # リスト2
      text =
        String.trim("""
        リストです
        - リストアイテム1
        - リストアイテム2
        """)

      html = SkillEvidences.make_content_as_html(text)

      assert html == "<p>リストです</p><ul><li>リストアイテム1</li><li>リストアイテム2</li></ul>"

      # リスト3
      text =
        String.trim("""
        リストです
        * リストアイテム1
        * リストアイテム2
        """)

      html = SkillEvidences.make_content_as_html(text)

      assert html == "<p>リストです</p><ul><li>リストアイテム1</li><li>リストアイテム2</li></ul>"
    end
  end

  describe "Forbidden format" do
    test "javascript" do
      # tags
      text =
        String.trim("""
        <javascript>alert(1);</javascript>
        """)

      html = SkillEvidences.make_content_as_html(text)

      assert html == "alert(1);"

      text =
        String.trim("""
        <p><javascript>alert(1);</javascript></p>
        """)

      html = SkillEvidences.make_content_as_html(text)

      assert html == "<p>&amp;lt;javascript&amp;gt;alert(1);&amp;lt;/javascript&amp;gt;</p>"

      text =
        String.trim("""
        <script src="https://example.com/alert.js" />
        """)

      html = SkillEvidences.make_content_as_html(text)

      assert html == "<script></script>"

      # in attrs
      text =
        String.trim("""
        <a onClick="alert(1);">aiu</a>
        """)

      html = SkillEvidences.make_content_as_html(text)

      assert html == "<a target=\"_blank\">aiu</a>"
    end

    test "head" do
      text =
        String.trim("""
        # 見出し1
        """)

      html = SkillEvidences.make_content_as_html(text)

      assert html == "見出し1"
    end

    test "image" do
      # tag
      text =
        String.trim("""
        <img src="https://example.com/dummy.jpg" />
        """)

      html = SkillEvidences.make_content_as_html(text)

      assert html == "<img>"

      # img書式
      text =
        String.trim("""
        ![myimg](https://example.com/dummy.jpg)
        """)

      html = SkillEvidences.make_content_as_html(text)

      assert html == "<p><img></p>"
    end
  end
end
