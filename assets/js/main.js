(function () {
  // Shortcut keys
  if (window.location.pathname !== "/search/") {
    document.addEventListener("keydown", function (event) {
      if (event.ctrlKey && event.shiftKey && event.key === "F") {
        window.location.href = "/search/";
      }
    });
  }

  // Theme switcher
  // Thanks to Aleksandr Hovhannisyan <https://www.aleksandrhovhannisyan.com/blog/the-perfect-theme-switch/>
  const Theme = { AUTO: "auto", LIGHT: "light", DARK: "dark" };
  const THEME_STORAGE_KEY = "theme";
  const THEME_OWNER = document.documentElement;

  const cachedTheme = localStorage.getItem(THEME_STORAGE_KEY);
  if (cachedTheme) {
    THEME_OWNER.dataset[THEME_STORAGE_KEY] = cachedTheme;
  }

  document.addEventListener("DOMContentLoaded", () => {
    const themeSwitcher = document.getElementById("theme-switcher");
    if (!themeSwitcher) return;

    themeSwitcher.addEventListener("change", (e) => {
      const theme = e.target.value;
      if (theme === Theme.AUTO) {
        delete THEME_OWNER.dataset[THEME_STORAGE_KEY];
        localStorage.removeItem(THEME_STORAGE_KEY);
      } else {
        THEME_OWNER.dataset[THEME_STORAGE_KEY] = theme;
        localStorage.setItem(THEME_STORAGE_KEY, theme);
      }
    });

    const initialTheme = cachedTheme ?? Theme.AUTO;
    themeSwitcher.querySelector("input[checked]").removeAttribute("checked");
    themeSwitcher
      .querySelector(`input[value="${initialTheme}"]`)
      .setAttribute("checked", "");
  });
})();
