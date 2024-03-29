% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/auth0.R
\name{use_auth0}
\alias{use_auth0}
\title{Auth0 configuration file}
\usage{
use_auth0(path = ".", file = "_auth0.yml", overwrite = FALSE)
}
\arguments{
\item{path}{Directory name. Should be the root of the shiny app
you want to add this functionality}

\item{file}{File name. Defaults to \verb{_auth0.yml}.}

\item{overwrite}{Will only overwrite existing path if \code{TRUE}.}
}
\description{
Create an YAML containing information to connect with Auth0.
}
\details{
The YAML configuration file has required parameters and extra
parameters.

The required parameters are:
\itemize{
\item \code{auth0_config} is a list contaning at least:
\itemize{
\item \code{api_url}: Your account at Auth0 (e.g. https://jonhdoe.auth0.com).
It is the "Domain" in Auth0 application settings.
\item \code{credentials}: Your credentials to access Auth0 API, including
\itemize{
\item \code{key}: the Client ID in Auth0 application settings.
\item \code{secret}: the Client Secret in Auth0 application settings.
}
}
}

The extra parameters are:
\itemize{
\item \code{remote_url}: If you are using Shiny-Server or ShinyApps IO service.
\item \code{scope}: The information that Auth0 app will access.
Defaults to "openid profile".
\item \code{request}: Endpoit to request a token. Defaults to "oauth/token"
\item \code{access}: Endpoit to access. Defaults to "oauth/token"
}
}
