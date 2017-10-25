$(document).ready(function() {
    var amIaMine;
    $(".structure").click(function() {
        /*
        /
        /   doesn't specifically work since the variable pressedId is trying to be scoped on viewer.html, not this page.
        /
        var pressedId = this.id;
        var ifrm = document.getElementById('myIframe');
        ifrm = ifrm.contentWindow || ifrm.contentDocument.document || ifrm.contentDocument;
        ifrm.document.open();
        ifrm.document.write('<script>alert(pressedId);<\/script>');
        ifrm.document.close();
        */
        
        /* these two do the same thing, cross support */
        //$("#viewerContents").css({"position":"relative", "height":"100%","overflow":"hidden", "overflow-x:":"hidden"});
        //$("#viewerContents").bind('touchmove', function(e){e.preventDefault()})
        
        // didnt work
        // didnt work cause i wrote it as  #viewerContent not #viewerContents
        //$("#viewerContents").css({"height":$(window).height(), "overflow" : "hidden"});
        $(".insideBorders").fadeOut(350);
        $("#bottomStyleBar").animate({"bottom":"-50px"}, 500);
        $("#top_lower_menu").animate({"top":"-62"}, 800);
        $("#top_menu").animate({"top":"-32"}, 500);
        
        
        $("#viewerContents").css({"height":($(window).height()-80), "overflow" : "hidden"}); // -80 b/c it still scrolled a bit? might have to increase that
        
        var originalTapID = this.id;
        
    // structure name
        var structureName = ((this.id).replace("_", " ")).replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
    
    // personal account data
        var account_data = JSON.parse(localStorage.getItem(localStorage.getItem('currentlyPlaying')));


        var isUpgrading = account_data['upgrade_data'];
        
    // structure level
        function currentStructureLevel() {
            if(originalTapID == "command_center")
                return account_data['building_level_data']['cc'];
            else if(originalTapID == "tech_lab")
                return account_data['building_level_data']['lab'];
            else if(originalTapID == "ship_yard")
                return account_data['building_level_data']['shipyard'];
            else if(originalTapID == "corporation_hq")
                return account_data['building_level_data']['corphq'];
            else if(originalTapID == "global_market")
                return account_data['building_level_data']['globalmarket'];
            else if(originalTapID == "stock_market")
                return account_data['building_level_data']['stockmarket'];
            else if(originalTapID == "metal_mine")
                return account_data['building_level_data']['metal'];
            else if(originalTapID == "crystal_mine")
                return account_data['building_level_data']['crystal'];
            else if(originalTapID == "gas_mine")
                return account_data['building_level_data']['gas'];
            else if(originalTapID == "radar_station")
                return account_data['building_level_data']['radar'];
            else if(originalTapID == "item_mender")
                return account_data['building_level_data']['itemmender'];
        }
    
    // mines incomes (we're getting from server, but theoretically we could get from json too)
        /*function currentMinesIncomes() {
            if(originalTapID == "metal_mine")
                return account_data['cc_level'];
            if(originalTapID == "crystal_mine")
                return account_data['lab_level'];
            if(originalTapID == "gas_mine")
                return account_data['shipyard_level'];
        }*/
        
    // if it's a mine

        var secondsToFormat = function(seconds) {
            var formattedTime;

            var minutes = seconds / 60;
            var hours = minutes / 60;
            var days = hours / 24;

            if(days == 1)
                formattedTime = "1 Day";
            else if(days > 1) {
                var fullDays = days.toString().split(".")[0];
                var remHours = (days - parseInt(fullDays)) * 24;

                if(parseInt(remHours) == 1) 
                    var multipleHours = "";
                else if(parseInt(remHours) > 1)
                    var multipleHours = "s";

                if(remHours >= 1)
                    return formattedTime = fullDays + " Days and " + remHours.toString().split(".")[0] + " Hour" + multipleHours;
                else
                    return formattedTime = fullDays + " Days";
            }

            if(hours == 1)
                formattedTime = "1 Hour";
            else if(hours > 1) {
                var fullHours = hours.toString().split(".")[0];
                var remMinutes = (hours - parseInt(fullHours)) * 60;
                if(parseInt(remMinutes) == 1) 
                    var multipleMinutes = "";
                else if(parseInt(remMinutes) > 1)
                    var multipleMinutes = "s";

                if(remMinutes >= 1)
                    return formattedTime = fullHours + " Hours and " + remMinutes.toString().split(".")[0] + " Minute" + multipleMinutes;
                else
                    return formattedTime = fullHours + " Hours";
            }

            if(minutes == 1)
                formattedTime = "1 Minute";
            else if(minutes > 1) {
                var fullMinutes = minutes.toString().split(".")[0];
                var remSeconds = (minutes - parseInt(fullMinutes)) * 60;

                if(parseInt(remSeconds) == 1) 
                    var multipleSeconds = "";
                else if(parseInt(remSeconds) > 1)
                    var multipleSeconds = "s";

                if(remSeconds >= 1)
                    return formattedTime = fullMinutes + " Minutes and " + remSeconds.toString().split(".")[0] + " Seconds" + multipleSeconds;
                else
                    return formattedTime = fullMinutes + " Minutes";
            }

            if(seconds == 1)
                return formattedTime = "1 Second";
            else if(seconds > 1) {
                var fullSeconds = seconds.toString().split(".")[0];
                return formattedTime = fullSeconds + " Seconds";
            }
        };


        if((originalTapID == "metal_mine") || (originalTapID == "gas_mine") || (originalTapID == "crystal_mine")) {
            var buildingIncome = mine_data['building_data'][originalTapID + '_data']['levels'][currentStructureLevel()-1]['income'];
            var nextLevelIncome = mine_data['building_data'][originalTapID + '_data']['levels'][currentStructureLevel()]['income'];
            var structureBuildTimeSeconds = mine_data['building_data'][originalTapID + '_data']['levels'][currentStructureLevel()-1]['time'];
            var upgradeCost = mine_data['building_data'][originalTapID + '_data']['levels'][currentStructureLevel()-1]['cost'];
            
            var structureBuildTime = secondsToFormat(structureBuildTimeSeconds);

            amIaMine = "<br/>Income: " + buildingIncome + "</br></br></br>Level: " + (parseInt(currentStructureLevel()) + 1) + " income: " + nextLevelIncome + "</br>Upgrade cost: " + upgradeCost + "</br>Time to upgrade: " + structureBuildTime;
        }
        else {
            amIaMine = "</br>"; // no ur not
        }
        
        $("#displayViewer").show();
        $("#displayViewer").animate({"left" : "5px"}, 500, function() {

            var remUpgradeTime;
            if(originalTapID.substring(originalTapID.indexOf("_")+1, originalTapID.length) == "mine") {
                remUpgradeTime = secondsToFormat(account_data["upgrade_time_data"][originalTapID.substring(0, originalTapID.indexOf("_"))] - Math.floor(Date.now() / 1000)) + " remaining";
            }
            else {
                remUpgradeTime = "";
            }

            $("#displayViewer").html("<h3>" + structureName + "</h3><div class='hvr-pulse' id='viewerCloser'></div><br/><br/>Level: " + currentStructureLevel() + amIaMine + "</br><br/><button class='upgrade_building " + originalTapID + "'>Upgrade</button></br>" + remUpgradeTime );
        });
    });

    $("#displayViewer").delegate(".upgrade_building", "click", function () {
        
        if(amIaMine == "</br>")
            var type = "building";
        else
            var type = "mine";

        tryUpgrade(type, $(this).attr('class').split(' ')[1]);
    });

    $("#displayViewer").delegate("#viewerCloser", "click", function () {
        //alert("clicked");
        $("#viewerContents").css({"height":"100%", "overflow" : "scroll"});
        
        $(".insideBorders").fadeIn(350);
        $("#bottomStyleBar").animate({"bottom":"0px"}, 500);
        $("#top_lower_menu").animate({"top":"32"}, 800);
        $("#top_menu").animate({"top":"0"}, 500);
        
        $("#displayViewer").fadeOut();
        $("#displayViewer").animate({"left" : "-500px"}, 500, function() {
            $("#displayViewer").html("");
        });
    });

});