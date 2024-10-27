(() => {
  "use strict";

  const themeConfig = {
    checkbox: ".theme-toggle #mode-theme", // Checkbox selector
    buttons: ".theme-toggle button", // Button selector
  };

  // Debounce utility to avoid executing function too often
  const debounce = (func, wait) => {
    let timeout;
    return (...args) => {
      clearTimeout(timeout);
      timeout = setTimeout(() => {
        func.apply(this, args);
      }, wait);
    };
  };

  const getStoredTheme = () => localStorage.getItem("theme");
  const setStoredTheme = (theme) => localStorage.setItem("theme", theme);

  // Fallback to "light" if no theme found in localStorage or system preferences
  const getPreferredTheme = () => {
    const storedTheme = getStoredTheme();
    if (storedTheme) {
      return storedTheme;
    } else {
      return window.matchMedia("(prefers-color-scheme: dark)").matches
        ? "dark"
        : "light"; // Fallback theme
    }
  };

  const isPreferredTheme = (mode) => {
    if (["auto", "system"].includes(mode)) {
      return window.matchMedia("(prefers-color-scheme: dark)").matches
        ? "dark"
        : "light";
    }
    return mode;
  };

  const setTheme = (theme) => {
    theme = isPreferredTheme(theme);
    document.documentElement.setAttribute("data-theme", theme);
    window.postMessage({ themeChange: theme }, window.location.origin);
  };

  const setActiveTheme = (theme) => {
    const themeCheckbox = document.querySelector(themeConfig.checkbox);
    const themeButtons = document.querySelectorAll(themeConfig.buttons);

    // Set the checkbox state based on the theme
    if (themeCheckbox) {
      theme = isPreferredTheme(theme);
      themeCheckbox.checked = theme === "dark";
      themeCheckbox.setAttribute(
        "aria-checked",
        theme === "dark" ? "true" : "false"
      );
    }

    // Set the active class for the buttons
    if (themeButtons) {
      themeButtons.forEach((button) => {
        const isActive = button.getAttribute("data-theme-value") === theme;
        button.setAttribute("aria-pressed", isActive ? "true" : "false");
        button.classList.toggle("active", isActive);
      });
    }
  };

  // Listen for system dark mode changes if theme is "auto"
  window.matchMedia("(prefers-color-scheme: dark)").addEventListener(
    "change",
    debounce(() => {
      if (!["light", "dark"].includes(getStoredTheme())) {
        setTheme(getPreferredTheme());
      }
    }, 200) // Debounced with 200ms delay
  );

  // Set initial theme and prevent FOUC (Flash of Unstyled Content)
  setTheme(getPreferredTheme());

  // On page load
  window.addEventListener("DOMContentLoaded", () => {
    setActiveTheme(getPreferredTheme());

    const themeCheckbox = document.querySelector(themeConfig.checkbox);
    const themeButtons = document.querySelectorAll(themeConfig.buttons);

    if (themeCheckbox) {
      themeCheckbox.addEventListener("change", (event) => {
        const theme = event.target.checked ? "dark" : "light";
        setStoredTheme(theme);
        setTheme(theme);
        setActiveTheme(theme);
      });
    }

    if (themeButtons) {
      themeButtons.forEach((button) => {
        button.addEventListener("click", () => {
          const theme = button.getAttribute("data-theme-value");
          setStoredTheme(theme);
          setTheme(theme);
          setActiveTheme(theme);
        });
      });
    }
  });
})();
