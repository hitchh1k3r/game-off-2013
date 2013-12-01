window.fbAsyncInit = function() {
    FB.init({appId: '1427900747439630', status: true, xfbml: true});
};

facebookInit = function()
{
    if (document.getElementById('facebook-jssdk'))
    {
        return;
    }
    var firstScriptElement = document.getElementsByTagName('script')[0];
    var facebookJS = document.createElement('script'); 
    facebookJS.id = 'facebook-jssdk';
    facebookJS.src = '//connect.facebook.net/en_US/all.js';
    firstScriptElement.parentNode.insertBefore(facebookJS, firstScriptElement);
}

postToFacebook = function(message)
{
	FB.ui({method: 'feed', link: 'http://hitchh1k3r.github.io/gitFighter/web/', caption: message});
}