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
    if (theme === "auto") {
      theme = window.matchMedia("(prefers-color-scheme: dark)").matches
        ? "dark"
        : "light";
    }

    document.documentElement.setAttribute("data-theme", theme);

    // Send message to another that the theme has been changed
    // e.g for mermaid, disqus, giscus, and utterances theme.
    window.postMessage({ themeChange: theme }, "*");
  };

  setTheme(getPreferredTheme());

  const showActiveTheme = (theme) => {
    const themeToggle = document.querySelector("#theme-toggle");
    const themeButtons = themeToggle?.querySelectorAll("button");
    if (!themeToggle && !themeButtons) return;

    themeButtons.forEach((button) => {
      button.classList.toggle(
        "active",
        button.getAttribute("data-theme-value") === theme
      );
    });
  };

  window
    .matchMedia("(prefers-color-scheme: dark)")
    .addEventListener("change", () => {
      const storedTheme = getStoredTheme();
      if (storedTheme !== "light" && storedTheme !== "dark") {
        setTheme(getPreferredTheme());
      }
    });

  window.addEventListener("DOMContentLoaded", () => {
    showActiveTheme(getPreferredTheme());

    const dataThemeValue = document.querySelectorAll("[data-theme-value]");
    if (dataThemeValue) {
      dataThemeValue.forEach((toggle) => {
        toggle.addEventListener("click", () => {
          const theme = toggle.getAttribute("data-theme-value");
          setStoredTheme(theme);
          setTheme(theme);
          showActiveTheme(theme);
        });
      });
    }
  });
})();
