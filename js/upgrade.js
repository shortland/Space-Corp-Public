function tryUpgradeU(type, name) {
    name = name.substring(0, name.indexOf("_"));
    $.post("http://ilankleiman.com/spacecorp/structures/upgrade.pl", {
        type: type,
        building: name,
        nocache: Math.random()
    },
    function(data, status) {
        //eval(data);
        $(document).ready(function() {
            var ifrm = document.getElementById('myIframe');
            ifrm = ifrm.contentWindow || ifrm.contentDocument.document || ifrm.contentDocument;
            ifrm.document.open();
            ifrm.document.write('<script>alert("'+data+'");<\/script>');
            ifrm.document.close();
        });

        // "refresh"
        localStorage.setItem("restartTimer", "true");
    });
}

function rushUpgrade(name) {
    $.post("http://ilankleiman.com/spacecorp/structures/upgrade.pl", {
        method: "rush",
        structure: name,
        nocache: Math.random()
    },
    function(data, status) {
        //eval(data);
        $(document).ready(function() {
            var ifrm = document.getElementById('myIframe');
            ifrm = ifrm.contentWindow || ifrm.contentDocument.document || ifrm.contentDocument;
            ifrm.document.open();
            ifrm.document.write('<script>alert("'+data+'");<\/script>');
            ifrm.document.close();

        });

        // "refresh"
        if(data.indexOf("!") !== -1) {

        }
        else {
            $("#"+name+"_r").hide();
        }
        
        localStorage.setItem("restartTimer", "true");
        //rushToken();
    });
}