/*
    viewer2.js
    // recode since new json formatting
*/
$(document).ready(function() {

    document.addEventListener('pause', function() {
        localStorage.setItem("restartTimer", "true");
    }, false);
    document.addEventListener('resume', function() {
        localStorage.setItem("restartTimer", "true");
    }, false);

    (function getDatas() {
        $.post("http://ilankleiman.com/spacecorp2/auth/legacyClientWrapper.pl", {
            method: "login_A",
            bet: "viewer2",
            nocache: Math.random()
        },
        function(data,status) {
            try {
                eval(data);
            }
            catch(err) {
                alert(err);
            }
            if(status == "success") {
                // adds a secondary level to accountNumber1, calling it currentlyPlaying, hence why we use two instances of getItem(getItem(currentlyPlaying))
                // we could bypass using two getItems if we didn't set it to currentlyPlaying; although we could use multiple accounts set data by doing accountNumber1,2,3,4,5... idk... faster fetching.
                localStorage.setItem('currentlyPlaying', 'accountNumber1');
                var account_data = JSON.parse(localStorage.getItem(localStorage.getItem('currentlyPlaying')));
                
                var response_time = parseInt(account_data['nowtime']);
                //alert(response_time);
                var current_time = parseInt(Math.floor(Date.now() / 1000));
                var overlap_time = Math.abs(response_time - current_time);
                if(overlap_time > 8) {
                    var ifrm = document.getElementById('myIframe');
                    ifrm = ifrm.contentWindow || ifrm.contentDocument.document || ifrm.contentDocument;
                    ifrm.document.open();
                    ifrm.document.write('<script>alert("Server response time error");<\/script>');
                    ifrm.document.close();
                }
                else {
                    if($("body").css("display") == "none") {
                        $("body").show();
                    }
                    // wait to show body so that elements can render
                    console.log("it was: " + overlap_time);
                }

                // set rush image next to buildings currently building
                rushToken();
                $("#viewerContents").delegate(".rushUpgrade", "click", function () {
                    if(localStorage.getItem("rushTap")) {
                        if(parseInt(localStorage.getItem("rushTap")) >= Math.floor(Date.now() / 1000)) {

                            return;
                        }
                        else {
                            //alert("tapped");
                            localStorage.setItem("rushTap", Math.floor(Date.now() / 1000));
                            var removeR = this.id;
                            removeR = removeR.substring(0, removeR.indexOf("_"));
                            rushUpgrade(removeR);
                        }
                    }
                    else {
                        //alert("tapped");
                        localStorage.setItem("rushTap", Math.floor(Date.now() / 1000));
                        var removeR = this.id;
                        removeR = removeR.substring(0, removeR.indexOf("_"));
                        rushUpgrade(removeR);
                    }   
                });
                
                $('#usersLevel').html(account_data['user_data']['level']);
                $('#usersPower').html("Power:&nbsp;"+account_data['user_data']['power']);
                $('#usersName').html(account_data['user_data']['username']);
               
                $('#mySystemName').html("&nbsp;&nbsp;"+account_data['planet_data']['system_name']);
                $('#myCoords').html("&nbsp;&nbsp;(X,Y): "+account_data['planet_data']['system_x'] + ", " + account_data['planet_data']['system_y']);
               
                $('#metalMine_level').html(account_data['building_level_data']['metal']);
                $('#crystalMine_level').html(account_data['building_level_data']['crystal']);
                $('#gasFracker_level').html(account_data['building_level_data']['gas']);
                $('#cc_level').html(account_data['building_level_data']['cc']);
                $('#lab_level').html(account_data['building_level_data']['lab']);
                $('#shipyard_level').html(account_data['building_level_data']['shipyard']);
                $('#HQ_level').html(account_data['building_level_data']['corphq']);
                $('#market_level').html(account_data['building_level_data']['globalmarket']);
                $('#stock_level').html(account_data['building_level_data']['stockmarket']);
                $('#radar_level').html(account_data['building_level_data']['radar']);
                $('#itemMender_level').html(account_data['building_level_data']['itemmender']);

                $('#usersGem').html(account_data['current_resource_data']['gems']);
                
                $('#cash_balance').html(account_data['current_resource_data']['cash'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
                $('#metal_balance').html(account_data['current_resource_data']['metal'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
                $('#crystal_balance').html(account_data['current_resource_data']['crystal'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
                $('#gas_balance').html(account_data['current_resource_data']['gas'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
                

                $('#cash_income').html("+"+account_data['current_income_data']['cash'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")+"/hr");
                $('#metal_income').html("+"+account_data['current_income_data']['metal'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")+"/hr");
                $('#crystal_income').html("+"+account_data['current_income_data']['crystal'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")+"/hr");
                $('#gas_income').html("+"+account_data['current_income_data']['gas'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")+"/hr");
               
                (function update_balances(start_time) {
                    var currentTime = Math.floor(Date.now() / 1000);
                    if((currentTime - start_time) >= 10) {
                        //alert("big diff");
                        getDatas();
                        return;
                    }
                    var currentCash = parseInt(account_data['current_resource_data']['cash']*100);
                    var currentCashAsBig = currentCash;
                    var cashIncomeAsBig = ((account_data['current_income_data']['cash']/60)/60).toFixed(2) * 100;
                    var newCashBalance = (parseInt(currentCashAsBig) + parseInt(cashIncomeAsBig))/100;
                    account_data['current_resource_data']['cash'] = newCashBalance;
                    $('#cash_balance').html(Math.round(newCashBalance).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
               
                    var currentMetal = parseInt(account_data['current_resource_data']['metal']*100);
                    var currentMetalAsBig = currentMetal;
                    var metalIncomeAsBig = ((account_data['current_income_data']['metal']/60)/60).toFixed(2) * 100;
                    var newMetalBalance = (parseInt(currentMetalAsBig) + parseInt(metalIncomeAsBig))/100;
                    account_data['current_resource_data']['metal'] = newMetalBalance;
                    $('#metal_balance').html(Math.round(newMetalBalance).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
               
                    var currentCrystal = parseInt(account_data['current_resource_data']['crystal']*100);
                    var currentCrystalAsBig = currentCrystal;
                    var crystalIncomeAsBig = ((account_data['current_income_data']['crystal']/60)/60).toFixed(2) * 100;
                    var newCrystalBalance = (parseInt(currentCrystalAsBig) + parseInt(crystalIncomeAsBig))/100;
                    account_data['current_resource_data']['crystal'] = newCrystalBalance;
                    $('#crystal_balance').html(Math.round(newCrystalBalance).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
               
                    var currentGas = parseInt(account_data['current_resource_data']['gas']*100);
                    var currentGasAsBig = currentGas;
                    var gasIncomeAsBig = ((account_data['current_income_data']['gas']/60)/60).toFixed(2) * 100;
                    var newGasBalance = (parseInt(currentGasAsBig) + parseInt(gasIncomeAsBig))/100;
                    account_data['current_resource_data']['gas'] = newGasBalance;
                    $('#gas_balance').html(Math.round(newGasBalance).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
               
                    if(localStorage.getItem("restartTimer") == "true") {
                        localStorage.setItem("restartTimer", "false");
                        getDatas();
                        return false;
                    }
                    setTimeout(function() {
                        update_balances(start_time);
                    }, 1000);

                }(Math.floor(Date.now() / 1000)));
            }
        });
    })();

});