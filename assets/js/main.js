(function () {
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

  // Go to Top
  document.addEventListener("DOMContentLoaded", function () {
    window.onscroll = function () {
      scrollFunction();
    };

    function scrollFunction() {
      if (
        document.body.scrollTop > 20 ||
        document.documentElement.scrollTop > 20
      ) {
        document.getElementById("scroll-top__link").classList.add("visible");
      } else {
        document.getElementById("scroll-top__link").classList.remove("visible");
      }
    }

    document
      .getElementById("scroll-top__link")
      .addEventListener("click", function () {
        document.body.scrollTop = 0; /* For Safari */
        document.documentElement.scrollTop = 0; /* For other browsers */
      });
  });

  // Navigation menu
  document.addEventListener("DOMContentLoaded", function () {
    const hamburger = document.querySelector(".hamburger");
    const navMenu = document.querySelector(".nav-menu");
    const navLink = document.querySelectorAll(".nav-link");

    hamburger.addEventListener("click", mobileMenu);
    navLink.forEach((n) => n.addEventListener("click", closeMenu));

    function mobileMenu() {
      hamburger.classList.toggle("active");
      navMenu.classList.toggle("active");
    }

    function closeMenu() {
      hamburger.classList.remove("active");
      navMenu.classList.remove("active");
    }
  });

  // Copy to clipboard
  document.addEventListener("DOMContentLoaded", function () {
    const copyButtons = document.querySelectorAll(".copy-button");

    copyButtons.forEach(function (copyButton) {
      copyButton.addEventListener("click", function () {
        const codeBlock = copyButton
          .closest("[class^=language-]") // or .highlighter-rouge
          .querySelector(".rouge-code");
        const text = codeBlock.innerText;

        navigator.clipboard
          .writeText(text)
          .then(function () {
            showTooltip(
              copyButton.querySelector(".tooltip"),
              copyButton.getAttribute("success-label")
            );
            toggleIcons(copyButton, true);
          })
          .catch(function (err) {
            console.error("Failed to copy text: ", err);
            showTooltip(
              copyButton.querySelector(".tooltip"),
              copyButton.getAttribute("error-label")
            );
          });
      });

      // Menampilkan pesan dari atribut saat mouse masuk ke tombol
      copyButton.addEventListener("mouseenter", function () {
        const tooltipText = copyButton.getAttribute("copy-label");
        showTooltip(copyButton.querySelector(".tooltip"), tooltipText);
      });

      // Menghapus pesan saat mouse meninggalkan tombol
      copyButton.addEventListener("mouseleave", function () {
        copyButton.querySelector(".tooltip").classList.remove("show");
      });
    });

    function toggleIcons(button, isSuccess) {
      const clipboardIcon = button.querySelector(".copy-clipboard");
      const checkIcon = button.querySelector(".copy-succeed");

      if (isSuccess) {
        clipboardIcon.style.display = "none";
        checkIcon.style.display = "inline";

        setTimeout(() => {
          checkIcon.style.display = "none";
          clipboardIcon.style.display = "inline";
        }, 1000);
      } else {
        clipboardIcon.style.display = "inline";
        checkIcon.style.display = "none";
      }
    }

    function showTooltip(tooltip, message) {
      tooltip.textContent = message;
      tooltip.classList.add("show");

      setTimeout(() => {
        tooltip.classList.remove("show");
      }, 1000);
    }
  });

  // Shortcut keys
  if (window.location.pathname !== "/search/") {
    document.addEventListener("keydown", function (event) {
      if (event.ctrlKey && event.shiftKey && event.key === "F") {
        window.location.href = "/search/";
      }
    });
  }
})();
