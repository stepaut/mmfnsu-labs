import pandas as pd

def clean_table(df:pd.DataFrame):
    df.drop_duplicates()
    

def main():
    df = pd.DataFrame()

    clean_table(df)

if __name__ == '__main__':
    main()

