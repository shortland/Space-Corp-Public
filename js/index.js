$(document).ready(function()
{
//localStorage.clear();
//localStorage.setItem("restartTimer", "false");
/* remove this 8/9/16 */
    $('#izk').animate({'color' : '#ffffff'}, 2000);
    setTimeout(function()
        {
            if(localStorage.getItem('username')) // account is already made, just go to viewer.html and get set details
            {
                // remove this in production setting
                // localStorage.setItem('accountNumber1', JSON.stringify({username:'unnamed-user', level:'1', cash:'4,000,000', metal:'400,000', crystal:'400,000', gas:'400,000', gems:'1,000', corporation:'-', power:'0'}));
               //$(body).hide();
               //var account_data = JSON.parse(localStorage.getItem(localStorage.getItem('currentlyPlaying')));
               //alert(localStorage.getItem(accountNumber1[cash]));
               window.location.href = 'viewer.html';
                //window.location.href = 'viewer.html';
            }
            else // account isn't made, but details will be set there upon registration completion; not here
            {
                //localStorage.setItem('accountNumber1', JSON.stringify({username:'unnamed-user', level:'1', cash:'4,000,000', metal:'400,000', crystal:'400,000', gas:'400,000', gems:'1,000', corporation:'-', power:'0'}));
               
                window.location.href = 'hello_commander.html';
                // localStorage.setItem('accountNumber1', JSON.stringify({username:'Shortland', level:'57', cash:'4,000,000,000', metal:'16,000,000', crystal:'18,000,000', gas:'26,000,000', gems:'18,000', corporation:'Costco'}));
            }
        }, 2500);
/* */ // remove this 8/9/16
                  
});

/*
    * 10/14/15 7:51PM
    *  - Reminder: redo main.js... storing account data in form of JSON.
    *
    *
*/
