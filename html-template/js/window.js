
function windowPageLoad()
{
	//cancel select
	document.onselectstart = function()
	{
		if ( event.srcElement.tagName != "INPUT" )
		{
			//don't allow select event other then input
			return false;
		}
	}
	
	//cancel dragging
	document.ondragstart = function(){return false;}
}

function windowToggle(id)
{
	var e = document.getElementById(id);
	if ((e.style.display == 'block') || (e.style.display == ''))
	{
		e.style.display = 'none';
	} 
	else
	{
		e.style.display = 'block';
	}	
}
