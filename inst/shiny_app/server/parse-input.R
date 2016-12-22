parse_input <- function(data, var, dpcomma, filename, sheetname=NULL) {
    data_list <- list()

    # For Excel files, combine the file and sheet names
    if (!is.null(sheetname)) {
        filename <- paste0(filename, "!", sheetname)
    }
    data_list$filename <- filename

    # Identify the layout of the table: look at data[1, 2]. If it is a
    # variable name, then the layout is entirely in columns. Otherwise,
    # there are scalar variables in the top rows.
    if (!trimws(data[1, 2]) %in% var) {
        # Look for scalar variables in the top rows
        i <- 1
        while (i <= nrow(data)) {
            if (trimws(data[i, 1]) == var$average) {
                if (dpcomma) {
                    data[i, 2] <- gsub(",", ".", data[i, 2])
                }
                data_list$average <- as.numeric(data[i, 2])
            } else if (trimws(data[i, 1]) == var$year) {
                if (dpcomma) {
                    data[i, 2] <- gsub(",", ".", data[i, 2])
                }
                data_list$year <- as.numeric(data[i, 2])
            } else if (trimws(data[i, 1]) == var$country) {
                data_list$country <- data[i, 2]
            } else if (trimws(data[i, 1]) == var$component) {
                data_list$component <- data[i, 2]
            } else if (trimws(data[i, 1]) == var$popsize) {
                if (dpcomma) {
                    data[i, 2] <- gsub(",", ".", data[i, 2])
                }
                data_list$popsize <- as.numeric(data[i, 2])
            } else if (trimws(data[i, 1]) == var$gumbel) {
                if (dpcomma) {
                    data[i, 2] <- gsub(",", ".", data[i, 2])
                }
                data_list$gumbel <- as.numeric(data[i, 2])
            } else {
                # We've reached the end of the top rows
                break
            }
            i <- i + 1
        }
        # Remove the top rows and analyse the rest of table
        names <- sapply(data[i, ], trimws)
        data <- data[-c(1:i), ]
        colnames(data) <- names
    } else {
        names <- sapply(data[1, ], trimws)
        data <- data[-1, ]
        colnames(data) <- names
    }

    # Look for percentiles and use that column to identify and remove empty rows
    if (var$p %in% colnames(data)) {
        if (dpcomma) {
            data[, var$p] <- gsub(",", ".", data[, var$p])
        }
        data[, var$p] <- as.numeric(data[, var$p])
        data <- data[!is.na(data[, var$p]), ]
        data_list$p <- data[, var$p]
    } else {
        return(simpleError("fractiles are missing"))
    }

    # Look for the year, country and component
    if (var$year %in% colnames(data)) {
        data_list$year <- as.numeric(data[1, var$year])
        # If the year does not take the form of a number
        if (is.na(data_list$year)) {
            data_list$year <- data[1, var$year]
        }
    }
    if (var$country %in% colnames(data)) {
        data_list$country <- data[1, var$country]
    }
    if (var$component %in% colnames(data)) {
        data_list$component <- data[1, var$component]
    }

    # Look for the population size
    if (var$popsize %in% colnames(data)) {
        if (dpcomma) {
            data[, var$popsize] <- gsub(",", ".", data[, var$popsize])
        }
        data[, var$popsize] <- as.numeric(data[, var$popsize])
        data_list$popsize <- data[1, var$popsize]
    }

    # Look for Gumbel parameter
    if (var$gumbel %in% colnames(data)) {
        if (dpcomma) {
            data[, var$gumbel] <- gsub(",", ".", data[, var$gumbel])
        }
        data[, var$gumbel] <- as.numeric(data[, var$gumbel])
        data_list$gumbel <- data[1, var$gumbel]
    }

    # Look for the average
    if (var$average %in% colnames(data)) {
        if (dpcomma) {
            data[, var$average] <- gsub(",", ".", data[, var$average])
        }
        data[, var$average] <- as.numeric(data[, var$average])
        data_list$average <- data[1, var$average]
    }

    # Look for the thresholds
    if (var$q %in% colnames(data)) {
        if (dpcomma) {
            data[, var$q] <- gsub(",", ".", data[, var$q])
        }
        data[, var$q] <- as.numeric(data[, var$q])
        if (anyNA(data[, var$q])) {
            return(simpleError("thresholds contain missing values"))
        }
        data_list$threshold <- data[, var$q]
    } else {
        return(simpleError("no data on thresholds"))
    }

    # Look for the averages/shares
    if (var$bracketshare %in% colnames(data)) {
        if (dpcomma) {
            data[, var$bracketshare] <- gsub(",", ".", data[, var$bracketshare])
        }
        data[, var$bracketshare] <- as.numeric(data[, var$bracketshare])
        if (anyNA(data[, var$bracketshare])) {
            return(simpleError("bracket shares contain missing values"))
        }
        data_list$whichavgsh <- "bracketshare"
        data_list$bracketshare <- data[, var$bracketshare]
    } else if (var$topshare %in% colnames(data)) {
        if (dpcomma) {
            data[, var$topshare] <- gsub(",", ".", data[, var$topshare])
        }
        data[, var$topshare] <- as.numeric(data[, var$topshare])
        if (anyNA(data[, var$topshare])) {
            return(simpleError("top shares contain missing values"))
        }
        data_list$whichavgsh <- "topshare"
        data_list$topshare <- data[, var$topshare]
    } else if (var$bracketavg %in% colnames(data)) {
        if (dpcomma) {
            data[, var$bracketavg] <- gsub(",", ".", data[, var$bracketavg])
        }
        data[, var$bracketavg] <- as.numeric(data[, var$bracketavg])
        if (anyNA(data[, var$bracketavg])) {
            return(simpleError("bracket averages contain missing values"))
        }
        data_list$whichavgsh <- "bracketavg"
        data_list$bracketavg <- data[, var$bracketavg]
    } else if (var$topavg %in% colnames(data)) {
        if (dpcomma) {
            data[, var$topavg] <- gsub(",", ".", data[, var$topavg])
        }
        data[, var$topavg] <- as.numeric(data[, var$topavg])
        if (anyNA(data[, var$topavg])) {
            return(simpleError("top averages contain missing values"))
        }
        data_list$whichavgsh <- "topavg"
        data_list$topavg <- data[, var$topavg]
    } else if (var$b %in% colnames(data)) {
        if (dpcomma) {
            data[, var$b] <- gsub(",", ".", data[, var$b])
        }
        data[, var$b] <- as.numeric(data[, var$b])
        if (anyNA(data[data_list$p != 0, var$b])) {
            return(simpleError("inverted Pareto coefficients contain missing values"))
        }
        data_list$whichavgsh <- "invpareto"
        data_list$invpareto <- data[, var$b]
    } else {
        return(simpleError("no data on shares/averages/inverted Pareto coefficients"))
    }

    # Look for single/couple share
    if (var$singlebracket %in% colnames(data)) {
        if (dpcomma) {
            data[, var$singlebracket] <- gsub(",", ".", data[, var$singlebracket])
        }
        data[, var$singlebracket] <- as.numeric(data[, var$singlebracket])
        if (anyNA(data[, var$singlebracket])) {
            return(simpleError("single shares contain missing values"))
        }
        data_list$whichcouple <- "singlebracket"
        data_list$singlebracket <- data[, var$singlebracket]
    } else if (var$couplebracket %in% colnames(data)) {
        if (dpcomma) {
            data[, var$couplebracket] <- gsub(",", ".", data[, var$couplebracket])
        }
        data[, var$couplebracket] <- as.numeric(data[, var$couplebracket])
        if (anyNA(data[, var$couplebracket])) {
            return(simpleError("single shares contain missing values"))
        }
        data_list$whichcouple <- "couplebracket"
        data_list$couplebracket <- data[, var$couplebracket]
    } else if (var$singletop %in% colnames(data)) {
        if (dpcomma) {
            data[, var$singletop] <- gsub(",", ".", data[, var$singletop])
        }
        data[, var$singletop] <- as.numeric(data[, var$singletop])
        if (anyNA(data[, var$singletop])) {
            return(simpleError("couple shares contain missing values"))
        }
        data_list$whichcouple <- "singletop"
        data_list$singletop <- data[, var$singletop]
    } else if (var$coupletop %in% colnames(data)) {
        if (dpcomma) {
            data[, var$coupletop] <- gsub(",", ".", data[, var$coupletop])
        }
        data[, var$coupletop] <- as.numeric(data[, var$coupletop])
        if (anyNA(data[, var$coupletop])) {
            return(simpleError("couple shares contain missing values"))
        }
        data_list$whichcouple <- "coupletop"
        data_list$coupletop <- data[, var$coupletop]
    }
    # Overall share
    if (var$singleshare %in% colnames(data)) {
        if (dpcomma) {
            data[, var$singleshare] <- gsub(",", ".", data[, var$singleshare])
        }
        data[, var$singleshare] <- as.numeric(data[, var$singleshare])
        data_list$singleshare <- data[1, var$singleshare]
    } else if (var$coupleshare %in% colnames(data)) {
        if (dpcomma) {
            data[, var$coupleshare] <- gsub(",", ".", data[, var$coupleshare])
        }
        data[, var$coupleshare] <- as.numeric(data[, var$coupleshare])
        data_list$coupleshare <- data[1, var$coupleshare]
    }

    if (is.na(data_list$average) | is.null(data_list$average)) {
        return(simpleError("average is missing"))
    }
    if (is.null(data_list$year)) {
        data_list$year <- "n/a"
    } else if (is.na(data_list$year)) {
        data_list$year <- "n/a"
    }
    if (is.null(data_list$country)) {
        data_list$country <- "n/a"
    } else if (is.na(data_list$country)) {
        data_list$country <- "n/a"
    }
    if (is.null(data_list$component)) {
        data_list$component <- "n/a"
    } else if (is.na(data_list$component)) {
        data_list$component <- "n/a"
    }
    if (is.null(data_list$popsize)) {
        data_list$popsize <- NA
    }
    if (is.null(data_list$gumbel)) {
        data_list$gumbel <- NA
    }

    return(data_list)
}