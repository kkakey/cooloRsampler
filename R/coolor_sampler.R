#' Generate a color palette from https://coolors.co/
#'
#' This function grabs a randomly generated color palette
#' of 2 to 9 colors from https://coolors.co/.
#' @param ncolor Input number of colors in palette (2-9)
#' @return Hex color codes of palette.
#' @keywords coolors
#' @export
#' @import rvest
#' @import RSelenium
#' @import magrittr
#' @import scales
#' @import ggplot2
#' @examples
#' ## Generate a palette of 6 colors from https://coolors.co/
#' my_colors <- coolor_sampler(ncolor=6)
#'
#' ## View sampled colors
#' scales::show_col(my_colors, ncol = 1)
#'
#' ## Easily add the palette to your next ggplot!
#' background_col <- my_colors[1]
#' points_col <- my_colors[2:length(my_colors)]
#'
#' data("mtcars")
#' library(ggplot2)
#' ggplot(mtcars, aes(mpg, wt)) +
#'   geom_point(aes(colour = factor(cyl))) +
#'   scale_colour_manual(values = rev(points_col)) +
#'   theme(plot.background = element_rect(background_col),
#'         panel.background = element_rect(background_col),
#'         legend.background = element_rect(background_col),
#'         text = element_text(color="white"))

coolor_sampler <- function(ncolor=5) {

  print('Grabbing some colors - this might take a few seconds!')

  url = 'https://coolors.co/generate'

  exCap <- list("moz:firefoxOptions" = list(args = list('--headless')))
  rD <- RSelenium::rsDriver(browser = "firefox", port = 4567L, extraCapabilities = exCap, verbose = F)
  remDr <- rD[["client"]]
  remDr$navigate(url)
  Sys.sleep(1)
  # close initial pop-up windows
  webElem <- remDr$findElement(using = 'xpath',"/html/body/div[31]/div/div[2]/div/a")
  webElem$clickElement()

  webElem <- remDr$findElement(using = 'xpath',"/html/body/div[29]/div/div[2]/div/a[1]")
  webElem$clickElement()

  webElem <- remDr$findElement(using = 'xpath',"/html/body/div[9]/div/div[2]/div/a")
  webElem$clickElement()

  if (ncolor==5) {
    html <- remDr$getPageSource()[[1]]
    # grabs HEX color codes
    hex <- rvest::read_html(html) %>% # parse HTML
      rvest::html_nodes("div.generator_color_hex") %>%
      rvest::html_text()
  }
  else if (ncolor<5  & ncolor>1) {

    val = 5 - ncolor
    x <- 0
    while (x < val) {
      ### delete color ####
      webElem <- remDr$findElement(using = 'xpath',"/html/body/div[6]/div[3]/div[3]/div[1]/div[2]/div[3]/div[1]")
      webElem$clickElement()
      x <- x + 1
    }
    html <- remDr$getPageSource()[[1]]
    # grabs HEX color codes
    hex <- rvest::read_html(html) %>% # parse HTML
      rvest::html_nodes("div.generator_color_hex") %>%
      rvest::html_text()
  }
  else if (ncolor>5 & ncolor<10) {

    val = ncolor - 5
    x <- 0
    while (x < val) {
      ### add color ####
      # click area to get button to show up
      webElem <- remDr$findElement(using = 'css selector',"div.generator_color_bar-right")
      webElem$clickElement()
      # click button to add a color!
      webElem <- remDr$findElement(using = 'xpath','/html/body/div[6]/div[3]/div[5]/a/i')
      webElem$clickElement()
      x <- x + 1
    }
    html <- remDr$getPageSource()[[1]]
    # grabs HEX color codes
    hex <- rvest::read_html(html) %>% # parse HTML
      rvest::html_nodes("div.generator_color_hex") %>%
      rvest::html_text()
  }
  else if (ncolor<2 | ncolor > 9) {
    rD$server$stop()
    stop('Oops! Please enter a number between 3 and 9')
  }

  # add '#' to beginning of each code
  hex_full <- c()
  for (i in hex) {
    hex_full <- c(hex_full, paste0("#",i))
  }

  ### close webpage ####
  rD$server$stop()
  return(hex_full)
}
