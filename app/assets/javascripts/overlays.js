// OPENS AND CLOSES THE OVERLAYS

/* Open when someone clicks on the span element */
function openStateNav() {
    document.getElementById("state-overlay").style.visibility = 'visible';
    document.getElementById("state-overlay").style.opacity = '1';
}

/* Open when someone clicks on the span element */
function openCategoryNav() {
    document.getElementById("category-overlay").style.visibility = 'visible';
    document.getElementById("category-overlay").style.opacity = '1';
}

// we dont have a sidebar overlay right now 
function openSidebarNav() {
    document.getElementById("sidebar-overlay").style.visibility = 'visible';
    document.getElementById("sidebar-overlay").style.opacity = '1';
}

function openMenuNav() {
    document.getElementById("menu-overlay").style.visibility = 'visible';
    document.getElementById("menu-overlay").style.opacity = '1';
}

/* Close when someone clicks on the "x" symbol inside the overlay */
function closeNav() {
    document.getElementById("state-overlay").style.visibility = "hidden";
    document.getElementById("state-overlay").style.opacity = "0";
    document.getElementById("category-overlay").style.visibility = "hidden";
    document.getElementById("category-overlay").style.opacity = "0";
    document.getElementById("menu-overlay").style.visibility = "hidden";
    document.getElementById("menu-overlay").style.opacity = "0";
}