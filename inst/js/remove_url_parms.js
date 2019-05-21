var uri = window.location.toString();if (uri.indexOf('?') > 0) {var clean_uri = uri.substring(0, uri.indexOf('?'));window.history.replaceState({}, document.title, clean_uri);}
