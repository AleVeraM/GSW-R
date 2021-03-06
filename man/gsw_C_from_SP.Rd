% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/gsw.R
\name{gsw_C_from_SP}
\alias{gsw_C_from_SP}
\title{Conductivity from Practical Salinity}
\usage{
gsw_C_from_SP(SP, t, p)
}
\arguments{
\item{SP}{Practical Salinity (PSS-78) [ unitless ]}

\item{t}{in-situ temperature (ITS-90) [ deg C ]}

\item{p}{sea pressure [ dbar ]}
}
\description{
Conductivity from Practical Salinity
}
\examples{
gsw_C_from_SP(34.5487, 28.7856, 10) # 56.412599581571186
}
\references{
\url{http://www.teos-10.org/pubs/gsw/html/gsw_C_from_SP.html}
}

