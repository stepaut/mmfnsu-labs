import pandas as pd
import numpy as np
import sys
import os

def clean_table(df:pd.DataFrame, 
                path:str, 
                nan_crit_val:float = 0.25,
                ejected_vals_coef:int = 1,
                ejection_type:str = "IQR", #https://leftjoin.ru/all/outliers-detection-in-python/
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
            Q1 = df[c].quantile(0.25)
            Q3 = df[c].quantile(0.75)
            IQR = Q3 - Q1
            median = df[c].median()
            maxv = get_correct_max(df[c], IQR, median, ejected_vals_coef)
            minv = get_correct_min(df[c], IQR, median, ejected_vals_coef)

            for i in range(df[c].count()):
                v = df[c].loc[i]
                if v > median + ejected_vals_coef * IQR:
                    if do_output: log.append(f'in col {c} in row {i} top ej-n = {v} repl-d by {maxv}; IQR={IQR}, median={median}')
                    df.at[i, c] = maxv
                elif v < median - ejected_vals_coef * IQR:
                    if do_output: log.append(f'in col {c} in row {i} bottom ej-n = {v} repl-d by {minv}; IQR={IQR}, median={median}')
                    df.at[i, c] = minv

    # Обработка пропущенных значений
    for c in df.columns:
        if df[c].isna().sum() > df[c].count() * nan_crit_val:
            if do_output: log.append(f'Drop column "{c}" beacuse too much nans')
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
    
def get_correct_max(col, IQR, median, ejected_vals_coef):
    maxv = sys.float_info.min
    for v in col:
        if v>maxv:
            dif = abs(median - v)
            if dif <= ejected_vals_coef * IQR:
                maxv = v
    return maxv

def get_correct_min(col, IQR, median, ejected_vals_coef):
    minv = sys.float_info.max
    for v in col:
        if v<minv:
            dif = abs(median - v)
            if dif <= ejected_vals_coef * IQR:
                minv = v
    return minv

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
                      ejected_vals_coef = 1000)
    print(df1)

if __name__ == '__main__':
    main()

