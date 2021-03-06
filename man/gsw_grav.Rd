% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/gsw.R
\name{gsw_grav}
\alias{gsw_grav}
\title{Gravitational acceleration}
\usage{
gsw_grav(latitude, p)
}
\arguments{
\item{latitude}{latitude in decimal degress north [ -90 ... +90 ]}

\item{p}{sea pressure [ dbar ]}
}
\value{
gravitational acceleration [ m/s^2 ]
}
\description{
Gravitational acceleration
}
\examples{
gsw_grav(c(-90, -60), 0) # 9.832186205884799, 9.819178859991149
}
\references{
\url{http://www.teos-10.org/pubs/gsw/html/gsw_grav.html}
}

