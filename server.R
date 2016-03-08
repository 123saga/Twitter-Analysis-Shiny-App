
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

function(input, output, session) {
    
    statuses <- reactive({
        # Change when the "update" button is pressed...
        input$update
        # ...but not for anything else
        isolate({
            withProgress({
                setProgress(message = "Gathering tweets...")
                getTweets(input$searchString, input$numTweets)
            })
        })
    })
    
    textdata <- reactive({
        # Change when the "update" button is pressed...
        input$update
        # ...but not for anything else
        #isolate({
            #withProgress({
                #setProgress(message = "Processing tweets...")
                getTextData(statuses())
            #})
        #})
    })
    
    sentiments <- reactive({
        # Change when the "update" button is pressed...
        input$update
        # ...but not for anything else
        #isolate({
            withProgress({
                setProgress(message = "Gathering sentiments...")
                sentiments <- getSentiments(textdata())
            })
        #})
    })
    
    runpca <- reactive({
        # Change when the "update" button is pressed...
        #input$update
        # ...but not for anything else
        #isolate({
            withProgress({
                setProgress(message = "Running PCA...")
                doPCA(textdata(), statuses(), sentiments())
            })
        #})
    })
    
    # Make the wordcloud drawing predictable during a session
    wordcloud_rep <- repeatable(wordcloud)
    
    output$plot <- renderPlot({
        wordcloud_rep(textdata(), scale=c(4,0.5),
                      min.freq=3, max.words=100,
                      colors=brewer.pal(8, "RdBu"), random.order=F, 
                      rot.per=0.1, use.r.layout=F)
    })
    
    output$tweetCount  <- renderText({
        paste("Number of Tweets Found: ", as.character(nrow(statuses())))
    })
    
    output$sentiment <- renderPlot({
        v <- sentiments()
        emotions <- data.frame("count"=colSums(v[,c(1:8)]))
        emotions <- cbind("sentiment" = rownames(emotions), emotions)
        ggplot(data = emotions, aes(x = sentiment, y = count)) +
            geom_bar(aes(fill = sentiment), stat = "identity") +
            xlab("Sentiment") + ylab("Total Count") + 
            scale_fill_brewer(palette='RdBu') + 
            theme_bw() + theme(legend.position='none')
    })
    
    output$pcaplot <- renderPlot({
        df <- runpca()

        ggplot(df, aes_string(x=input$xvar, y=input$yvar)) + 
            geom_point(aes_string(fill=input$colvar), size=4, alpha=0.7, pch=21, stroke=1.3) + 
            scale_fill_gradientn(colours = brewer.pal(10,"RdBu")) + theme_bw()
        
    })
    
    output$tweet_table <- DT::renderDataTable({
        df <- runpca()
        text <- df$text
        pc <- df[,input$pc]
        
        cuts <- cut(pc, 10)
        temp <- data.frame(text=text, pc=pc, pc_val=cuts)
        temp <- temp %>%
            group_by(pc_val) %>%
            summarise(text=iconv(sample(text,1), to='UTF-8-MAC', sub='byte')) %>%
            filter(!is.na(pc_val))
        
        DT::datatable(temp)
    })
}