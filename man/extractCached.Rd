% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extractCached.R
\name{extractCached}
\alias{extractCached}
\title{Extract cached objects}
\usage{
extractCached(path, chunk, objects, envir = topenv(parent.frame()))
}
\arguments{
\item{path}{String containing the path to the donor Rmarkdown file.}

\item{chunk}{String containing the name of the requested chunk.}

\item{objects}{Character vector containing variable names for one or more objects to be extracted.}

\item{envir}{Environment where the loaded objects should be stored.}
}
\value{
Variables with names \code{objects} are created in \code{envir}.
A markdown chunk (wrapped in a collapsible element) is printed that contains all commands needed to generate those objects, 
based on the code in the named chunks of the donor Rmarkdown file.
}
\description{
Extract specific R objects from the knitr cache of a previously compiled Rmarkdown file (the \dQuote{donor})
so that it can be used in the compilation process of another Rmarkdown file (the \dQuote{acceptor}).
}
\details{
Each R object is extracted in its state at the requested \code{chunk} and inserted into \code{envir}.
Note that the object does not have to be generated or even referenced in \code{chunk},
provided it was generated in a previous chunk.

The parser in this function is rather limited,
so the donor Rmarkdown file is subject to several constraints:
\itemize{
\item All chunks involved in generating the requested objects (indirectly or otherwise) should be named.
\item All named chunks should be executed; \code{eval=FALSE} is not respected.
\item All relevant code occurs within triple backticks, i.e., any inline code should be read-only.
}

Unnamed chunks are allowed but cannot be referenced and will not be shown in the output of this function.
This should not be used for code that might affect variables in the named chunks,
i.e., code in unnamed chunks should be \dQuote{read-only} with respect to variables in the named chunks.
Chunks with names starting with \code{unref-} are considered to be the same as unnamed chunks and will be ignored;
this is useful for figure-generating chunks that need to be referenced inside the donor report.

Obviously, this entire process assumes that donor report has already been compiled with \code{cache=TRUE}.
If not, \code{extractCached} will compile it (and thus generate the cache) using \code{\link{compileChapter}}.
}
\examples{
# Mocking up an Rmarkdown report.
donor <- tempfile(fileext=".Rmd")
write(file=donor, "```{r some-monsters}
destoroyah <- 1
mecha.king.ghidorah <- 2
```
                                                                
```{r more-monsters}
space.godzilla <- 3
```

```{r}
msg <- 'I am not referenced.'
```

```{r unref-figure}
plot(1, 1, main='I am also not referenced.')
```

```{r even-more-monsters}
megalon <- 4
```")

# Extracting stuff from it in another report.
acceptor <- tempfile(fileext=".Rmd")
dpb <- deparse(basename(donor))
write(file=acceptor, sprintf("```{r, echo=FALSE, results='asis'}
chapterPreamble()
```
                                                                
```{r, results='asis', echo=FALSE}
extractCached(\%s, chunk='more-monsters', 
   objects=c('space.godzilla', 'destoroyah'))
```

```{r}
space.godzilla * destoroyah
```

```{r, results='asis', echo=FALSE}
extractCached(\%s, chunk='even-more-monsters', 
   objects=c('megalon', 'mecha.king.ghidorah'))
```

```{r}
mecha.king.ghidorah * megalon
```", dpb, dpb))

rmarkdown::render(acceptor)

if (interactive()) browseURL(sub(".Rmd$", ".html", acceptor))

}
\seealso{
\code{\link{setupHTML}} and \code{\link{chapterPreamble}}, to set up the code for the collapsible element.

\code{\link{compileChapter}}, to compile a Rmarkdown report to generate the cache.
}
\author{
Aaron Lun
}
