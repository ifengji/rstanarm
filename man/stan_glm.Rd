% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/stan_glm.R, R/stan_glm.fit.R
\name{stan_glm}
\alias{stan_glm}
\alias{stan_glm.fit}
\alias{stan_glm.nb}
\title{Bayesian generalized linear models via Stan}
\usage{
stan_glm(formula, family = gaussian(), data, weights, subset,
  na.action = NULL, offset = NULL, model = TRUE, x = FALSE, y = TRUE,
  contrasts = NULL, ..., prior = normal(), prior_intercept = normal(),
  prior_aux = exponential(), prior_PD = FALSE, algorithm = c("sampling",
  "optimizing", "meanfield", "fullrank"), adapt_delta = NULL, QR = FALSE,
  sparse = FALSE)

stan_glm.nb(formula, data, weights, subset, na.action = NULL, offset = NULL,
  model = TRUE, x = FALSE, y = TRUE, contrasts = NULL, link = "log",
  ..., prior = normal(), prior_intercept = normal(),
  prior_aux = exponential(), prior_PD = FALSE, algorithm = c("sampling",
  "optimizing", "meanfield", "fullrank"), adapt_delta = NULL, QR = FALSE)

stan_glm.fit(x, y, weights = rep(1, NROW(y)), offset = rep(0, NROW(y)),
  family = gaussian(), ..., prior = normal(), prior_intercept = normal(),
  prior_aux = exponential(), prior_smooth = exponential(autoscale = FALSE),
  prior_ops = NULL, group = list(), prior_PD = FALSE,
  algorithm = c("sampling", "optimizing", "meanfield", "fullrank"),
  adapt_delta = NULL, QR = FALSE, sparse = FALSE)
}
\arguments{
\item{formula, data, subset}{Same as \code{\link[stats]{glm}}, 
but \emph{we strongly advise against omitting the \code{data}
argument}. Unless \code{data} is specified (and is a data frame) many
post-estimation functions (including \code{update}, \code{loo},
\code{kfold}) are not guaranteed to work properly.}

\item{family}{Same as \code{\link[stats]{glm}}, except negative binomial GLMs
are also possible using the \code{\link{neg_binomial_2}} family object.}

\item{na.action, contrasts}{Same as \code{\link[stats]{glm}}, but
rarely specified.}

\item{model, offset, weights}{Same as \code{\link[stats]{glm}}.}

\item{x}{In \code{stan_glm}, logical scalar indicating whether to
return the design matrix. In \code{stan_glm.fit}, usually a design matrix
but can also be a list of design matrices with the same number of rows, in
which case the first element of the list is interpreted as the primary design
matrix and the remaining list elements collectively constitute a basis for a
smooth nonlinear function of the predictors indicated by the \code{formula}
argument to \code{\link{stan_gamm4}}.}

\item{y}{In \code{stan_glm}, logical scalar indicating whether to
return the response vector. In \code{stan_glm.fit}, a response vector.}

\item{...}{Further arguments passed to the function in the \pkg{rstan} 
package (\code{\link[rstan]{sampling}}, \code{\link[rstan]{vb}}, or 
\code{\link[rstan]{optimizing}}), corresponding to the estimation method 
named by \code{algorithm}. For example, if \code{algorithm} is
\code{"sampling"} it is possibly to specify \code{iter}, \code{chains},
\code{cores}, \code{refresh}, etc.}

\item{prior}{The prior distribution for the regression coefficients. 
\code{prior} should be a call to one of the various functions provided by 
\pkg{rstanarm} for specifying priors. The subset of these functions that 
can be used for the prior on the coefficients can be grouped into several 
"families":

\tabular{ll}{
  \strong{Family} \tab \strong{Functions} \cr 
  \emph{Student t family} \tab \code{normal}, \code{student_t}, \code{cauchy} \cr 
  \emph{Hierarchical shrinkage family} \tab \code{hs}, \code{hs_plus} \cr 
  \emph{Laplace family} \tab \code{laplace}, \code{lasso} \cr
  \emph{Product normal family} \tab \code{product_normal} \cr
}

See the \link[=priors]{priors help page} for details on the families and 
how to specify the arguments for all of the functions in the table above.
To omit a prior ---i.e., to use a flat (improper) uniform prior---
\code{prior} can be set to \code{NULL}, although this is rarely a good
idea.

\strong{Note:} Unless \code{QR=TRUE}, if \code{prior} is from the Student t
family or Laplace family, and if the \code{autoscale} argument to the 
function used to specify the prior (e.g. \code{\link{normal}}) is left at 
its default and recommended value of \code{TRUE}, then the default or 
user-specified prior scale(s) may be adjusted internally based on the
scales of the predictors. See the \link[=priors]{priors help page} and the
\emph{Prior Distributions} vignette for details on the rescaling and the
\code{\link{prior_summary}} function for a summary of the priors used for a
particular model.}

\item{prior_intercept}{The prior distribution for the intercept. 
\code{prior_intercept} can be a call to \code{normal}, \code{student_t} or 
\code{cauchy}. See the \link[=priors]{priors help page} for details on 
these functions. To omit a prior on the intercept ---i.e., to use a flat
(improper) uniform prior--- \code{prior_intercept} can be set to
\code{NULL}.

\strong{Note:} If using a dense representation of the design matrix 
---i.e., if the \code{sparse} argument is left at its default value of 
\code{FALSE}--- then the prior distribution for the intercept is set so it 
applies to the value \emph{when all predictors are centered}. If you prefer
to specify a prior on the intercept without the predictors being
auto-centered, then you have to omit the intercept from the
\code{\link[stats]{formula}} and include a column of ones as a predictor,
in which case some element of \code{prior} specifies the prior on it,
rather than \code{prior_intercept}.}

\item{prior_aux}{The prior distribution for the "auxiliary" parameter (if
applicable). The "auxiliary" parameter refers to a different parameter 
depending on the \code{family}. For Gaussian models \code{prior_aux} 
controls \code{"sigma"}, the error 
standard deviation. For negative binomial models \code{prior_aux} controls 
\code{"reciprocal_dispersion"}, which is similar to the 
\code{"size"} parameter of \code{\link[stats]{rnbinom}}:
smaller values of \code{"reciprocal_dispersion"} correspond to 
greater dispersion. For gamma models \code{prior_aux} sets the prior on 
to the \code{"shape"} parameter (see e.g., 
\code{\link[stats]{rgamma}}), and for inverse-Gaussian models it is the 
so-called \code{"lambda"} parameter (which is essentially the reciprocal of
a scale parameter). Binomial and Poisson models do not have auxiliary 
parameters. 

\code{prior_aux} can be a call to \code{exponential} to 
use an exponential distribution, or \code{normal}, \code{student_t} or 
\code{cauchy}, which results in a half-normal, half-t, or half-Cauchy 
prior. See \code{\link{priors}} for details on these functions. To omit a 
prior ---i.e., to use a flat (improper) uniform prior--- set 
\code{prior_aux} to \code{NULL}.}

\item{prior_PD}{A logical scalar (defaulting to \code{FALSE}) indicating
whether to draw from the prior predictive distribution instead of
conditioning on the outcome.}

\item{algorithm}{A string (possibly abbreviated) indicating the 
estimation approach to use. Can be \code{"sampling"} for MCMC (the
default), \code{"optimizing"} for optimization, \code{"meanfield"} for
variational inference with independent normal distributions, or
\code{"fullrank"} for variational inference with a multivariate normal
distribution. See \code{\link{rstanarm-package}} for more details on the
estimation algorithms. NOTE: not all fitting functions support all four
algorithms.}

\item{adapt_delta}{Only relevant if \code{algorithm="sampling"}. See 
\code{\link{adapt_delta}} for details.}

\item{QR}{A logical scalar defaulting to \code{FALSE}, but if \code{TRUE} 
applies a scaled \code{\link{qr}} decomposition to the design matrix, 
\eqn{X = Q^\ast R^\ast}{X = Q* R*}, where \eqn{Q^\ast = Q \sqrt{n-1}}{Q* = 
Q (n-1)^0.5} and \eqn{R^\ast = \frac{1}{\sqrt{n-1}} R}{R* = (n-1)^(-0.5) 
R}. The coefficients relative to \eqn{Q^\ast}{Q*} are obtained and then 
premultiplied by the inverse of \eqn{R^{\ast}}{R*} to obtain coefficients 
relative to the original predictors, \eqn{X}. These transformations do not 
change the likelihood of the data but are recommended for computational 
reasons when there are multiple predictors. Importantly, while the columns
of \eqn{X} are almost always correlated, the columns of \eqn{Q^\ast}{Q*}
are uncorrelated by design, which often makes sampling from the posterior
easier. However, because when \code{QR} is \code{TRUE} the \code{prior}
argument applies to the coefficients relative to \eqn{Q^\ast}{Q*} (and
those are not very interpretable), setting \code{QR=TRUE} is only
recommended if you do not have an informative prior for the regression
coefficients. 

For more details see the Stan case study 
\emph{The QR Decomposition For Regression Models} at 
\url{http://mc-stan.org/users/documentation/case-studies/qr_regression.html}.}

\item{sparse}{A logical scalar (defaulting to \code{FALSE}) indicating
whether to use a sparse representation of the design (X) matrix. 
If \code{TRUE}, the the design matrix is not centered (since that would 
destroy the sparsity) and likewise it is not possible to specify both 
\code{QR = TRUE} and \code{sparse = TRUE}. Depending on how many zeros
there are in the design matrix, setting \code{sparse = TRUE} may make
the code run faster and can consume much less RAM.}

\item{link}{For \code{stan_glm.nb} only, the link function to use. See 
\code{\link{neg_binomial_2}}.}

\item{prior_smooth}{The prior distribution for the hyperparameters in GAMs,
with lower values yielding less flexible smooth functions.
 
\code{prior_smooth} can be a call to \code{exponential} to 
use an exponential distribution, or \code{normal}, \code{student_t} or 
\code{cauchy}, which results in a half-normal, half-t, or half-Cauchy 
prior. See \code{\link{priors}} for details on these functions. To omit a 
prior ---i.e., to use a flat (improper) uniform prior--- set 
\code{prior_smooth} to \code{NULL}. The number of hyperparameters depends
on the model specification but a scalar prior will be recylced as necessary
to the appropriate length.}

\item{prior_ops}{Deprecated. See \link{rstanarm-deprecated} for details.}

\item{group}{A list, possibly of length zero (the default), but otherwise
having the structure of that produced by \code{\link[lme4]{mkReTrms}} to
indicate the group-specific part of the model. In addition, this list must
have elements for the \code{regularization}, \code{concentration} 
\code{shape}, and \code{scale} components of a \code{\link{decov}}
prior for the covariance matrices among the group-specific coefficients.}
}
\value{
A \link[=stanreg-objects]{stanreg} object is returned 
for \code{stan_glm, stan_glm.nb}.

A \link[=stanfit-class]{stanfit} object (or a slightly modified 
  stanfit object) is returned if \code{stan_glm.fit} is called directly.
}
\description{
Generalized linear modeling with optional prior distributions for the
coefficients, intercept, and auxiliary parameters.
}
\details{
The \code{stan_glm} function is similar in syntax to 
  \code{\link[stats]{glm}} but rather than performing maximum likelihood 
  estimation of generalized linear models, full Bayesian estimation is 
  performed (if \code{algorithm} is \code{"sampling"}) via MCMC. The Bayesian
  model adds priors (independent by default) on the coefficients of the GLM.
  The \code{stan_glm} function calls the workhorse \code{stan_glm.fit}
  function, but it is also possible to call the latter directly.
  
  The \code{stan_glm.nb} function, which takes the extra argument 
  \code{link}, is a wrapper for \code{stan_glm} with \code{family = 
  \link{neg_binomial_2}(link)}.
}
\examples{
if (!grepl("^sparc",  R.version$platform)) {
### Linear regression
fit <- stan_glm(mpg / 10 ~ ., data = mtcars, QR = TRUE,
                algorithm = "fullrank") # for speed of example only
plot(fit, prob = 0.5)
plot(fit, prob = 0.5, pars = "beta")
}
\donttest{
### Logistic regression
head(wells)
wells$dist100 <- wells$dist / 100
fit2 <- stan_glm(
  switch ~ dist100 + arsenic, 
  data = wells, 
  family = binomial(link = "logit"), 
  prior_intercept = normal(0, 10),
  QR = TRUE,
  chains = 2, iter = 200 # for speed of example only
)
print(fit2)
prior_summary(fit2)

plot(fit2, plotfun = "areas", prob = 0.9, # ?bayesplot::mcmc_areas
     pars = c("(Intercept)", "arsenic"))
pp_check(fit2, plotfun = "error_binned")  # ?bayesplot::ppc_error_binned


### Poisson regression (example from help("glm")) 
counts <- c(18,17,15,20,10,20,25,13,12)
outcome <- gl(3,1,9)
treatment <- gl(3,3)
fit3 <- stan_glm(counts ~ outcome + treatment, family = poisson(link="log"),
                 prior = normal(0, 1), prior_intercept = normal(0, 5),
                 chains = 2, iter = 250) # for speed of example only
print(fit3)

bayesplot::color_scheme_set("green")
plot(fit3)
plot(fit3, regex_pars = c("outcome", "treatment"))
plot(fit3, plotfun = "combo", regex_pars = "treatment") # ?bayesplot::mcmc_combo

### Gamma regression (example from help("glm"))
clotting <- data.frame(log_u = log(c(5,10,15,20,30,40,60,80,100)),
                       lot1 = c(118,58,42,35,27,25,21,19,18),
                       lot2 = c(69,35,26,21,18,16,13,12,12))
fit4 <- stan_glm(lot1 ~ log_u, data = clotting, family = Gamma(link="log"),
                 chains = 2, iter = 300) # for speed of example only 
print(fit4, digits = 2)
fit5 <- update(fit4, formula = lot2 ~ log_u)

### Negative binomial regression
fit6 <- stan_glm.nb(Days ~ Sex/(Age + Eth*Lrn), data = MASS::quine, 
                    link = "log", prior_aux = exponential(1),
                    chains = 2, iter = 200) # for speed of example only

prior_summary(fit6)
bayesplot::color_scheme_set("brightblue")
plot(fit6)
pp_check(fit6, plotfun = "hist", nreps = 5)

# 80\% interval of estimated reciprocal_dispersion parameter
posterior_interval(fit6, pars = "reciprocal_dispersion", prob = 0.8)
plot(fit6, "areas", pars = "reciprocal_dispersion", prob = 0.8)
}

}
\references{
Gelman, A. and Hill, J. (2007). \emph{Data Analysis Using
  Regression and Multilevel/Hierarchical Models.} Cambridge University Press,
  Cambridge, UK. (Ch. 3-6)
}
\seealso{
\code{\link{stanreg-methods}} and 
\code{\link[stats]{glm}}.

The various vignettes for \code{stan_glm}.
}

