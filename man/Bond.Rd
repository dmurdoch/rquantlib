\name{Bond}
\alias{Bond}
\alias{plot.Bond}
\alias{print.Bond}
\alias{print.FixedRateBond}
\alias{summary.Bond}
\title{Base class for Bond price evalution}
\description{
  This class forms the basis from which the more specific classes are
  derived. }
\usage{
\method{print}{Bond}(x, digits=5, ...)
\method{print}{FixedRateBond}(x, digits=5, ...)
\method{plot}{Bond}(x, ...)
\method{summary}{Bond}(object, digits=5, ...)
}
\arguments{
  \item{x}{Any Bond object derived from this base class} 
  \item{object}{Any Bond object derived from this base class} 
  \item{digits}{Number of digits of precision shown} 
  \item{...}{Further arguments} 
}
\value{
  None, but side effects of displaying content.
}
\details{
         Please see any decent Finance textbook for background reading, and the
  \code{QuantLib} documentation for details on the \code{QuantLib}
  implementation.  
}
\references{\url{https://www.quantlib.org/} for details on \code{QuantLib}.}
\author{Khanh Nguyen \email{knguyen@cs.umb.edu}; Dirk Eddelbuettel \email{edd@debian.org} for the \R interface;
  the QuantLib Group for \code{QuantLib}}
\note{The interface might change in future release as \code{QuantLib}
  stabilises its own API.}

\examples{

## This data is taken from sample code shipped with QuantLib 0.9.7
## from the file Examples/Swap/swapvaluation
params <- list(tradeDate=as.Date('2004-09-20'),
               settleDate=as.Date('2004-09-22'),
               dt=.25,
               interpWhat="discount",
               interpHow="loglinear")
setEvaluationDate(as.Date("2004-09-20"))

## We got numerical issues for the spline interpolation if we add
## any on of these three extra futures, at least with QuantLib 0.9.7
## The curve data comes from QuantLib's Examples/Swap/swapvaluation.cpp
## Removing s2y helps, as kindly pointed out by Luigi Ballabio
tsQuotes <- list(d1w = 0.0382,
                 d1m = 0.0372,
                 fut1=96.2875,
                 fut2=96.7875,
                 fut3=96.9875,
                 fut4=96.6875,
                 fut5=96.4875,
                 fut6=96.3875,
                 fut7=96.2875,
                 fut8=96.0875,
                 # s2y = 0.037125,  ## s2y perturbs
                 s3y = 0.0398,
                 s5y = 0.0443,
                 s10y = 0.05165,
                 s15y = 0.055175)
times <- seq(0,10,.1)

setEvaluationDate(params$tradeDate)
discountCurve <- DiscountCurve(params, tsQuotes, times)

# price a zero coupon bond
bondparams <- list(faceAmount=100, issueDate=as.Date("2004-11-30"),
                   maturityDate=as.Date("2008-11-30"), redemption=100 )
dateparams <-list(settlementDays=1,
                  calendar="UnitedStates/GovernmentBond",
                  businessDayConvention=4)
ZeroCouponBond(bondparams, discountCurve, dateparams)

# price a fixed rate coupon bond

bond <- list(settlementDays=1, issueDate=as.Date("2004-11-30"),
             faceAmount=100, dayCounter='Thirty360',
             paymentConvention='Unadjusted')
schedule <- list(effectiveDate=as.Date("2004-11-30"),
                 maturityDate=as.Date("2008-11-30"),
                 period='Semiannual',
                 calendar='UnitedStates/GovernmentBond',
                 businessDayConvention='Unadjusted',
                 terminationDateConvention='Unadjusted',
                 dateGeneration='Forward',
                 endOfMonth=1)
calc=list(dayCounter='Actual360', compounding='Compounded',
          freq='Annual', durationType='Modified')
rates <- c(0.02875)
FixedRateBond(bond, rates, schedule, calc, discountCurve=discountCurve)

# price a fixed rate coupon bond from yield

yield <- 0.050517
FixedRateBond(bond, rates, schedule, calc, yield=yield)

# calculate the same bond from the clean price

price <- 92.167
FixedRateBond(bond, rates, schedule, calc, price=price)

# price a floating rate bond
bondparams <- list(faceAmount=100, issueDate=as.Date("2004-11-30"),
                   maturityDate=as.Date("2008-11-30"), redemption=100, 
                   effectiveDate=as.Date("2004-12-01"))

dateparams <- list(settlementDays=1, calendar="UnitedStates/GovernmentBond",
                   dayCounter = 1, period=3, businessDayConvention = 1,
                   terminationDateConvention=1, dateGeneration=0, endOfMonth=0,
                   fixingDays = 1)

gearings <- spreads <- caps <- floors <- vector()

iborCurve <- DiscountCurve(params,list(flat=0.05), times)
ibor <- list(type="USDLibor", length=6, inTermOf="Month", 
             term=iborCurve)
FloatingRateBond(bondparams, gearings, spreads, caps, floors, 
                 ibor, discountCurve, dateparams)
}
\keyword{misc}

