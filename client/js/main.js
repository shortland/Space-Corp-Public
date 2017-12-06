$(document).ready(function()
{
	if(!localStorage.getItem('accountNumber1'))
	{
		localStorage.setItem('accountNumber1', 'New User');
		$('#selectedAccount').html('- New User -');
	}
	else
	{
		if(!localStorage.getItem('lastActiveAccount'))
		{
			$('#selectedAccount').html('- New User -');					// remember to add in active account
		}
		else
		{
			$('#selectedAccount').html('- ' + localStorage.getItem('lastActiveAccount') + ' -');
		}
	}

	$('#buttonStart').click(function()
	{
		if(!localStorage.getItem('lastActiveAccount'))
		{
			localStorage.setItem('currentlyPlaying', 'accountNumber1');
			window.location.href = 'hello_commander.html';
		}
		else
		{
			if(localStorage.getItem('lastActiveAccount') == "New User") // scenario shoudn't ever occus unless user quit during the choose name screen
			{
				localStorage.setItem('currentlyPlaying', 'accountNumber1'); 
				window.location.href = 'hello_commander.html';
			}
			else
			{
				// you were working here at 7:21PM september 8 -> b/c new user goes to new page with accountNumber1, store vars:
				// on hello_C -> after textbox lastActiveAccount <-- store username there.
				// on hello_C -> get accountNumber -> would be 1 above, or gotten by this.id bellow 
				// when get account number (ie creating new account, number 5.) accountNumber5 would get the value of username "Shortland"
				// when create username "Shortland" -> make user create password (hello_C)-> stores as accountNumber5Password -> ShortlandPassowrd
				window.location.href = 'viewer.html';
			}
		}
	});

	for (i = 1; i < 40; i++)
	{
		if(!localStorage.getItem('accountNumber' + i))
		{
			localStorage.setItem('lastAccount', i - 1);
			break;
		}
		else
		{
			$('#accountsOutput').append("<div class='listedAccount' id='accountNumber" + i + "'>&nbsp;&nbsp;&nbsp;&nbsp;" + localStorage.getItem('accountNumber' + i) + "<img src='images/launchpic.png' class='launchPicture' /></div><br/>");
		}
	}

	var topPosition = $(window).height() - ($('#mainMenuItems').height() + 40);
	var leftPosition = ($(window).width() - 180) / 2;
	$('#mainMenuItems').css({'top' : topPosition, 'left' : leftPosition});

	$('#contactSupport').click(function()
	{
		window.location.href = 'mailto:support@izkgames.com?Subject=I%20require%20assistance!';
	});

	$('#buttonAccounts, #selectedAccount').click(function()
	{
		$('#accountList').fadeIn('fast');
	});

	var accountsListCloseGap = $(window).width() * .05;
	var accountsListCloseRight = ($(window).width() - (accountsListCloseGap * 2)) - 53;
	$('#accountListClose').css({'left' : accountsListCloseRight});

	$('#accountListClose').click(function()
	{
		$('#accountList').fadeOut('fast');
	});

	var accountFrameHeight = $(window).height() - (($(window).height() * .1) + 63);
	$('#accountFrame').css({'height' : accountFrameHeight});

	$('#accountAddAnother').click(function()							// finish this up - new account doesnt make register screen, rather back to the "HELLO COMMANDER _____"
	{
		var newestAccountNumber = parseInt(localStorage.getItem('lastAccount')) + 1;
		localStorage.setItem('currentlyPlaying', 'accountNumber' + newestAccountNumber);
		window.location.href = 'hello_commander.html';
	});

	$('.listedAccount').click(function()
	{
		localStorage.setItem('currentlyPlaying', this.id);
		if(localStorage.getItem(this.id) == 'New User')
		{
			window.top.location.href = 'hello_commander.html';
		}
		else
		{
			window.top.location.href = 'viewer.html';
		}
	});
});

