(function () {
  // Shortcut keys
  if (window.location.pathname !== "/search/") {
    document.addEventListener("keydown", function (event) {
      if (event.ctrlKey && event.shiftKey && event.key === "F") {
        window.location.href = "/search/";
      }
    });
  }

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
  // document.addEventListener("DOMContentLoaded", function () {
  //   const clipboardButtons = document.querySelectorAll(
  //     '.code-header button[aria-label="copy"]'
  //   );
  //   clipboardButtons.forEach(function (button) {
  //     button.addEventListener("click", function () {
  //       const codeBlock = button
  //         .closest(".code-header")
  //         .nextElementSibling.querySelector(".rouge-code");
  //       const text = codeBlock.innerText.trim();

  //       navigator.clipboard
  //         .writeText(text)
  //         .then(function () {
  //           // button.innerHTML = '<i class="ti ti-check"></i>';
  //           showTooltip(button, "Copied!");
  //           setTimeout(function () {
  //             // button.innerHTML = '<i class="ti ti-clipboard"></i>';
  //           }, 2000);
  //         })
  //         .catch(function (err) {
  //           console.error("Failed to copy!", err);
  //         });
  //     });
  //   });

  //   function showTooltip(element, message) {
  //     const tooltip = document.createElement("div");
  //     tooltip.className = "tooltip";
  //     tooltip.textContent = message;
  //     document.body.appendChild(tooltip);

  //     const rect = element.getBoundingClientRect();
  //     tooltip.style.left = `${
  //       rect.left + window.scrollX + rect.width / 2 - tooltip.offsetWidth / 2
  //     }px`;
  //     tooltip.style.top = `${
  //       rect.top + window.scrollY - tooltip.offsetHeight - 5
  //     }px`;

  //     tooltip.classList.add("show");

  //     setTimeout(function () {
  //       tooltip.classList.remove("show");
  //       document.body.removeChild(tooltip);
  //     }, 2000);
  //   }
  // });

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
