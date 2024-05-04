import numpy as np
import nibabel as nb
import pandas as pd
import os

wab_measures = ['pid', 'wab_fluency', 'wab_av_comp', 'wab_rep', 'wab_obj_name', 'wab_aphasia_score']
roi = ['pid', 'temporal', 'parietal', 'motor', 'frontal']

work_dir = '/rri_disks/eugenia/meltzer_lab/NROD98/wab_xtract'
roi_damage_path = work_dir + '/tables/roi_damage.csv'
wab_scores_path = work_dir + '/behavioral/wab_scores.csv'

roi_damageDF = pd.read_csv(roi_damage_path)[roi]
wabDF = pd.read_csv(wab_scores_path).rename(columns={'subj': 'pid'})

mergedDF = pd.merge(roi_damageDF, wabDF, on=["pid"]).dropna()
correlationDF = mergedDF.corr()[wab_measures][1:5]

# mergedDF.to_csv('/rri_disks/eugenia/meltzer_lab/NROD98/wab_xtract/tables/' + 'wab_lesion_overlap.csv')
correlationDF.to_csv('/rri_disks/eugenia/meltzer_lab/NROD98/wab_xtract/correlations/' + 'correlation_wab_roi_damage.csv')
print(correlationDF)