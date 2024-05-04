import pandas as pd

work_dir = '/rri_disks/eugenia/meltzer_lab/NROD98/wab_xtract'
tract_fa_path = work_dir + "/tables/mean_tract_FA.csv"
wab_scores_path = work_dir + '/behavioral/wab_scores.csv'

tract_FA_DF = pd.read_csv(tract_fa_path)
wabDF = pd.read_csv(wab_scores_path).rename(columns={'subj': 'pid'})

tracts = ['af', 'ar', 'ilf', 'ifo', 'slf3', 'uf']
wab_measures = ['wab_fluency', 'wab_av_comp', 'wab_rep', 'wab_obj_name', 'wab_aphasia_score']

tract_FA_DF = pd.pivot_table(tract_FA_DF, values='mean_FA', index='pid', columns='tract').reset_index()
for tract in tracts:
    tract_FA_DF[tract] = tract_FA_DF[tract + "_r"] - tract_FA_DF[tract + "_l"]

tracts.append('pid')
tract_FA_DF = tract_FA_DF[tracts]

mergedDF = pd.merge(tract_FA_DF, wabDF, on=["pid"]).dropna()
correlationDF = mergedDF.corr()[wab_measures][:6]

mergedDF.to_csv(work_dir + '/tables/' + 'wab_mean_FA.csv')
correlationDF.to_csv(work_dir + '/correlations/' + 'correlation_wab_mean_FA.csv')