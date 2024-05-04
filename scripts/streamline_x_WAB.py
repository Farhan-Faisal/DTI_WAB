import pandas as pd
import numpy as np
import os

def create_directory_if_not_exists(directory):
    if not os.path.exists(directory):
        os.makedirs(directory)
        print(f"Directory '{directory}' created successfully.")
    else:
        print(f"Directory '{directory}' already exists.")

base_dir = '/rri_disks/eugenia/meltzer_lab/NROD98/wab_xtract'
behav_path = base_dir + '/behavioral/wab_scores.csv'
tract_path = base_dir + '/native_diffusion_space_output'

cols = ['subj', 'wab_fluency', 'wab_av_comp', 'wab_rep', 'wab_obj_name', 'wab_aphasia_score']
behavDF = pd.read_csv(behav_path)[cols].dropna()

subj_list = behavDF.subj.to_list()
track_list = ['af', 'ar', 'ifo', 'ilf', 'slf1', 'slf2', 'slf3', 'uf']
unused_track_list = ['atr', 'cbd', 'cbp', 'cbt', 'cst', 'fa', 'fx', 'mdlf','or', 'str', 'vof']

print(subj_list)
tract_dict = []
for subj in subj_list:
    subj_entry = {'subj': subj}
    for tract in track_list:

        l_tract_path = path = os.path.join(tract_path, str(subj), 'tracts', tract + '_l', 'sum_waytotal')
        r_tract_path = path = os.path.join(tract_path, str(subj), 'tracts', tract + '_r', 'sum_waytotal')
        if tract not in ['af', 'ar', 'ifo', 'ilf']:
            l_tract_path = path = os.path.join(tract_path, str(subj), 'tracts', tract + '_l', 'waytotal')
            r_tract_path = path = os.path.join(tract_path, str(subj), 'tracts', tract + '_r', 'waytotal')

        try:
            lfile = open(l_tract_path, 'r')
            rfile = open(r_tract_path, 'r')

            subj_entry[tract] = int(rfile.readline().strip()) - int(lfile.readline().strip())
            
            # subj_entry[tract + '_r'] = int(rfile.readline().strip())
            lfile.close()
            rfile.close()
        except FileNotFoundError:
            continue
    
    tract_dict.append(subj_entry)

tractDF = pd.DataFrame.from_dict(tract_dict)
mergedDF = pd.merge(tractDF, behavDF, on=["subj"]).dropna()
correlationDF = mergedDF.corr()[cols[1:]][1:-len(cols) + 1]

create_directory_if_not_exists(base_dir + "/correlations")
create_directory_if_not_exists(base_dir + "/tables")
mergedDF.to_csv(base_dir + "/tables/wab_streamline.csv")
correlationDF.to_csv(base_dir + "/correlations/correlation_wab_streamline.csv")
print(correlationDF)