## Please see ../README_developer.md for the scheme used in adding functions
## here. Generally the functions will be added to Part 4.


## PART 1: document the package

#' R implementation of the Thermodynamic Equation Of Seawater - 2010 (TEOS-10)
#'
#' Provides an R interface to the TEOS-10 / GSW (Gibbs Sea Water) library,
#' for use by the "oce" package (see \url{http://dankelley.github.io/oce})
#' and other uses.
#'
#' The functions are linked with the C version of the TEOS-10 library,
#' but the interface (i.e. the function names and the argument lists)
#' match the Matlab implementation.  The documentation of the functions
#' provided here focuses on the arguments and return value, with links
#' to the TEOS-10 webpages yielding fuller details.
#' 
#' See \url{http://www.teos-10.org/pubs/gsw/html/gsw_contents.html}
#' for a list of the TEOS-10 functions, and links therein for more
#' information on the functions (including references to more detailed
#' software manuals and also to the related scientific literature).
#'
#' Each function provided here has a test suite that is used during the
#' building of the package. That means that results should match those of
#' the equivalent Matlab functions to 8 or more significant digits. And,
#' importantly, it means that the functions cannot drift from these
#' tested values, for if they did, the package would fail to build and
#' thus could not be hosted on CRAN.
#'
#' The underlying C code works on vectors, so each of the R functions
#' in gsw starts by transforming its arguments accordingly.  Generally,
#' this means first using \code{\link{rep}} on each argument to get something
#' with length matching the first argument, and, after the computation
#' is complete, converting the return value into a matrix, if the first
#' argument was a matrix. There are some exceptions to this, however.
#' For example, both \code{\link{gsw_SA_from_SP}} and 
#' \code{\link{gsw_SP_from_SA}} can handle the case in which the first
#' argument is a matrix and arguments \code{longitude} and \code{latitude}
#' are vectors sized to match that matrix. This can be handy with 
#' gridded datasets.
#'
#' As of late 2014, the package is still in an early stage of development,
#' with only about a third of the common functions having been coded. All
#' functions needed by the "oce" package are working, however, and the
#' development version of "oce" now prefers to use the present package
#' for calculations, if it is installed.
#'
#' @docType package
#' @name gsw
NULL


## PART 2: utility functions

#' Reshape list elements to match the shape of the first element.
#'
#' @param list A list of elements, typically arguments that will be used in GSW functions.
#' @return A list with all elements of same shape (length or dimension).
argfix <- function(list)
{
    n <- length(list)
    if (n > 0) {
        length1 <- length(list[[1]])
        for (i in 2:n) {
            if (length(list[[i]]) != length1) {
                list[[i]] <- rep(list[[i]], length.out=length1)
            }
        }
        if (is.matrix(list[[1]])) {
            for (i in 2:n) {
                dim(list[[i]]) <- dim(list[[1]])
            }
        }
    }
    list
}



## PART 3: gsw (Gibbs SeaWater) functions, in alphabetical order (ignoring case)

#' adiabatic lapse rate from Conservative Temperature
#'
#' Note that the unit is K/Pa, i.e. 1e-4 times K/dbar.
#' 
#' @param SA Absolute Salinity [ g/kg ]
#' @param CT Conservative Temperature [ deg C ]
#' @param p sea pressure [ dbar ]
#' @return adiabatic lapse rate (note unconventional unit) [ K/Pa ]
#' @examples
#' gsw_adiabatic_lapse_rate_from_CT(34.7118, 28.7856, 10) # 2.40199646230069e-8
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_adiabatic_lapse_rate_from_CT.html}
gsw_adiabatic_lapse_rate_from_CT <- function(SA, CT, p)
{
    l <- argfix(list(SA=SA, CT=CT, p=p))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_adiabatic_lapse_rate_from_CT",
               SA=as.double(l$SA), CT=as.double(l$CT), p=as.double(l$p),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}
                                        
#' thermal expansion coefficient with respect to Conservative Temperature. (48-term equation)
#' 
#' @param SA Absolute Salinity [ g/kg ]
#' @param CT Conservative Temperature [ deg C ]
#' @param p sea pressure [ dbar ]
#' @return thermal expansion coefficient with respect to Conservative Temperature [ 1/K ]
#' @examples
#' gsw_alpha(34.7118, 28.7856, 10) # 3.24480399390879e-3
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_alpha.html}
gsw_alpha <- function(SA, CT, p)
{
    l <- argfix(list(SA=SA, CT=CT, p=p))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_alpha",
               SA=as.double(l$SA), CT=as.double(l$CT), p=as.double(l$p),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}

#' thermal expansion coefficient over haline contraction coefficient (48-term equation)
#' 
#' @param SA Absolute Salinity [ g/kg ]
#' @param CT Conservative Temperature [ deg C ]
#' @param p sea pressure [ dbar ]
#' @return ratio of thermal expansion coefficient to haline contraction coefficient [ (g/kg)/K ]
#' @examples
#' gsw_alpha_on_beta(34.7118, 28.8099, 10) # 0.452454540612631
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_alpha_on_beta.html}
gsw_alpha_on_beta <- function(SA, CT, p)
{
    l <- argfix(list(SA=SA, CT=CT, p=p))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_alpha_on_beta",
               SA=as.double(l$SA), CT=as.double(l$CT), p=as.double(l$p),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}

#' thermal expansion coefficient with respect to in-situ temperature
#' 
#' @param SA Absolute Salinity [ g/kg ]
#' @param t in-situ temperature (ITS-90)  [ deg C ]
#' @param p sea pressure [ dbar ]
#' @return thermal expansion coefficient with respect to in-situ temperature [ 1/K ]
#' @examples
#' gsw_alpha_wrt_t_exact(34.7118, 28.7856, 10) # 1e-3*0.325601747227247
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_alpha_wrt_t_exact.html}
gsw_alpha_wrt_t_exact<- function(SA, t, p)
{
    l <- argfix(list(SA=SA, t=t, p=p))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_alpha_wrt_t_exact",
               SA=as.double(l$SA), t=as.double(l$t), p=as.double(l$p),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}

#' Conductivity from Practical Salinity
#' 
#' @param SP Practical Salinity (PSS-78) [ unitless ]
#' @param t in-situ temperature (ITS-90) [ deg C ]
#' @param p sea pressure [ dbar ]
#' @examples 
#' gsw_C_from_SP(34.5487, 28.7856, 10) # 56.412599581571186
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_C_from_SP.html}
gsw_C_from_SP <- function(SP, t, p)
{
    l <- argfix(list(SP=SP, t=t, p=p))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_C_from_SP",
               SP=as.double(l$SP), t=as.double(l$t), p=as.double(l$p),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SP))
        dim(rval) <- dim(SP)
    rval
}

#' saline contraction coefficient at constant Conservative Temperature. (48-term equation)
#' 
#' @param SA Absolute Salinity [ g/kg ]
#' @param CT Conservative Temperature [ deg C ]
#' @param p sea pressure [ dbar ]
#' @return saline contraction coefficient at constant Conservative Temperature [ kg/g ]
#' @examples
#' SA = c(34.7118, 34.8915, 35.0256, 34.8472, 34.7366, 34.7324)
#' CT = c(28.7856, 28.4329, 22.8103, 10.2600,  6.8863,  4.4036)
#' p =  c(     10,      50,     125,     250,     600,    1000)
#' beta <- gsw_beta(SA,CT,p)
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_beta.html}
gsw_beta <- function(SA, CT, p)
{
    l <- argfix(list(SA=SA, CT=CT, p=p))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_beta",
               SA=as.double(l$SA), CT=as.double(l$CT), p=as.double(l$p),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}

#' saline contraction coefficient at constant in-situ temperature
#' 
#' @param SA Absolute Salinity [ g/kg ]
#' @param t in-situ temperature (ITS-90) [ deg C ]
#' @param p sea pressure [ dbar ]
#' @return saline contraction coefficient at constant in-situ temperature [ kg/g ]
#' @examples
#' gsw_beta_const_t_exact(34.7118, 28.7856, 10) # 7.31120837010429e-4
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_beta_const_t_exact.html}
gsw_beta_const_t_exact <- function(SA, t, p)
{
    l <- argfix(list(SA=SA, t=t, p=p))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_beta_const_t_exact",
               SA=as.double(l$SA), t=as.double(l$t), p=as.double(l$p),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}

#' Isobaric heat capacity
#' 
#' @param SA Absolute Salinity [ g/kg ]
#' @param t in-situ temperature (ITS-90) [ deg C ]
#' @param p sea pressure [ dbar ]
#' @examples 
#' gsw_cp_t_exact(34.7118, 28.7856, 10) # 4002.888003958537
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_cp_t_exact.html}
gsw_cp_t_exact <- function(SA, t, p)
{
    l <- argfix(list(SA=SA, t=t, p=p))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_cp_t_exact",
               SA=as.double(l$SA), t=as.double(l$t), p=as.double(l$p),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}

#' cabbeling coefficient (48-term equation)
#' 
#' @param SA Absolute Salinity [ g/kg ]
#' @param CT Conservative Temperature [ deg C ]
#' @param p sea pressure [ dbar ]
#' @return cabbeling coefficient with respect to Conservative Temperature [ 1/(K^2) ]
#' @examples
#' SA = c(34.7118, 34.8915, 35.0256, 34.8472, 34.7366, 34.7324)
#' CT = c(28.8099, 28.4392, 22.7862, 10.2262,  6.8272,  4.3236)
#' p =  c(     10,      50,     125,     250,     600,    1000)
#' cabbeling <- gsw_cabbeling(SA,CT,p)
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_cabbeling.html}
gsw_cabbeling <- function(SA, CT, p)
{
    l <- argfix(list(SA=SA, CT=CT, p=p))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_cabbeling",
               SA=as.double(l$SA), CT=as.double(l$CT), p=as.double(l$p),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}

#' Conservative temperature freezing point
#'
#' Note: as of 2014-12-23, this corresponds to the Matlab function
#' called \code{gsw_t_freezing_poly}. (The confusion arises from a
#' mismatch in release version between the Matlab and C libraries.)
#' 
#' @param SA Absolute Salinity [ g/kg ]
#' @param p sea pressure [ dbar ]
#' @param saturation_fraction saturation fraction of dissolved air in seawater
#' @return Conservative Temperature at freezing of seawater [ deg C ]. That is, the freezing temperature expressed in terms of Conservative Temperature (ITS-90). 
#' @examples 
#' gsw_CT_freezing(34.7118, 10) # -1.899657519404743
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_CT_freezing.html}
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_CT_freezing_poly.html}
gsw_CT_freezing <- function(SA, p, saturation_fraction=1)
{
    l <- argfix(list(SA=SA, p=p, saturation_fraction=saturation_fraction))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_CT_freezing",
               SA=as.double(l$SA), p=as.double(l$p), saturation_fraction=as.double(l$saturation_fraction),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}

#' Conservative Temperature from potential temperature
#' 
#' @param SA Absolute Salinity [ g/kg ]
#' @param pt potential temperature (ITS-90) [ deg C ]
#' @return Conservative Temperature [ deg C ]
#' @examples 
#' gsw_CT_from_pt(34.7118, 28.7832) # 28.809923015982083
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_CT_from_pt.html}
gsw_CT_from_pt <- function(SA, pt)
{
    l <- argfix(list(SA=SA, pt=pt))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_CT_from_pt",
               SA=as.double(l$SA), pt=as.double(l$pt),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}

#' Convert from temperature to conservative temperature
#' 
#' @param SA Absolute Salinity [ g/kg ]
#' @param t in-situ temperature (ITS-90) [ deg C ]
#' @param p sea pressure [ dbar ]
#' @examples 
#' gsw_CT_from_t(34.7118, 28.7856, 10) # 28.809919826700281
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_CT_from_t.html}
gsw_CT_from_t <- function(SA, t, p)
{
    l <- argfix(list(SA=SA, t=t, p=p))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_CT_from_t",
               SA=as.double(l$SA), t=as.double(l$t), p=as.double(l$p),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}

#' Specific enthalpy of seawater (48-term equation)
#' 
#' @param SA Absolute Salinity [ g/kg ]
#' @param CT Conservative Temperature [ deg C ]
#' @param p sea pressure [ dbar ]
#' @examples 
#' gsw_enthalpy(34.7118, 28.8099, 10) # 1.1510318130700132e5
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_enthalpy.html}
gsw_enthalpy <- function(SA, CT, p)
{
    l <- argfix(list(SA=SA, CT=CT, p=p))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_enthalpy",
               SA=as.double(l$SA), t=as.double(l$CT), p=as.double(l$p),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}

#' Specific enthalpy of seawater
#' 
#' @param SA Absolute Salinity [ g/kg ]
#' @param t in-situ temperature (ITS-90)  [ deg C ]
#' @param p sea pressure [ dbar ]
#' @examples 
#' gsw_enthalpy_t_exact(34.7118, 28.7856, 10) # 1.151032604783763e5
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_enthalpy_t_exact.html}
gsw_enthalpy_t_exact <- function(SA, t, p)
{
    l <- argfix(list(SA=SA, t=t, p=p))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_enthalpy_t_exact",
               SA=as.double(l$SA), t=as.double(l$t), p=as.double(l$p),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}

#' Specific entropy as a function of in-situ temperature and pressure
#'
#' Calculates specific entropy given Absolute Salinity, in-situ
#' temperature and pressure.
#'
#' The related function gsw_entropy_from_CT() is not provided
#' in the C library, although it is available in the (later-
#' versioned) Matlab library.
#' 
#' @param SA Absolute Salinity [ g/kg ]
#' @param t in-situ temperature (ITS-90) [ deg C ]
#' @param p sea pressure [ dbar ]
#' @return specific entropy [ J/(kg*K) ]
#' @examples
#' gsw_entropy_from_t(34.7118, 28.7856, 10) # 400.3894252787245
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_entropy_from_t.html}
gsw_entropy_from_t <- function(SA, t, p)
{
    l <- argfix(list(SA=SA, t=t, p=p))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_entropy_from_t",
               SA=as.double(l$SA), t=as.double(l$t), p=as.double(l$p),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}

#' Gravitational acceleration
#' 
#' @param latitude latitude in decimal degress north [ -90 ... +90 ]
#' @param p sea pressure [ dbar ]
#' @return gravitational acceleration [ m/s^2 ]
#' @examples
#' gsw_grav(c(-90, -60), 0) # 9.832186205884799, 9.819178859991149
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_grav.html}
gsw_grav <- function(latitude, p)
{
    l <- argfix(list(latitude=latitude, p=p))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_grav",
               latitude=as.double(l$latitude), p=as.double(l$p),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(latitude))
        dim(rval) <- dim(latitude)
    rval
}

#' Calculate Brunt Vaisala Frequency squared
#'
#' @param SA Absolute Salinity [ g/kg ]
#' @param CT Conservative Temperature [ deg C ]
#' @param p sea pressure [ dbar ]
#' @param latitude latitude in decimal degrees [ -90 to 90 ]
#' @return a list containing N2 [ s^(-2) ] and mid-point pressure p_mid [ dbar ]
#' @examples 
#' SA <- c(34.7118, 34.8915)
#' CT <- c(28.8099, 28.4392)
#' p <- c(      10,      50)
#' latitude <- 4
#' gsw_Nsquared(SA, CT, p, latitude)$N2 # 6.0847042791371e-5
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_Nsquared.html}
gsw_Nsquared <- function(SA, CT, p, latitude=0)
{
    l <- argfix(list(SA=SA, CT=CT, p=p, latitude=latitude))
    n <- length(l[[1]])
    r <- .C("wrap_gsw_Nsquared",
            SA=as.double(l$SA), CT=as.double(l$CT), p=as.double(l$p), latitude=as.double(l$latitude),
            n=n, n2=double(n-1), p_mid=double(n-1), NAOK=TRUE, package="gsw")
    if (is.matrix(SA))
        stop("gsw_Nsquared() cannot handle matix SA")
    list(N2=r$n2, p_mid=r$p_mid)
}

#' potential density
#' 
#' @param SA Absolute Salinity [ g/kg ]
#' @param t in-situ temperature (ITS-90) [ deg C ]
#' @param p sea pressure [ dbar ]
#' @param p_ref reference pressure [ dbar ]
#' @return potential density [ kg/m^3 ]
#' @examples
#' gsw_pot_rho_t_exact(34.7118, 28.7856, 10, 0) # 1021.798145811089
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_pot_rho_t_exact.html}
gsw_pot_rho_t_exact <- function(SA, t, p, p_ref)
{
    l <- argfix(list(SA=SA, t=t, p=p, p_ref=p_ref))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_pot_rho_t_exact",
               SA=as.double(l$SA), t=as.double(l$t), p=as.double(l$p), pref=as.double(l$p_ref),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}

#' in-situ density (48-term equation)
#' 
#' @param SA Absolute Salinity [ g/kg ]
#' @param CT Conservative Temperature [ deg C ]
#' @param p sea pressure [ dbar ]
#' @return in-situ density [ kg/m^3 ]
#' @examples
#' gsw_rho(34.7118, 28.8099, 10) # 1021.8404465661
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_rho.html}
gsw_rho <- function(SA, CT, p)
{
    l <- argfix(list(SA=SA, CT=CT, p=p))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_rho",
               SA=as.double(l$SA), CT=as.double(l$CT), p=as.double(l$p),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}

#' in-situ density
#' 
#' @param SA Absolute Salinity [ g/kg ]
#' @param t in-situ temperature (ITS-90) [ deg C ]
#' @param p sea pressure [ dbar ]
#' @return in-situ density [ kg/m^3 ]
#' @examples
#' gsw_rho_t_exact(34.7118, 28.7856, 10) # 1021.840173185531
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_rho_t_exact.html}
gsw_rho_t_exact <- function(SA, t, p)
{
    l <- argfix(list(SA=SA, t=t, p=p))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_rho_t_exact",
               SA=as.double(l$SA), t=as.double(l$t), p=as.double(l$p),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}

#' Convert from density to absolute salinity
#'
#' @param rho seawater density [ kg/m^3 ]
#' @param CT Conservative Temperature [ deg C ]
#' @param p sea pressure [ dbar ]
#' @examples
#' gsw_SA_from_rho(1021.8482, 28.7856, 10) # 34.711382887931144
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_SA_from_rho.html}
gsw_SA_from_rho <- function(rho, CT, p)
{
    l <- argfix(list(rho=rho, CT=CT, p=p))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_SA_from_rho",
               SA=as.double(l$rho), CT=as.double(l$CT), p=as.double(l$p),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(rho))
        dim(rval) <- dim(rho)
    rval
}

#' Convert from practical salinity to absolute salinity
#'
#' Calculate Absolute Salinity from Practical Salinity, pressure,
#' longitude, and latitude.
#'
#' If SP is a matrix and if its dimensions correspond to the
#' lengths of longitude and latitude, then the latter are
#' converted to analogous matrices with \code{\link{expand.grid}}.
#' 
#' @param SP Practical Salinity (PSS-78) [ unitless ]
#' @param p sea pressure [ dbar ]
#' @param longitude longitude in decimal degrees [ 0 to 360 or -180 to 180]
#' @param latitude latitude in decimal degrees [ -90 to 90 ]
#' @examples
#' gsw_SA_from_SP(34.5487, 10, 188, 4) # 34.711778344814114 
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_SA_from_SP.html}
gsw_SA_from_SP <- function(SP, p, longitude, latitude)
{
    ## check for special case that SP is a matrix defined on lon and lat
    if (is.matrix(SP)) {
        dim <- dim(SP)
        if (length(longitude) == dim[1] && length(latitude) == dim[2]) {
            ll <- expand.grid(longitude=as.vector(longitude), latitude=as.vector(latitude))
            longitude <- ll$longitude
            latitude <- ll$latitude
        }
    }
    l <- argfix(list(SP=SP, p=p, longitude=longitude, latitude=latitude))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_SA_from_SP",
               SP=as.double(l$SP), p=as.double(l$p), longitude=as.double(l$longitude), latitude=as.double(l$latitude),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SP))
        dim(rval) <- dim(SP)
    rval
}

#' potential density anomaly referenced to 0 dbar
#'
#' This uses the 48-term density equation, and returns
#' potential density referenced to a pressure of 0 dbar,
#' minus 1000 kg/m^3.
#'
#' @param SA Absolute Salinity [ g/kg ]
#' @param CT Conservative Temperature [ deg C ]
#' @return potential density anomaly [ kg/m^3 ]
#' @examples
#' gsw_sigma0(34.7118, 28.8099) # 21.798411276610750
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_sigma0.html}
gsw_sigma0 <- function(SA, CT)
{
    l <- argfix(list(SA=SA, CT=CT))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_sigma0",
               SA=as.double(l$SA), CT=as.double(l$CT),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}

#' potential density anomaly referenced to 1000 dbar
#'
#' This uses the 48-term density equation, and returns
#' potential density referenced to a pressure of 1000 dbar,
#' minus 1000 kg/m^3.
#'
#' @param SA Absolute Salinity [ g/kg ]
#' @param CT Conservative Temperature [ deg C ]
#' @return potential density anomaly [ kg/m^3 ]
#' @examples
#' gsw_sigma1(34.7118, 28.8099) # 25.955891533636986
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_sigma1.html}
gsw_sigma1 <- function(SA, CT)
{
    l <- argfix(list(SA=SA, CT=CT))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_sigma1",
               SA=as.double(l$SA), CT=as.double(l$CT),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}

#' potential density anomaly referenced to 2000 dbar
#'
#' This uses the 48-term density equation, and returns
#' potential density referenced to a pressure of 2000 dbar,
#' minus 1000 kg/m^3.
#'
#' @param SA Absolute Salinity [ g/kg ]
#' @param CT Conservative Temperature [ deg C ]
#' @return potential density anomaly [ kg/m^3 ]
#' @examples
#' gsw_sigma2(34.7118, 28.8099) # 30.022796416066058
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_sigma2.html}
gsw_sigma2 <- function(SA, CT)
{
    l <- argfix(list(SA=SA, CT=CT))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_sigma2",
               SA=as.double(l$SA), CT=as.double(l$CT),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}

#' potential density anomaly referenced to 3000 dbar
#'
#' This uses the 48-term density equation, and returns
#' potential density referenced to a pressure of 3000 dbar,
#' minus 1000 kg/m^3.
#'
#' @param SA Absolute Salinity [ g/kg ]
#' @param CT Conservative Temperature [ deg C ]
#' @return potential density anomaly with reference pressure 3000 dbar [ kg/m^3 ]
#' @examples
#' gsw_sigma3(34.7118, 28.8099) # 34.002600253012133
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_sigma3.html}
gsw_sigma3 <- function(SA, CT)
{
    l <- argfix(list(SA=SA, CT=CT))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_sigma3",
               SA=as.double(l$SA), CT=as.double(l$CT),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}

#' potential density anomaly referenced to 4000 dbar
#'
#' This uses the 48-term density equation, and returns
#' potential density referenced to a pressure of 4000 dbar,
#' minus 1000 kg/m^3.
#'
#' @param SA Absolute Salinity [ g/kg ]
#' @param CT Conservative Temperature [ deg C ]
#' @return potential density anomaly with reference pressure 4000 dbar [ kg/m^3 ]
#' @examples
#' gsw_sigma3(34.7118, 28.8099) # 37.898467323406976
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_sigma4.html}
gsw_sigma4 <- function(SA, CT)
{
    l <- argfix(list(SA=SA, CT=CT))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_sigma4",
               SA=as.double(l$SA), CT=as.double(l$CT),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}

#' sound speed with 48-term density
#'
#' This uses the 48-term density equation.
#'
#' @param SA Absolute Salinity [ g/kg ]
#' @param CT Conservative Temperature [ deg C ]
#' @param p sea pressure [ dbar ]
#' @return sound speed [ m/s ]
#' @examples
#' gsw_sound_speed(34.7118, 28.7856, 10) # 1542.420534932182
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_sound_speed.html}
gsw_sound_speed<- function(SA, CT, p)
{
    l <- argfix(list(SA=SA, CT=CT, p=p))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_sound_speed",
               SA=as.double(l$SA), CT=as.double(l$CT), p=as.double(l$p),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}

#' sound speed
#'
#' @param SA Absolute Salinity [ g/kg ]
#' @param t in-situ temperature (ITS-90) [ deg C ]
#' @param p sea pressure [ dbar ]
#' @return sound speed [ m/s ]
#' @examples
#' gsw_sound_speed_t_exact(34.7118, 28.7856, 10) # 1542.420534932182
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_sound_speed_t_exact.html}
gsw_sound_speed_t_exact <- function(SA, t, p)
{
    l <- argfix(list(SA=SA, t=t, p=p))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_sound_speed_t_exact",
               SA=as.double(l$SA), t=as.double(l$t), p=as.double(l$p),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}

#' Specific volume
#' 
#' @param SA Absolute Salinity [ g/kg ]
#' @param CT Conservative Temperature [ deg C ]
#' @param p sea pressure [ dbar ]
#' @return Specific volume (1/density)
#' @examples 
#' gsw_specvol(34.7118, 28.8099, 10) # 9.78626363206202e-4
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_specvol.html}
gsw_specvol  <- function(SA, CT, p)
{
    1 / gsw_rho(SA, CT, p)
}

#' Specific volume anomaly
#' 
#' @param SA Absolute Salinity [ g/kg ]
#' @param CT Conservative Temperature [ deg C ]
#' @param p sea pressure [ dbar ]
#' @return Specific volume anomaly [ m^3/kg ]
#' @examples 
#' gsw_specvol_anom(34.7118, 28.8099, 10) # 6.01005694856401e-6
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_specvol_anom.html}
gsw_specvol_anom  <- function(SA, CT, p)
{
    l <- argfix(list(SA=SA, CT=CT, p=p))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_specvol_anom",
               SA=as.double(l$SA), CT=as.double(l$CT), p=as.double(l$p),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}

#' Specific volume
#' 
#' @param SA Absolute Salinity [ g/kg ]
#' @param t in-situ temperature (ITS-90)  [ deg C ]
#' @param p sea pressure [ dbar ]
#' @return Specific volume [ m^3/kg ]
#' @examples 
#' gsw_specvol_t_exact(34.7118, 28.7856, 10) # 9.78626625025472e-4
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_specvol_t_exact.html}
gsw_specvol_t_exact  <- function(SA, t, p)
{
    l <- argfix(list(SA=SA, t=t, p=p))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_specvol_t_exact",
               SA=as.double(l$SA), CT=as.double(l$t), p=as.double(l$p),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}

#' Convert from conductivity to practical salinity
#' 
#' @param C conductivity [ mS/cm ]
#' @param t in-situ temperature (ITS-90) [ deg C ]
#' @param p sea pressure [ dbar ]
#' @return Practical salinity.
#' @examples 
#' gsw_SP_from_C(34.5487, 28.7856, 10) # 20.009869599086951
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_SP_from_C.html}
gsw_SP_from_C <- function(C, t, p)
{
    l <- argfix(list(C=C, t=t, p=p))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_SP_from_C",
               C=as.double(l$C), t=as.double(l$t), p=as.double(l$p),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(C))
        dim(rval) <- dim(C)
    rval
}

#' Convert from Absolute Salinity to Practical Salinity
#'
#' Calculate Practical Salinity from Absolute Salinity, pressure,
#' longitude, and latitude.
#'
#' If SP is a matrix and if its dimensions correspond to the
#' lengths of longitude and latitude, then the latter are
#' converted to analogous matrices with \code{\link{expand.grid}}.
#'
#' Note: unlike the corresponding Matlab function, this does not
#' return a flag indicating whether the location is in the ocean.
#' 
#' @param SA Absolute Salinity [ g/kg ]
#' @param p sea pressure [ dbar ]
#' @param longitude longitude in decimal degrees [ 0 to 360 or -180 to 180]
#' @param latitude latitude in decimal degrees [ -90 to 90 ]
#' @return Practical salinity.
#' @examples 
#' gsw_SP_from_SA(34.7118, 10, 188, 4) # 34.548721553448317
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_SP_from_SA.html}
gsw_SP_from_SA <- function(SA, p, longitude, latitude)
{
    ## check for special case that SP is a matrix defined on lon and lat
    if (is.matrix(SA)) {
        dim <- dim(SA)
        if (length(longitude) == dim[1] && length(latitude) == dim[2]) {
            ll <- expand.grid(longitude=as.vector(longitude), latitude=as.vector(latitude))
            longitude <- ll$longitude
            latitude <- ll$latitude
        }
    }
    l <- argfix(list(SA=SA, p=p, longitude=longitude, latitude=latitude))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_SP_from_SA",
               SA=as.double(l$SA), p=as.double(l$p), longitude=as.double(l$longitude), latitude=as.double(l$latitude),
               n=n, SP=double(n), NAOK=TRUE, package="gsw")$SP
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}

#' Freezing temperature
#'
#' Note: as of 2014-12-23, this corresponds to the Matlab function
#' called \code{gsw_t_freezing_poly}. (The confusion arises from a
#' mismatch in release version between the Matlab and C libraries.)
#' 
#' @param SA Absolute Salinity [ g/kg ]
#' @param p sea pressure [ dbar ]
#' @param saturation_fraction saturation fraction of dissolved air in seawater
#' @return in-situ freezing temperature (ITS-90) [ deg C ]
#' @examples 
#' gsw_t_freezing(34.7118, 10) # -1.902704434299200
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_t_freezing.html}
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_t_freezing_poly.html}
gsw_t_freezing <- function(SA, p, saturation_fraction=1)
{
    l <- argfix(list(SA=SA, p=p, saturation_fraction=saturation_fraction))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_t_freezing",
               SA=as.double(l$SA), p=as.double(l$p), saturation_fraction=as.double(l$saturation_fraction),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}

#' in situ temperature from Conservative Temperature
#' 
#' @param SA Absolute Salinity [ g/kg ]
#' @param CT Conservative Temperature [ deg C ]
#' @param p sea pressure [ dbar ]
#' @return in-situ temperature (ITS-90) [ deg C ]
#' @examples 
#' gsw_t_from_CT(34.7118, 28.8099, 10) # 28.785580227725703
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_t_from_CT.html}
gsw_t_from_CT <- function(SA, CT, p)
{
    l <- argfix(list(SA=SA, CT=CT, p=p))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_t_from_CT",
               SA=as.double(l$SA), CT=as.double(l$CT), p=as.double(l$p),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}

#' thermobaric coefficient (48-term equation)
#' 
#' @param SA Absolute Salinity [ g/kg ]
#' @param CT Conservative Temperature [ deg C ]
#' @param p sea pressure [ dbar ]
#' @return thermobaric coefficient wrt Conservative Temperature [ 1/(K Pa) ]
#' @examples 
#' gsw_thermobaric(34.7118, 28.8099, 10) # 1.40572143831373e-12
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_thermobaric.html}
gsw_thermobaric <- function(SA, CT, p)
{
    l <- argfix(list(SA=SA, CT=CT, p=p))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_thermobaric",
               SA=as.double(l$SA), CT=as.double(l$CT), p=as.double(l$p),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(SA))
        dim(rval) <- dim(SA)
    rval
}

#' Turner angle and density ratio
#'
#' This uses the 48-term density equation. The values of Turner Angle
#' Tu and density ratio Rrho are calculated at mid-point pressures, p_mid.
#'
#' @param SA Absolute Salinity [ g/kg ]
#' @param CT Conservative Temperature [ deg C ]
#' @param p sea pressure [ dbar ]
#' @return a list containing Tu, Rrho, and p_mid
#' @examples
#' SA = c(34.7118, 34.8915)
#' CT = c(28.8099, 28.4392)
#' p =  c(     10,      50)
#' r <- gsw_Turner_Rsubrho(SA, CT, p) # -2.064830032393999, -0.9304018848608, 30
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_Turner_Rsubrho.html}
gsw_Turner_Rsubrho <- function(SA, CT, p)
{
    l <- argfix(list(SA=SA, CT=CT, p=p))
    n <- length(l[[1]])
    r <- .C("wrap_gsw_Turner_Rsubrho",
            SA=as.double(l$SA), CT=as.double(l$CT), p=as.double(l$p),
            n=n, Tu=double(n-1), Rsubrho=double(n-1), p_mid=double(n-1))
    Tu <- r$Tu
    Rsubrho <- r$Rsubrho
    p_mid <- r$p_mid
    if (is.matrix(SA)) {
        stop("gsw_Turner_Rsubrho() cannot handle matix SA")
        ## dim(Tu) <- dim(SA)
        ## dim(Rsubrho) <- dim(SA)
        ## dim(p_mid) <- dim(SA)
    }
    list(Tu=Tu, Rsubrho=Rsubrho, p_mid=p_mid)
}

#' height from pressure (48-term equation)
#' 
#' @param p sea pressure [ dbar ]
#' @param lat latitude in decimal degrees north [ -90 ... +90 ]
#' 
#' @return height [ m ]
#' @examples
#' gsw_z_from_p(10, 4) # -9.9445831334188
#' @references
#' \url{http://www.teos-10.org/pubs/gsw/html/gsw_z_from_p.html}
gsw_z_from_p<- function(p, lat)
{
    l <- argfix(list(p=p, lat=lat))
    n <- length(l[[1]])
    rval <- .C("wrap_gsw_z_from_p",
               p=as.double(l$p), lat=as.double(l$lat),
               n=n, rval=double(n), NAOK=TRUE, package="gsw")$rval
    if (is.matrix(p))
        dim(rval) <- dim(p)
    rval
}

