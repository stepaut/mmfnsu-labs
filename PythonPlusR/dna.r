

################################

ID <- "sample"

directory <- getwd()
df <- read.csv(paste0(directory, "\\datasets\\dna.csv"), colClasses = c("character", rep("numeric", 30)))

#print(df)

# 1.1

poss <- list()

for (i in 1:nrow(df)){
    sample <- df[i, ID]
    sample <- strsplit(as.character(sample), "")[[1]]
    l <- length(sample)
    pos <- as.integer(rep("2", l))
    pos[1:l] <- as.integer(sample)
    poss <- c(poss, list(pos))
}


df_wos <- df[, 2:ncol(df)]

poss <- do.call(rbind, poss)
poss <- replace(poss, poss == 2, NA)
df_wos_wp <- cbind(poss, df_wos)


pacients_cols <- colnames(df_wos)
pacient_vals <- list()

for (pacient in pacients_cols) {
    pacient_val <- c()
    for (pos in 1:20) {
        pacient_val <- c(
            pacient_val,
            sum(as.numeric(as.character(df_wos_wp[, pos])) * as.numeric(as.character(df_wos_wp[, pacient])), na.rm = TRUE) / sum(as.numeric(as.character(df_wos_wp[, pacient]))[!is.na(as.numeric(as.character(df_wos_wp[, pos])))], na.rm = TRUE)
        )
    }
    pacient_vals <- c(pacient_vals, list(pacient_val))
}

pacient_vals <- matrix(unlist(pacient_vals), nrow = length(pacients_cols), byrow = TRUE)

#print(pacients_feachs)

# 1.2

count_pair <- function(data, i, j) {
    patterns <- c("11", "01", "10", "00")
    data_p <- data[!is.na(data[[i]]), ]
    data_p <- data_p[!is.na(data_p[[j]]), ]
    i_col <- as.character(data_p[[i]])
    j_col <- as.character(data_p[[j]])
    pair_col <- paste0(i_col, j_col)
    res <- list()
    for (p in patterns) {
        res <- c(res, list(as.integer(pair_col == p)))
    }
    return(do.call(rbind, res))
}

pairs <- list()

for (i in 1:20) {
    for (j in 1:20) {
        if (i != j) {
            pairs <- c(pairs, list(c(i, j)))
        }
    }
}

pacient_pair_vals <- list()
col_names <- c()

for (pair in pairs) {
    counts <- count_pair(df_wos_wp, pair[1], pair[2])
    pacient_pair_val <- list()

    for (pacient in pacients_cols) {
        div <- sum(as.numeric(df_wos_wp[[pacient]]))
        k <- 1
        feach <- list()

        for (p in 1:4) {
            feach <- c(feach, sum(as.numeric(counts[p, ]) * as.numeric(df_wos_wp[[pacient]])) / div)
            k <- k + 1
        }

        pacient_pair_val <- c(pacient_pair_val, list(feach))
    }

    pacient_pair_vals <- c(pacient_pair_vals, list(pacient_pair_val))
}

pacient_pair_vals_matrix <- array(NA, dim = c(length(pacients_cols), length(pairs), 4))

for (i in 1:length(pairs)) {
    for (j in 1:length(pacients_cols)) {
        for (k in 1:4) {
            pacient_pair_vals_matrix[j, i, k] <- pacient_pair_vals[[i]][[j]][[k]]
        }
    }
}

aaa <- aperm(pacient_pair_vals_matrix, c(1, 3, 2))
pacient_pair_vals <- matrix(aaa, nrow = 30, ncol = 1520, byrow = FALSE)

#print(pacients_feachs2)

# 1.3

all_vals <- cbind(pacient_vals, pacient_pair_vals)
logged_vals <- log(all_vals)
dim(logged_vals)

print(logged_vals)