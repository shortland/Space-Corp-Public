$(document).ready(function() {
    // iscroll zoom
    /*
    var myScroll;

    (function loaded () {
        myScroll = new IScroll('#wrapper', {
            zoom: true,
            scrollX: true,
            scrollY: true,
            mouseWheel: true,
            wheelAction: 'zoom',
            zoomMin: 1,
            zoomMax: 3,
            zoomStart: 2
        });
    })();
    document.addEventListener('touchmove', function (e) { e.preventDefault(); }, false);
    */
	
	// // // // // localStorage.getItem('accountNumber1') // holds-> "shortland"

	// here at 10/13/15, 5:46PM you were about to store username, and other account informations in a json format like below. main.js needs to be changed to accept the new format.
	// basically recode main.js >.>
                  
    // edit: 8/9/16 thank you past-self for leaving notes like the above.
    // won't be working on main.html/.js rn since past self removed that page for beginners, will be working on other stuff, making metal mine give X metal every second based on hourly income without a cron job. Can now do with UNIX based timing methods, previously unknown to self. working on formula in notebook.

    // edit: 1/26/16 I implemented the above back then, though more recently have made buildings u

	// localStorage.setItem('storedPerson', JSON.stringify({firstName:'John', lastName:'Doe', age:'46'}));

	// var person = JSON.parse(localStorage.getItem('storedPerson'));

	// alert(person["age"]);

    //
    document.addEventListener('pause', function() {
        localStorage.setItem("restartTimer", "true");
    }, false);
    document.addEventListener('resume', function() {
        localStorage.setItem("restartTimer", "true");
    }, false);
        
    // gets the data in form of json stored in variable-localstorage "accountNumber1",

    var rushToken = function() {
        // set and remove that yellow star! if no, remove == html("")
        // if yes, remove and then set === .html()
            var current_time = (Math.floor(Date.now() / 1000));
            var account_data = JSON.parse(localStorage.getItem(localStorage.getItem('currentlyPlaying')));
            var buildStatus = JSON.parse(account_data['upgrade_data'])['upgrade_status'];
            var buildRushCost = JSON.parse(account_data['upgrade_data'])['upgrade_time'];
            if(buildStatus['metal_upgrade'] == "yes") {
                if((buildRushCost['metal_time'] - current_time) >= 5) {
                    $("#metal_token").html("<div class='rushUpgrade' id='metal_r'></div>");
                }
            }
            else {
                $("#metal_token").html("");
            }
            if(buildStatus['crystal_upgrade'] == "yes") {
                if((buildRushCost['crystal_time'] - current_time) >= 5) {
                    $("#crystal_token").html("<div class='rushUpgrade' id='crystal_r'></div>");
                }
            }
            else {
                $("#crystal_token").html("");
            }
            if(buildStatus['gas_upgrade'] == "yes") {
                if((buildRushCost['gas_time'] - current_time) >= 5) {
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

    $("#viewerContents").delegate(".rushUpgrade", "click", function () {
        var removeR = this.id;
        removeR = removeR.substring(0, removeR.indexOf("_"));
        rushUpgrade(removeR);
    });
    
    // gets account data in json, and sets it;
    // gets data on app open, & when app close/reopen
    (function getDatas() {
        $.post("http://ilankleiman.com/spacecorp/login/cookie_login.pl", {
            method: "login_A",
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
                var current_time = parseInt(Math.floor(Date.now() / 1000));
                var overlap_time = Math.abs(response_time - current_time);
                if(overlap_time > 6) {
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
                
                $('#usersLevel').html(account_data['level']);
                $('#usersName').html(account_data['username']);
                $('#usersPower').html("Power:&nbsp;"+account_data['power']);
                $('#usersGem').html(account_data['gems']);
               
                $('#mySystemName').html("&nbsp;&nbsp;"+account_data['system_name']);
                $('#myCoords').html("&nbsp;&nbsp;(X,Y): "+account_data['system_x'] + ", " + account_data['system_y']);
               
                $('#metalMine_level').html(account_data['metal_level']);
                $('#crystalMine_level').html(account_data['crystal_level']);
                $('#gasFracker_level').html(account_data['gas_level']);
                $('#cc_level').html(account_data['cc_level']);
                $('#lab_level').html(account_data['lab_level']);
                $('#shipyard_level').html(account_data['shipyard_level']);
                $('#HQ_level').html(account_data['corphq_level']);
                $('#market_level').html(account_data['globalmarket_level']);
                $('#stock_level').html(account_data['stockmarket_level']);
                $('#radar_level').html(account_data['radar_level']);
                $('#itemMender_level').html(account_data['itemmender_level']);
               
                $('#cash_balance').html(account_data['cash_balance'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
                $('#cash_income').html("+"+account_data['cash_income'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")+"/hr");
               
                $('#metal_balance').html(account_data['metal_balance'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
                $('#metal_income').html("+"+account_data['metal_income'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")+"/hr");
               
                $('#crystal_balance').html(account_data['crystal_balance'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
                $('#crystal_income').html("+"+account_data['crystal_income'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")+"/hr");
               
                $('#gas_balance').html(account_data['gas_balance'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
                $('#gas_income').html("+"+account_data['gas_income'].toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")+"/hr");
               
                (function update_balances(start_time) {
                    var currentTime = Math.floor(Date.now() / 1000);
                    if((currentTime - start_time) >= 10) {
                        //alert("big diff");
                        getDatas();
                        return;
                    }
                    var currentCash = parseInt(account_data['cash_balance']*100);
                    var currentCashAsBig = currentCash;
                    var cashIncomeAsBig = ((account_data['cash_income']/60)/60).toFixed(2) * 100;
                    var newCashBalance = (parseInt(currentCashAsBig) + parseInt(cashIncomeAsBig))/100;
                    account_data['cash_balance'] = newCashBalance;
                    $('#cash_balance').html(Math.round(newCashBalance).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
               
                    var currentMetal = parseInt(account_data['metal_balance']*100);
                    var currentMetalAsBig = currentMetal;
                    var metalIncomeAsBig = ((account_data['metal_income']/60)/60).toFixed(2) * 100;
                    var newMetalBalance = (parseInt(currentMetalAsBig) + parseInt(metalIncomeAsBig))/100;
                    account_data['metal_balance'] = newMetalBalance;
                    $('#metal_balance').html(Math.round(newMetalBalance).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
               
                    var currentCrystal = parseInt(account_data['crystal_balance']*100);
                    var currentCrystalAsBig = currentCrystal;
                    var crystalIncomeAsBig = ((account_data['crystal_income']/60)/60).toFixed(2) * 100;
                    var newCrystalBalance = (parseInt(currentCrystalAsBig) + parseInt(crystalIncomeAsBig))/100;
                    account_data['crystal_balance'] = newCrystalBalance;
                    $('#crystal_balance').html(Math.round(newCrystalBalance).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
               
                    var currentGas = parseInt(account_data['gas_balance']*100);
                    var currentGasAsBig = currentGas;
                    var gasIncomeAsBig = ((account_data['gas_income']/60)/60).toFixed(2) * 100;
                    var newGasBalance = (parseInt(currentGasAsBig) + parseInt(gasIncomeAsBig))/100;
                    account_data['gas_balance'] = newGasBalance;
                    $('#gas_balance').html(Math.round(newGasBalance).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ","));
               
                    if(localStorage.getItem("restartTimer") == "true") {
                        localStorage.setItem("restartTimer", "false");
                        getDatas();
                        return false;
                    }
                    setTimeout(function() {
                        update_balances(start_time);
                    }, 6000);

                }(Math.floor(Date.now() / 1000)));
            }
        });
    })();

});