

################################

ID <- "sample"

directory <- getwd()
df <- read.csv(paste0(directory, "\\datasets\\dna.csv"), colClasses = c(ID = "character"))

df <- df[, 1:5]
df <- df[1:10, ]

print(df)

poses <- vector("list", 0)

for (sample in df[ID]) {
    sample <- as.list(as.character(sample))
    base <- rep(2, 20)
    l <- length(sample)
    base[1:l] <- sample
    poses <- c(poses, base)
}


data1 <- df[, 2:ncol(df)] # df_wos = df_wo_samples

poses <- as.data.frame(poses)
poses <- replace(poses, poses == 2, NA)
data2 <- cbind(poses, data1) # df_wos_with_poses
data2 <- as.data.frame(data2)

pacients_cols <- colnames(df)[2:ncol(df)]
pacients_feachs <- vector("list", 0)

for (pacient in pacients_cols) {
    pacient_feachs <- vector("list", 0)
    for (pos in 1:20) {
        pacient_feachs <- c(
            pacient_feachs,
            (as.numeric(unlist(data2[pos])) * as.numeric(unlist(data2[pacient]))) / sum(data2[pacient], na.rm = TRUE)
        )
    }
    pacients_feachs <- c(pacients_feachs, pacient_feachs)
}

print(pacients_feachs)