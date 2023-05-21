import pandas as pd
import numpy as np
import sys
import os
import enum
import matplotlib.pyplot as plt
import matplotlib
 
matplotlib.rcParams['font.size'] = 10
matplotlib.rcParams['figure.dpi'] = 100
 
from IPython.core.pylabtools import figsize

class EjectionType(enum.Enum):
    iqr = 0
    hampel = 1

def clean_table(df:pd.DataFrame, 
                path:str, 
                nan_crit_val:float = 0.25,
                iqr_coef:int = 1,
                ejection_type:EjectionType = EjectionType.iqr, #https://leftjoin.ru/all/outliers-detection-in-python/
                save_csv:bool = False, 
                do_output:bool = False):
    df = df.copy()
    log = []
    print('START data cleaning')

    for c in df.columns:
        if not pd.api.types.is_numeric_dtype(df[c]):
            df[c] = df[c].astype(str)

    # Удаление дубликатов
    df.drop_duplicates()

    # Обработка выбросов
    for c in df.columns:
        if pd.api.types.is_numeric_dtype(df[c]):
            median = df[c].median()

            if (ejection_type == EjectionType.iqr):
                Q1 = df[c].quantile(0.25)
                Q3 = df[c].quantile(0.75)
                max_deviation = (Q3 - Q1)*iqr_coef
            elif (ejection_type == EjectionType.hampel):
                difference = np.abs(median-df[c])
                max_deviation = 3 * difference.median()

            maxv = get_correct_max(df[c], max_deviation, median)
            minv = get_correct_min(df[c], max_deviation, median)

            for i in range(df[c].count()):
                v = df[c].loc[i]
                if v > median + max_deviation:
                    log.append(f'in col {c} in row {i} top ej-n = {v} repl-d by {maxv}; md={max_deviation}, median={median}')
                    df.at[i, c] = maxv
                elif v < median - max_deviation:
                    log.append(f'in col {c} in row {i} bottom ej-n = {v} repl-d by {minv}; md={max_deviation}, median={median}')
                    df.at[i, c] = minv

    # Обработка пропущенных значений
    for c in df.columns:
        if df[c].isna().sum() > df[c].count() * nan_crit_val:
            log.append(f'Drop column "{c}" beacuse too much nans')
            df = df.drop([c], axis=1)
        elif pd.api.types.is_numeric_dtype(df[c]):
            df[c].fillna(value=df[c].mean(), inplace=True)
        else:
            df[c].fillna(value=df[c].mode(), inplace=True)

    print('END data cleaning')
    if save_csv:
        df.to_csv(os.path.join(path, r'res.csv'))

    if do_output:
        with open(f"{path}\\temp\\log.txt", 'w') as fp:
            fp.write('\n'.join(log))
    return df
    
def get_correct_max(col, max_deviation, median):
    maxv = sys.float_info.min
    for v in col:
        if v>maxv:
            dif = abs(median - v)
            if dif <= max_deviation:
                maxv = v
    return maxv

def get_correct_min(col, max_deviation, median):
    minv = sys.float_info.max
    for v in col:
        if v<minv:
            dif = abs(median - v)
            if dif <= max_deviation:
                minv = v
    return minv

def make_graphs(orig:pd.DataFrame, clear:pd.DataFrame):
    cols = clear.columns

    figsize(6, 4)

    for c in cols:
        plt.hist([orig[c], clear[c]])

def main():
    dict = {'First Score':[100, 90, np.nan, 95, 1, 56],
        'Second Score': [30, np.nan, 45, 56, -11111, 56],
        'Third Score':[52, 1240, 80, 98, 1, 56],
        'Fourth Score':[np.nan, np.nan, np.nan, 65, 1, 56],
        'STRS':['52', '40', '80', None, 'aaa', 56],}
    df = pd.DataFrame(dict)
    directory = os.getcwd()
    df = pd.read_csv(directory + '\\datasets\\avocado.csv')
    print(df)

    df1 = clean_table(df, 
                      directory, 
                      do_output=True, 
                      nan_crit_val = 0.0000000001,
                      ejection_type=EjectionType.iqr,
                      iqr_coef = 1000)
    print(df1)

    make_graphs(df,df1)

if __name__ == '__main__':
    main()

