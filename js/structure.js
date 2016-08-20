$(document).ready(function()
{
    $(".structure").click(function()
    {
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
        var structureName = originalTapID;
        var structureName = structureName.replace("_", " ");
        var structureName =  structureName.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
    
    // personal account data
        var account_data = JSON.parse(localStorage.getItem(localStorage.getItem('currentlyPlaying')));
        
    // structure level
        function currentStructureLevel()
        {
            if(originalTapID == "command_center"){var structureLevel = account_data['cc_level'];}
            if(originalTapID == "tech_lab"){var structureLevel = account_data['lab_level'];}
            if(originalTapID == "ship_yard"){var structureLevel = account_data['shipyard_level'];}
            if(originalTapID == "corporation_hq"){var structureLevel = account_data['corphq_level'];}
            if(originalTapID == "global_market"){var structureLevel = account_data['globalmarket_level'];}
            if(originalTapID == "stock_market"){var structureLevel = account_data['stockmarket_level'];}
            if(originalTapID == "metal_mine"){var structureLevel = account_data['metal_level'];}
            if(originalTapID == "crystal_mine"){var structureLevel = account_data['crystal_level'];}
            if(originalTapID == "gas_mine"){var structureLevel = account_data['gas_level'];}
            if(originalTapID == "radar_station"){var structureLevel = account_data['radar_level'];}
            if(originalTapID == "item_mender"){var structureLevel = account_data['itemmender_level'];}
            
            return structureLevel;
        }
    
    // mines incomes (we're getting from server, but theoretically we could get from json too)
        function currentMinesIncomes()
        {
            if(originalTapID == "metal_mine"){var structureLevel = account_data['cc_level'];}
            if(originalTapID == "crystal_mine"){var structureLevel = account_data['lab_level'];}
            if(originalTapID == "gas_mine"){var structureLevel = account_data['shipyard_level'];}
            
            return structureLevel;
        }
        
    // if it's a mine
        if((originalTapID == "metal_mine")||(originalTapID == "gas_mine")||(originalTapID == "crystal_mine"))
        {
            if(originalTapID == "metal_mine")
            {
                var buildingIncome = account_data['metal_income'];
                var parsedStructureMetal = JSON.parse(metal_mine_data);
                var nextLevelIncome = parsedStructureMetal[currentStructureLevel()].income;
                var structureBuildTimeSeconds = parsedStructureMetal[currentStructureLevel()].upgrade_time;
                var upgradeCost = parsedStructureMetal[currentStructureLevel()].upgrade_cost;
            }
            
            if(originalTapID == "crystal_mine")
            {
                var buildingIncome = account_data['crystal_income'];
                var parsedStructureCrystal = JSON.parse(crystal_mine_data);
                var nextLevelIncome = parsedStructureCrystal[currentStructureLevel()].income;
                var structureBuildTimeSeconds = parsedStructureCrystal[currentStructureLevel()].upgrade_time;
                var upgradeCost = parsedStructureCrystal[currentStructureLevel()].upgrade_cost;
            }
            
            if(originalTapID == "gas_mine")
            {
                var buildingIncome = account_data['gas_income'];
                var parsedStructureGas = JSON.parse(gas_mine_data);
                var nextLevelIncome = parsedStructureGas[currentStructureLevel()].income;
                var structureBuildTimeSeconds = parsedStructureGas[currentStructureLevel()].upgrade_time;
                var upgradeCost = parsedStructureGas[currentStructureLevel()].upgrade_cost;
            }
            
            var structureBuildTimeMinutes = structureBuildTimeSeconds / 60;
            var structureBuildTimeHours = structureBuildTimeMinutes / 60;
            var structureBuildTimeDays = structureBuildTimeHours / 24;

            if(structureBuildTimeDays == 1)
            {
                var structureBuildTime = "1 Day";
            }
            if(structureBuildTimeDays >= 1)
            {
                var numberOfWholeDays = structureBuildTimeDays.toString().split(".")[0];
                if(parseInt(numberOfWholeDays) > 1)
                {
                    var isItDays = "s";
                }
                else
                {
                    var isItDays = "";
                }
                var andRemainingHours = (structureBuildTimeDays - parseInt(numberOfWholeDays)) * 24;
                var structureBuildTime = numberOfWholeDays + " Day" + isItDays + " and " + andRemainingHours + " Hours";
            }
            if(structureBuildTimeHours <= 23)
            {
                var structureBuildTime = structureBuildTimeHours + " Hours";
            }
            if(structureBuildTimeHours == 1)
            {
                var structureBuildTime = "1 Hour";
            }
            if(structureBuildTimeMinutes <= 59)
            {
                var structureBuildTime = structureBuildTimeMinutes + " Minutes";
            }
            if(structureBuildTimeMinutes == 1)
            {
                var structureBuildTime = "1 Minute";
            }
            if(structureBuildTimeSeconds <= 59)
            {
                var structureBuildTime = structureBuildTimeSeconds + " Seconds";
            }
            if(structureBuildTimeSeconds == 1)
            {
                var structureBuildTime = "1 Second";
            }
            
            var amIaMine = "<br/>Income: " + buildingIncome + "</br></br></br>Level: " + (parseInt(currentStructureLevel()) + 1) + " income: " + nextLevelIncome + "</br>Upgrade cost: " + upgradeCost + "</br>Time to upgrade: " + structureBuildTime;

        }
        else
        {
            var amIaMine = "</br>"; // no ur not
        }
        
        
        $("#displayViewer").show();
        $("#displayViewer").animate({"left" : "5px"}, 500, function()
        {
            $("#displayViewer").html("<h3>"+structureName+"</h3><div class='hvr-pulse' id='viewerCloser'></div><br/><br/>Level: " + currentStructureLevel() + amIaMine + "</br><br/><button id='upgrade_metal'>Upgrade</button>");
        });
    });
    //$("#viewerCloser").delegate(".demoPROJ", "click", function ()
	//{

    $("#displayViewer").delegate("#viewerCloser", "click", function ()
    {
        //alert("clicked");
        $("#viewerContents").css({"height":"100%", "overflow" : "scroll"});
        
        $(".insideBorders").fadeIn(350);
        $("#bottomStyleBar").animate({"bottom":"0px"}, 500);
        $("#top_lower_menu").animate({"top":"32"}, 800);
        $("#top_menu").animate({"top":"0"}, 500);
        
        $("#displayViewer").fadeOut();
        $("#displayViewer").animate({"left" : "-500px"}, 500, function()
        {
            $("#displayViewer").html("");
        });
    });

});