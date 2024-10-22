// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin");
const fs = require("fs");
const path = require("path");

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/*_web.ex",
    "../lib/*_web/**/*.*ex",
    "./node_modules/flowbite/**/*.js",
  ],
  safelist: [
    {
      pattern:
        /bg-(engineer|product|designer|marketer|sales|cxo)-(dark|light|dazzle)/,
      variants: ["hover"],
    },
  ],

  theme: {
    extend: {
      colors: {
        current: "currentColor",
        base: "#333333",
        transparent: "transparent",
        brightGreen: {
          50: "#DCF2F0",
          100: "#A9E0D7",
          300: "#12B7A3",
          600: "#008971",
          900: "#004D36",
        },
        brightPurple: {
          300: "#EC32AD",
        },
        lapislazuli: {
          50: "#ECE7F9",
          100: "#CDC3EF",
          300: "#8A73DC",
          600: "#4232C7",
          900: "#001AAC",
        },
        amethyst: {
          50: "#F4E5F6",
          100: "#E4BDE9",
          300: "#C063CD",
          600: "#9510B1",
          900: "#4D0297",
        },
        attention: {
          50: "#FEEBEF",
          100: "#FDCDD4",
          300: "#E37179",
          600: "#E5323F",
          900: "#B71225",
        },
        brightGray: {
          10: "#F9FAFA",
          50: "#EFF0F0",
          100: "#D4DBDB",
          200: "#97ACAC",
          300: "#97ACAC",
          400: "#777777",
          500: "#688888",
          700: "#4D6363",
          900: "#2E3A3A",
        },
        skillGem: {
          50: "#F6FDFD",
          100: "#82FAE9",
          300: "#40DEC6",
          600: "#52CCB5",
        },
        linePlaceholder: "#97ACAC",
        line: "#D4DBDB",
        background: "#EFF0F0",
        error: "#E5323F",
        white: "#ffffff",
        link: "#001AAC",
        sns: {
          facebook: "#1877F2",
          twitter: "#1DA1F2",
          newTwitter: "#000000",
          github: "#0D1117",
        },
        // キャリアフィールドを追加した場合は合わせて以下のページに色見本を追加してください
        // lib/bright_web/live/admin/career_field_live/index.html.heex
        product: {
          dark: "#06594A",
          light: "#ECF7EE",
          dazzle: "#F2FFE1",
        },
        engineer: {
          dark: "#165BC8",
          light: "#E6F0FF",
          dazzle: "#EEFBFF",
        },
        designer: {
          dark: "#CF3614",
          light: "#FFEFE0",
          dazzle: "#FFFFDC",
        },
        marketer: {
          dark: "#78247F",
          light: "#F1F0FF",
          dazzle: "#F1E3FF",
        },
        sales: {
          dark: "#D3000E",
          light: "#FD5B87",
          dazzle: "#FFE9EF",
        },
        cxo: {
          dark: "#F265D3",
          light: "#FFF1F7",
          dazzle: "#E0E0E5",
        },
        skillPanel: {
          brightGreen600: "#0EA895",
          brightGreen300: "#14D6BE",
          amethyst600: "#C04CD0",
          amethyst300: "#DD6DED",
        },
        planUpgrade: {
          600: "#f57f3e",
        },
        pureGray: {
          100: "#e0e0e0",
          600: "#acacac",
        },
      },
      animation: {
        "fade-in-bottom": "fade-in-bottom 0.5s ease-in-out both",
        "fade-in-left": "fade-in-left 0.3s ease-in-out both",
      },
      keyframes: {
        "fade-in-bottom": {
          "0%": {
            transform: "translateY(50px)",
            opacity: "0",
          },
          to: {
            transform: "translateY(0)",
            opacity: "1",
          },
        },
        "fade-in-left": {
          "0%": {
            transform: "translateX(-100%)",
            opacity: "0",
          },
          to: {
            transform: "translateX(0%)",
            opacity: "1",
          },
        },
      },
      backgroundImage: (theme) => ({
        bgGem: "url('/images/bg_gem_title.png')",
        bgGemEngineer: "url('/images/bg_gem_engineer.png')",
        bgGemproduct: "url('/images/bg_gem_product.png')",
        bgGemDesigner: "url('/images/bg_gem_designer.png')",
        bgGemMarketer: "url('/images/bg_gem_marketer.png')",
        bgGemSales: "url('/images/bg_gem_sales.png')",
        bgGemCxo: "url('/images/bg_gem_cxo.png')",
        bgGoogle: "url('/images/bg_google.png')",
        bgGithub: "url('/images/bg_github.png')",
        bgFacebook: "url('/images/bg_facebook.png')",
        bgTwitter: "url('/images/bg_twitter.png')",
        bgNewTwitter: "url('/images/bg_new_twitter.png')",
        bgAddAvatar: "url('/images/bg_add_avatar.png')",
      }),
      backgroundPosition: (theme) => ({
        "left-2.5": "10px center",
      }),
      backgroundSize: (theme) => ({
        5: "auto 20px",
        6: "auto 24px",
        7: "auto 28px",
        8: "auto 32px",
        9: "auto 34px",
        20: "auto 80px",
      }),
      fontFamily: (theme) => ({
        notosans: ["Noto Sans JP"],
        sans: ["Noto Sans JP"],
      }),
      fontSize: {
        normal: ["1rem", "1.5rem"],
      },
      rotate: (theme) => ({
        225: "225deg",
      }),
    },
  },
  plugins: [
    require("flowbite/plugin"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({ addVariant }) =>
      addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-click-loading", [
        ".phx-click-loading&",
        ".phx-click-loading &",
      ])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-submit-loading", [
        ".phx-submit-loading&",
        ".phx-submit-loading &",
      ])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-change-loading", [
        ".phx-change-loading&",
        ".phx-change-loading &",
      ])
    ),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function ({ matchComponents, theme }) {
      let iconsDir = path.join(__dirname, "./vendor/heroicons/optimized");
      let values = {};
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"],
      ];
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).map((file) => {
          let name = path.basename(file, ".svg") + suffix;
          values[name] = { name, fullPath: path.join(iconsDir, dir, file) };
        });
      });
      matchComponents(
        {
          hero: ({ name, fullPath }) => {
            let content = fs
              .readFileSync(fullPath)
              .toString()
              .replace(/\r?\n|\r/g, "");
            return {
              [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
              "-webkit-mask": `var(--hero-${name})`,
              mask: `var(--hero-${name})`,
              "mask-repeat": "no-repeat",
              "background-color": "currentColor",
              "vertical-align": "middle",
              display: "inline-block",
              width: theme("spacing.5"),
              height: theme("spacing.5"),
            };
          },
        },
        { values }
      );
    }),
    plugin(function ({ addBase, addComponents, addUtilities, theme }) {
      addBase({
        body: {
          fontSize: theme("fontSize.sm"),
          letterSpacing: theme("letterSpacing.tight"),
          color: "#333333",
        },
        h1: {
          fontSize: theme("fontSize.5xl"),
          fontWeight: theme("fontWeight.bold"),
          letterSpacing: theme("letterSpacing.tight"),
          alignSelf: "center",
        },
        h2: {
          fontSize: theme("fontSize.4xl"),
          fontWeight: theme("fontWeight.bold"),
          letterSpacing: theme("letterSpacing.tight"),
          alignSelf: "center",
        },
        h3: {
          fontSize: theme("fontSize.2xl"),
          fontWeight: theme("fontWeight.bold"),
          letterSpacing: theme("letterSpacing.tight"),
          alignSelf: "center",
        },
        h4: {
          fontSize: theme("fontSize.xl"),
          fontWeight: theme("fontWeight.bold"),
          letterSpacing: theme("letterSpacing.tight"),
          alignSelf: "center",
        },
        h5: {
          fontSize: theme("fontSize.lg"),
          fontWeight: theme("fontWeight.bold"),
          letterSpacing: theme("letterSpacing.tight"),
          alignSelf: "center",
        },
        td: {
          textAlign: "left",
          fontSize: theme("fontSize.sm"),
          padding: theme("padding.2"),
        },
        th: {
          textAlign: "left",
          fontSize: theme("fontSize.sm"),
          padding: theme("padding.2"),
        },
      });
      addComponents({
        ".skill-table td": {
          width: "110px",
        },
        ".skill-table th": {
          width: "140px",
        },
        ".skill-panel-table td": {
          height: theme("height:10"),
          borderRight: "1px",
          borderColor: "#97ACAC",
          borderBottom: "1px",
          borderStyle: "solid",
        },
        ".skill-panel-table th": {
          height: theme("height:10"),
          borderRight: "1px",
          borderColor: "#97ACAC",
          borderBottom: "1px",
          borderStyle: "solid",
        },
        "input.coustom-checkbox": {
          cursor: "pointer",
          paddingLeft: 30,
          verticalAlign: "middle",
          position: "relative",
          "&:before": {
            content: "''",
            display: "block",
            position: "absolute",
            backgroundColor: "#ffffff",
            borderRadius: "0%",
            border: "2px solid #2E3A3A",
            width: "20px",
            height: "20px",
            transform: "translateY(-50%)",
            top: "50%",
            left: "0px",
            borderRadius: "3px",
          },
          "&:after": {
            content: "''",
            display: "block",
            position: "absolute",
            borderBottom: "3px solid #2E3A3A",
            borderLeft: "3px solid #2E3A3A",
            opacity: "0",
            height: "6px",
            width: "12px",
            transform: "rotate(-45deg)",
            top: "4px",
            left: "4px",
          },
          "&:checked:after": {
            opacity: "1",
          },
        },
      });
      addUtilities({
        ".button-toggle-active": {
          backgroundColor: "#2E3A3A",
          color: "#ffffff",
          borderRadius: "999999px",
        },
        ".skill-panel-outline": {
          outline: "1px solid #97acac",
          outlineOffset: "1",
        },
        ".scrollbar-hide": {
          scrollbarWidth: "none",
          "-ms-overflow-style": "none",
          "&::-webkit-scrollbar": {
            width: "0px",
            background: "transparent",
            display: "none",
          },
          "& *::-webkit-scrollbar": {
            width: "0px",
            background: "transparent",
            display: "none",
          },
          "& *": {
            scrollbarWidth: "none",
            "-ms-overflow-style": "none",
          },
        },
      });
    }),
  ],
};
