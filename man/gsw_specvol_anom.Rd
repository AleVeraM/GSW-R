% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/gsw.R
\name{gsw_specvol_anom}
\alias{gsw_specvol_anom}
\title{Specific volume anomaly}
\usage{
gsw_specvol_anom(SA, CT, p)
}
\arguments{
\item{SA}{Absolute Salinity [ g/kg ]}

\item{CT}{Conservative Temperature [ deg C ]}

\item{p}{sea pressure [ dbar ]}
}
\value{
Specific volume anomaly [ m^3/kg ]
}
\description{
Specific volume anomaly
}
\examples{
gsw_specvol_anom(34.7118, 28.8099, 10) # 6.01005694856401e-6
}
\references{
\url{http://www.teos-10.org/pubs/gsw/html/gsw_specvol_anom.html}
}

