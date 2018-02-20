//SELECT ALL ON ADMIN PAGES

function selectAllCheckboxes(elem) {

    var div = document.getElementById("admin-table");
    var chk = div.getElementsByTagName('input');
    var len = chk.length;

    for (var i = 0; i < len; i++) {
        if (chk[i].type === 'checkbox') {
            chk[i].checked = elem.checked;
        }
    }
}