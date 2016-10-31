// OPENS AND CLOSES THE OVERLAYS

/* Open when someone clicks on the span element */
function openStateNav() {
    document.getElementById("state-overlay").style.width = "100%";
}

/* Open when someone clicks on the span element */
function openCategoryNav() {
    document.getElementById("category-overlay").style.width = "100%";
}

function openSidebarNav() {
    document.getElementById("sidebar-overlay").style.width = "100%";
}

function openMenuNav() {
    document.getElementById("menu-overlay").style.width = "100%";
}

/* Close when someone clicks on the "x" symbol inside the overlay */
function closeNav() {
    document.getElementById("state-overlay").style.width = "0%";
    document.getElementById("category-overlay").style.width = "0%";
    document.getElementById("sidebar-overlay").style.width = "0%";
    document.getElementById("menu-overlay").style.width = "0%";
}