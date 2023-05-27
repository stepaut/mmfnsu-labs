library(ggplot2)

remove_ejections <- function(df, iqr_coef, ejection_type) {
    iqr_upper <- function(x, coef) {
        median <- median(x)
        Q1 <- quantile(x, probs = .25)
        Q3 <- quantile(x, probs = .75)
        iqr <- Q3 - Q1

        upper_limit <- median + (iqr * coef)

        return(x > upper_limit)
    }

    iqr_lower <- function(x, coef) {
        median <- median(x)
        Q1 <- quantile(x, probs = .25)
        Q3 <- quantile(x, probs = .75)
        iqr <- Q3 - Q1

        lower_limit <- median - (iqr * coef)

        return(x < lower_limit)
    }

    hampel_upper <- function(x) {
        median <- median(x)
        difference <- abs(median - x)
        difference_median <- median(difference)

        upper_limit <- median + 3 * difference_median

        return(x > upper_limit)
    }

    hampel_lower <- function(x) {
        median <- median(x)
        difference <- abs(median - x)
        difference_median <- median(difference)

        lower_limit <- median - 3 * difference_median

        return(x < lower_limit)
    }

    for (col in names(df)) {
        if (is.numeric(df[[col]])) {
            if (ejection_type == 1) {
                df[iqr_lower(df[[col]], iqr_coef), col] <- min(df[!(iqr_lower(df[[col]], iqr_coef) | iqr_upper(df[[col]], iqr_coef)), col]) # nolint
                df[iqr_upper(df[[col]], iqr_coef), col] <- max(df[!(iqr_lower(df[[col]], iqr_coef) | iqr_upper(df[[col]], iqr_coef)), col]) # nolint
            } else if (ejection_type == 2) {
                df[hampel_lower(df[[col]]), col] <- min(df[!(hampel_lower(df[[col]]) | hampel_upper(df[[col]])), col]) # nolint
                df[hampel_upper(df[[col]]), col] <- max(df[!(hampel_upper(df[[col]]) | hampel_upper(df[[col]])), col]) # nolint
            }
        }
    }

    return(df)
}

fix_skipped <- function(data, nan_crit_val) {
    len <- length(names(data))
    drop <- list()
    for (i in 1:len) {
        if (is.numeric(data[[i]])) {
            nan_len <- length(data[, i][is.na(data[, i])])
            len_of_col <- length(data[, i])
            if (nan_len > len_of_col * nan_crit_val) {
                drop <- c(drop, names(data)[i])
            } else {
                data[, i][is.na(data[, i])] <- mean(data[, i], na.rm = T)
            }
        } else {
            nan_len <- length(data[, i][data[, i] == ""])
            len_of_col <- length(data[, i])
            if (nan_len > len_of_col * nan_crit_val) {
                drop <- c(drop, names(data)[i])
            } else {
                f <- factor(data[, i])
                data[, i][(data[, i]) == ""] <- levels(f)[2]
            }
        }
    }

    data <- data[, !(names(data) %in% drop)]
    return(data)
}

clean_data <- function(
    data,
    path_to_save,
    ejection_type = 1,
    nan_crit_val = 0.25,
    iqr_coef = 1) {
    print("START")
    print(data)

    data_new <- data[!duplicated(data), ]

    data_new <- fix_skipped(data_new, nan_crit_val)

    print("FIX SKIPPED:")
    print(data_new)

    data_new <- remove_ejections(data_new, iqr_coef, ejection_type)

    print("REMOVE EJECTIONS:")
    print(data_new)
    print("END")

    write.csv(data_new, path_to_save, row.names = FALSE)

    return(data_new)
}


draw_hists <- function(data1, data2, col) {
    if (is.numeric(data1[, col])) {
        # ggplot(data = data2) +
        #     geom_histogram(mapping = aes(x = data2[, col]), bins = 4)

        blue <- rgb(0, 0, 1, alpha = 0.5)
        red <- rgb(1, 0, 0, alpha = 0.5)

        width <- (max(data1[, col]) - min(data1[, col])) / 10
        count2 <- (max(data2[, col]) - min(data2[, col])) / width

        hist(data1[, col], prob = TRUE, col = blue, breaks = 9)
        hist(data2[, col], prob = TRUE, col = red, breaks = count2 - 1, add = TRUE)
        legend("topright",
            legend = c("old", "new"),
            col = c(blue, red),
            pch = 15
        )
    }
}

#########################################

df <- data.frame(
    fs = c(100, 90, NaN, 95, 1, 56, 56),
    ss = c(30, NaN, 45, 56, -11111, 56, 56),
    ts = c(52, 1240, 80, 98, 1, 56, 56),
    ffs = c(NaN, NaN, NaN, 65, 1, 56, 56),
    STRS = c("52", "40", "40", "", "aaa", 56, 56),
    stringsAsFactors = FALSE
)


directory <- getwd()
path <- paste(directory, "\\datasets\\avocado1.csv", sep = "")

df <- read.csv(path)

path_to_save <- paste(directory, "\\temp\\dc.csv", sep = "")

df_new <- clean_data(df, path_to_save, 1, 0.25, 1)

draw_hists(df, df_new, "AveragePrice")
