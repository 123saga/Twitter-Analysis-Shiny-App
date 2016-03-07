
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

pcalist <- c('PC1','PC2','PC3','PC4','PC5')
numChoices <- c(1000, 2000, 3000, 4000, 5000)
colChoices <- c('positivity','anger','anticipation','disgust','fear','joy',
                'sadness','surprise','trust')

shinyUI(
    navbarPage("Twitter Analysis",
               tabPanel("Load Tweets",
                        fluidPage(
                            sidebarLayout(
                                # Sidebar with a slider and selection inputs
                                sidebarPanel(
                                    # Text box
                                    textInput("searchString",
                                              "Search Twitter for:",
                                              "Microsoft"),
                                    selectInput("numTweets", "Number of Tweets:",
                                                choices = numChoices),
                                    actionButton("update", "Search")
                                ),
                                mainPanel(plotOutput("plot"),
                                          verbatimTextOutput("tweetCount")
                                          )
                            )
                        )),
               tabPanel("Sentiments",
                        fluidPage(
                            titlePanel("Sentiment Analysis"),
                            mainPanel(plotOutput("sentiment"))
                        )),
               tabPanel("PCA",
                        fluidPage(
                            titlePanel("Principal Component Analysis"),
                            sidebarPanel(
                                selectInput('xvar', 'X Variable', pcalist),
                                selectInput('yvar', 'Y Variable', pcalist,
                                            selected=pcalist[2]),
                                selectInput('colvar','Color',colChoices, selected=colChoices[1])
                            ),
                            mainPanel(plotOutput("pcaplot"))
                        )),
               tabPanel("Sample Tweets",
                        fluidPage(
                            sidebarPanel(
                                selectInput('pc','Component to Consider:', pcalist)
                            ),
                            mainPanel(DT::dataTableOutput('tweet_table'))
                        ))
    )
)

