

drop_dup <- function(data) {
    df2 <- data[!duplicated(data), ]
    return(df2)
}

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

    data_new <- drop_dup(data)

    print("DD:")
    print(data_new)

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


#########################################

df <- data.frame(
    fs = c(100, 90, NaN, 95, 1, 56),
    ss = c(30, NaN, 45, 56, -11111, 56),
    ts = c(52, 1240, 80, 98, 1, 56),
    ffs = c(NaN, NaN, NaN, 65, 1, 56),
    STRS = c("52", "40", "40", "", "aaa", 56),
    stringsAsFactors = FALSE
)


directory <- getwd()
path <- paste(directory, "\\datasets\\avocado1.csv", sep = "")

# df <- read.csv(path)

path_to_save <- paste(directory, "\\temp\\dc.csv", sep = "")

df_new <- clean_data(df, path_to_save, 1, 0.25, 1)