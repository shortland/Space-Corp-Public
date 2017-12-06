var rushToken = function() {
    // set and remove that yellow star! if no, remove == html("")
    // if yes, remove and then set === .html()
        var current_time = (Math.floor(Date.now() / 1000));
        var account_data = JSON.parse(localStorage.getItem(localStorage.getItem('currentlyPlaying')));
        //var buildStatus = (account_data['upgrade_status_data']['metal']);
        //var buildRushCost = (account_data['upgrade_time_data']['metal']);
        //alert((account_data['upgrade_status_data']['metal']));
        if((account_data['upgrade_status_data']['metal']) == "yes") {
            if(((account_data['upgrade_time_data']['metal']) - current_time) >= 5) {
                $("#metal_token").html("<div class='rushUpgrade' id='metal_r'></div>");
            }
        }
        else {
            $("#metal_token").html("");
        }
        if((account_data['upgrade_status_data']['crystal']) == "yes") {
            if(((account_data['upgrade_time_data']['crystal']) - current_time) >= 5) {
                $("#crystal_token").html("<div class='rushUpgrade' id='crystal_r'></div>");
            }
        }
        else {
            $("#crystal_token").html("");
        }
        if((account_data['upgrade_status_data']['gas']) == "yes") {
            if(((account_data['upgrade_time_data']['gas']) - current_time) >= 5) {
                $("#gas_token").html("<div class='rushUpgrade' id='gas_r'></div>");
            }
        }
        else {
            $("#gas_token").html("");
        }

        //$("#viewerContents").delegate(".rushUpgrade", "click", function () {
            //alert(this.id);
        //    alert("d");
            
        //});
};