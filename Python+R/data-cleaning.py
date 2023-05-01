import pandas as pd
import numpy as np
import sys
import os

def clean_table(df:pd.DataFrame, path:str):
    df = df.copy()
    print('START data cleaning')

    for c in df.columns:
        if not pd.api.types.is_numeric_dtype(df[c]):
            df[c] = df[c].astype(str)

    # Удаление дубликатов
    df.drop_duplicates()

    # Обработка выбросов
    for c in df.columns:
        if pd.api.types.is_numeric_dtype(df[c]):
            Q1 = df[c].quantile(0.25)
            Q3 = df[c].quantile(0.75)
            IQR = Q3 - Q1
            median = df[c].median()
            maxv = get_correct_max(df[c], IQR, median)
            minv = get_correct_min(df[c], IQR, median)

            for i in range(df[c].count()):
                v = df[c].loc[i]
                if v > median + IQR:
                    df.at[i, c] = maxv
                    #print(f'{c}: {maxv}')
                elif v < median - IQR:
                    #print(f'{c}: {minv}')
                    df.at[i, c] = minv

    #print(df)

    # Обработка пропущенных значений
    for c in df.columns:
        if df[c].isna().sum() > df[c].count() * 0.25:
            print(f'Drop column "{c}" beacuse too much nans')
            df = df.drop([c], axis=1)
        elif pd.api.types.is_numeric_dtype(df[c]):
            df[c].fillna(value=df[c].mean(), inplace=True)
        else:
            df[c].fillna(value=df[c].mode(), inplace=True)

    print('END data cleaning')
    df.to_csv(os.path.join(path, r'res.csv'))
    return df
    
def get_correct_max(col, IQR, median):
    maxv = sys.float_info.min
    for v in col:
        if v>maxv:
            dif = median - v
            if dif <= IQR:
                maxv = v
    return maxv

def get_correct_min(col, IQR, median):
    minv = sys.float_info.max
    for v in col:
        if v<minv:
            dif = median - v
            if dif <= IQR:
                minv = v
    return minv

def main():
    dict = {'First Score':[100, 90, np.nan, 95, 1, 56],
        'Second Score': [30, np.nan, 45, 56, -11111, 56],
        'Third Score':[52, 1240, 80, 98, 1, 56],
        'Fourth Score':[np.nan, np.nan, np.nan, 65, 1, 56],
        'STRS':['52', '40', '80', None, 'aaa', 56],}
    df = pd.DataFrame(dict)

    print(df)

    directory = os.getcwd()
    df1 = clean_table(df, directory)
    print(df1)

if __name__ == '__main__':
    main()

