#' Generate a color palette from https://coolors.co/
#'
#' This function grabs a randomly generated color palette
#' from https://coolors.co/ and returns a continuous or discrete
#' palette of the desired length to the user.
#' @param ncolor Number of colors to have in palette.
#' @param type Type of palette: continuous or discrete. Default is discrete.
#' @return Hex color codes of palette.
#' @keywords coolors
#' @export
#' @import rvest
#' @import RSelenium
#' @import magrittr
#' @import scales
#' @import ggplot2
#' @import grDevices
#' @examples
#' ## Generate a palette of 6 colors from https://coolors.co/
#' my_colors <- coolor_sampler(ncolor=6)
#' ## View sampled colors
#' scales::show_col(my_colors, ncol = 1)
#'
#' ## Easily add the palette to your next ggplot!
#' library(ggplot2)
#' ggplot(mtcars, aes(mpg, wt)) +
#'   geom_point(aes(colour = factor(cyl))) +
#'   scale_colour_manual(values = coolor_sampler(ncolor=5))

coolor_sampler <- function(ncolor=5, type = "discrete") {

  print('Grabbing some colors - this will take just a few seconds!')

  url = 'https://coolors.co/generate'

  exCap <- list("moz:firefoxOptions" = list(args = list('--headless')))
  rD <- RSelenium::rsDriver(browser = "firefox", port = netstat::free_port(random = TRUE), extraCapabilities = exCap, verbose = F)
  remDr <- rD[["client"]]
  remDr$navigate(url)
  Sys.sleep(1)

  # close initial pop-up windows
  tryCatch({
    webElem <- remDr$findElement(using = 'css selector',"#whats-new > div:nth-child(1) > div:nth-child(2) > div:nth-child(1) > a:nth-child(1)")
    webElem$clickElement()

    webElem <- remDr$findElement(using = 'css selector',"#generator-tutorial-intro_begin-btn")
    webElem$clickElement()

    webElem <- remDr$findElement(using = 'css selector',"#generator-tutorial_steps > a:nth-child(2)")
    webElem$clickElement()
  }, error = function(e){
    rD$server$stop()
  })

  if ((type == "discrete" & ncolor==5) | type == "continuous") {
    html <- remDr$getPageSource()[[1]]
    # grabs HEX color codes
    hex <- rvest::read_html(html) %>%
      rvest::html_nodes("div.generator_color_hex") %>%
      rvest::html_text()
  }
  else if (type == "discrete" && (ncolor<5  & ncolor>1)) {
    val = 5 - ncolor
    x <- 0
    while (x < val) {
      ### delete color ####
      webElem <- remDr$findElement(using = 'css selector','div.generator_color:nth-child(1) > div:nth-child(2) > div:nth-child(3) > div:nth-child(1)')
      webElem$clickElement()
      x <- x + 1
    }
    html <- remDr$getPageSource()[[1]]
    # grabs HEX color codes
    hex <- rvest::read_html(html) %>%
      rvest::html_nodes("div.generator_color_hex") %>%
      rvest::html_text()
  }
  else if (type == "discrete" && (ncolor>5 & ncolor<10)) {
    val = ncolor - 5
    x <- 0
    while (x < val) {
      ### add color ####
      # click area to get button to show up
      webElem <- remDr$findElement(using = 'css selector',"div.generator_color_bar-right")
      webElem$clickElement()
      # click button to add a color!
      webElem <- remDr$findElement(using = 'css selector','#generator_add-btn_1')
      webElem$clickElement()
      x <- x + 1
    }
    html <- remDr$getPageSource()[[1]]
    # grabs HEX color codes
    hex <- rvest::read_html(html) %>%
      rvest::html_nodes("div.generator_color_hex") %>%
      rvest::html_text()
  }
  else if (type == "discrete" && (ncolor<2 | ncolor > 9)) {
    rD$server$stop()
    stop(paste0('Oops! Please enter a number between 3 and 9 for a discrete color palette.',
        'Otherwise specify `type = "continuous"` for a continuous palette'))
  }

  # add '#' to beginning of each code
  hex_full <- c()
  for (i in hex) {
    hex_full <- c(hex_full, paste0("#",i))
  }

  if (type == "continuous") {
    hex_full <- grDevices::colorRampPalette(hex_full)(ncolor)
  }

  ### close webpage ####
  rD$server$stop()
  return(hex_full)
}
