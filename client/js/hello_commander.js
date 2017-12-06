$(document).ready(function()
{
    data = "hello world";
    localStorage.setItem('nameError', 'false');
    $('#submitUsername').css({'left' : ($(window).width() / 2) - 90});

    $('#submitUsername').click(function()
    {
        if($('#setUsername').val().length > 20) // text box max length =20, but idk just incase
        {
            if(localStorage.getItem('nameError') == "true")
            {
                // you see the error, please type in your username >.>
                $("#setUsername").focus();
            }
            else
            {
                $('#addExtraHere').html("<br/><br/>");
                $('#messageBoxPadder').append("<br/><br/><div style='color:red;'>Please choose a username that's shorter.</span>");
                //document.getElementById("myAnchor").focus()
                localStorage.setItem('nameError', 'true');
                $("#setUsername").focus();
            }
        }
        if(($('#setUsername').val().length < 4) || ($('#setPassword').val().length < 4))
        {
            if(localStorage.getItem('nameError') == "true")
            {
                // you see the error, please type in your username >.>
                $("#setUsername").focus();
            }
            else
            {
                $('#addExtraHere').html("<br/><br/>");
                $('#messageBoxPadder').append("<br/><br/><div style='color:red;'>Your username and password must be at least 4 letters/numbers long.</span>");
                //document.getElementById("myAnchor").focus()
                localStorage.setItem('nameError', 'true');
                $("#setUsername").focus();
            }
        }
        else
        {
            // try to make account with that username
                               
            $.post("http://ilankleiman.com/spacecorp/login/register.pl",
            {
                username: $("#setUsername").val(),
                password: $("#setPassword").val(),
                email: "not_verified"
            },
            function(data,status)
            {
                localStorage.setItem("errorForPop", data);
                localStorage.setItem("username", $("#setUsername").val());
                popup();
            });
        }
    });
});