var uri = window.location.toString();if (uri.indexOf('?') > 0) {var clean_uri = uri.replace(/code=.+&/gi, '');window.history.replaceState({}, document.title, clean_uri);}
