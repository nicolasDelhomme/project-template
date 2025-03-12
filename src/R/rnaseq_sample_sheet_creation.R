library(here)
files<-list.files(here("data/raw"), pattern="*_1.fq.gz", full.names=TRUE)
readr::write_csv(tibble::tibble(sample=sub("_1\\.fq\\.gz","",basename(files)),
                                fastq_1=files,
                                fastq_2=sub("_1\\.f","_2.f",files),
                                strandedness="auto"),file="doc/sample_sheet.csv")
