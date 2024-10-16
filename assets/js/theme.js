(() => {
  "use strict";

  const getStoredTheme = () => localStorage.getItem("theme");
  const setStoredTheme = (theme) => localStorage.setItem("theme", theme);

  const getPreferredTheme = () => {
    return (
      getStoredTheme() ||
      (window.matchMedia("(prefers-color-scheme: dark)").matches
        ? "dark"
        : "light")
    );
  };

  const setTheme = (theme) => {
    if (theme === "auto" || theme === "system") {
      theme = window.matchMedia("(prefers-color-scheme: dark)").matches
        ? "dark"
        : "light";
    }

    document.documentElement.setAttribute("data-theme", theme);

    /**
     * Send message to another that the theme has been changed
     * e.g for mermaid, disqus, giscus, and utterances theme.
     *
     * Example usage:
     *
     *   window.addEventListener('message', (event) => {
     *     const theme = event.data.themeChange;
     *     const frame = document.querySelector('.giscus-frame');
     *     if (theme && frame.contentWindow) {
     *       frame.contentWindow.postMessage(
     *         { giscus: { setConfig: { theme: theme } } },
     *         'https://giscus.app'
     *       );
     *     }
     *   });
     */
    window.postMessage({ themeChange: theme }, "*");
  };

  setTheme(getPreferredTheme());

  window
    .matchMedia("(prefers-color-scheme: dark)")
    .addEventListener("change", () => {
      const storedTheme = getStoredTheme();
      if (storedTheme !== "light" && storedTheme !== "dark") {
        setTheme(getPreferredTheme());
      }
    });

  const themeConfig = {
    checkbox: "#theme-checkboxs",
    radio: "#theme-radios",
    button: "#theme-buttons",
  };

  const setActiveTheme = (theme, type) => {
    const themeToggle = document.querySelector(themeConfig[type]);

    if (!themeToggle) return;

    if (type === "button") {
      themeToggle.querySelectorAll("button").forEach((button) => {
        button.classList.toggle(
          "active",
          button.getAttribute("data-theme-value") === theme
        );
      });
    }

    if (type === "checkbox") {
      if (theme === "dark") {
        themeToggle
          .querySelector('[type="checkbox"]')
          .setAttribute("checked", "");
      } else {
        themeToggle
          .querySelector('[type="checkbox"]')
          .removeAttribute("checked");
      }
    }

    if (type === "radio") {
      themeToggle.querySelectorAll("input[type=radio]").forEach((radio) => {
        radio.removeAttribute("checked");
      });
      themeToggle
        .querySelector(`input[value=${theme}]`)
        .setAttribute("checked", "");
    }
  };

  window.addEventListener("DOMContentLoaded", () => {
    const buttons = document.querySelector(themeConfig.button);
    if (buttons) {
      setActiveTheme(getPreferredTheme(), "button");

      buttons.querySelectorAll("[data-theme-value]").forEach((button) => {
        button.addEventListener("click", () => {
          const theme = button.getAttribute("data-theme-value");
          setTheme(theme);
          setStoredTheme(theme);
          setActiveTheme(theme, "button");
        });
      });
    }

    const checkboxs = document.querySelector(themeConfig.checkbox);
    if (checkboxs) {
      setActiveTheme(getPreferredTheme(), "checkbox");

      checkboxs.addEventListener("change", (e) => {
        const theme = e.target.checked ? "dark" : "light";
        setTheme(theme);
        setStoredTheme(theme);
        setActiveTheme(theme, "checkbox");
      });
    }

    const radios = document.querySelector(themeConfig.radio);
    if (radios) {
      setActiveTheme(getPreferredTheme(), "radio");

      radios.querySelectorAll("input[type=radio]").forEach((radio) => {
        radio.addEventListener("click", () => {
          const theme = radio.getAttribute("value");
          setTheme(theme);
          setStoredTheme(theme);
          setActiveTheme(theme, "radio");
        });
      });
    }
  });
})();
