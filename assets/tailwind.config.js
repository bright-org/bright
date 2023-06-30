// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/*_web.ex",
    "../lib/*_web/**/*.*ex"
  ],
  theme: {
    extend: {
      colors: {
        brand: "#FD4F00", //TODO: Phoenix Frameworkでもともとある定義　不要になった時点で削除又はこのコメントを削除
        base: "#333333",
        transparent: "transparent",
        brightGreen: {
          50: "#DCF2F0",
          100: "#A9E0D7",
          300: "#12B7A3",
          600: "#008971",
          900: "#004D36",
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
        background: "#F9FAFA",
        error: "#E5323F",
        white: "#ffffff",
        link: "#001AAC",
        sns: {
          facebook: "#1877F2",
          twitter: "#1DA1F2",
          github: "#0D1117",
        },
        enginner: {
          dark: "#51971A",
          light: "#8CEB14",
          dazzle: "#8CEB14",
        },
        infra: {
          dark: "#165BC8",
          light: "#6BDDFE",
          dazzle: "#EEFBFF",
        },
        designer: {
          dark: "#E96500",
          light: "#E3E312",
          dazzle: "#FFFFDC",
        },
        marketer: {
          dark: "#6B50A4",
          light: "#C6A2EA",
          dazzle: "#F1E3FF",
        },
        sales: {
          dark: "#D3000E",
          light: "#FD5B87",
          dazzle: "#FFE9EF",
        },
      },
      extend: {
        backgroundImage: (theme) => ({
          bgGem: "url('./images/bg_gem_title.png')",
          bgGoogle: "url('./images/bg_google.png')",
          bgGithub: "url('./images/bg_github.png')",
          bgFacebook: "url('./images/bg_facebook.png')",
          bgTwitter: "url('./images/bg_twitter.png')",
        }),
        backgroundPosition: (theme) => ({
          "left-2.5": "10px center",
        }),
        backgroundSize: (theme) => ({
          5: "auto 20px",
          6: "auto 24px",
        }),
      }
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({ addVariant }) => addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])),
    plugin(({ addVariant }) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function ({ matchComponents, theme }) {
      let iconsDir = path.join(__dirname, "./vendor/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).map(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = { name, fullPath: path.join(iconsDir, dir, file) }
        })
      })
      matchComponents({
        "hero": ({ name, fullPath }) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": theme("spacing.5"),
            "height": theme("spacing.5")
          }
        }
      }, { values })
    })
  ]
}
