% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/gsw.R
\name{gsw_sigma4}
\alias{gsw_sigma4}
\title{potential density anomaly referenced to 4000 dbar}
\usage{
gsw_sigma4(SA, CT)
}
\arguments{
\item{SA}{Absolute Salinity [ g/kg ]}

\item{CT}{Conservative Temperature [ deg C ]}
}
\value{
potential density anomaly with reference pressure 4000 dbar [ kg/m^3 ]
}
\description{
This uses the 48-term density equation, and returns
potential density referenced to a pressure of 4000 dbar,
minus 1000 kg/m^3.
}
\examples{
gsw_sigma3(34.7118, 28.8099) # 37.898467323406976
}
\references{
\url{http://www.teos-10.org/pubs/gsw/html/gsw_sigma4.html}
}

