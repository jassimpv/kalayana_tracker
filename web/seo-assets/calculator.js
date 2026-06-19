(function () {
  "use strict";

  var ALLOCATIONS = {
    venueCatering: 0.35,
    decorClothing: 0.20,
    jewelleryGifts: 0.15,
    photography: 0.10,
    invitesTravel: 0.10,
    miscBuffer: 0.10
  };

  var LABELS = {
    venueCatering: "Venue & catering",
    decorClothing: "Decor & clothing",
    jewelleryGifts: "Jewellery & gifts",
    photography: "Photography & video",
    invitesTravel: "Invitations & travel",
    miscBuffer: "Miscellaneous buffer"
  };

  function formatCurrency(value, currency) {
    try {
      return new Intl.NumberFormat("en-IN", {
        style: "currency",
        currency: currency || "INR",
        maximumFractionDigits: 0
      }).format(value);
    } catch (e) {
      return (currency || "INR") + " " + Math.round(value).toLocaleString();
    }
  }

  function init() {
    var form = document.getElementById("budget-calculator-form");
    if (!form) return;

    var resultEl = document.getElementById("budget-calculator-result");
    var breakdownEl = document.getElementById("budget-calculator-breakdown");

    form.addEventListener("submit", function (event) {
      event.preventDefault();

      var totalBudget = parseFloat(document.getElementById("total-budget").value) || 0;
      var guestCount = parseFloat(document.getElementById("guest-count").value) || 0;
      var alreadyPaid = parseFloat(document.getElementById("already-paid").value) || 0;
      var currency = document.getElementById("currency").value || "INR";

      if (totalBudget <= 0) {
        resultEl.hidden = false;
        breakdownEl.innerHTML = "<p>Please enter a total wedding budget greater than zero.</p>";
        return;
      }

      var perGuest = guestCount > 0 ? totalBudget / guestCount : 0;
      var pending = Math.max(totalBudget - alreadyPaid, 0);

      var rows = "";
      Object.keys(ALLOCATIONS).forEach(function (key) {
        var amount = totalBudget * ALLOCATIONS[key];
        rows += "<dt>" + LABELS[key] + "</dt><dd>" + formatCurrency(amount, currency) + "</dd>";
      });

      breakdownEl.innerHTML =
        "<dl>" +
        "<dt>Total budget</dt><dd>" + formatCurrency(totalBudget, currency) + "</dd>" +
        "<dt>Already paid</dt><dd>" + formatCurrency(alreadyPaid, currency) + "</dd>" +
        "<dt>Pending amount</dt><dd>" + formatCurrency(pending, currency) + "</dd>" +
        (guestCount > 0
          ? "<dt>Estimated cost per guest</dt><dd>" + formatCurrency(perGuest, currency) + "</dd>"
          : "") +
        rows +
        "</dl>";

      resultEl.hidden = false;
      resultEl.setAttribute("tabindex", "-1");
      resultEl.focus({ preventScroll: false });
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
