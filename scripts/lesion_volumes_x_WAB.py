import numpy as np
import nibabel as nb
import pandas as pd
import os

def create_directory_if_not_exists(directory):
    if not os.path.exists(directory):
        os.makedirs(directory)
        print(f"Directory '{directory}' created successfully.")
    else:
        print(f"Directory '{directory}' already exists.")

stroke_path = '/rri_disks/artemis/meltzer_lab/tvb_stroke'
behav_path = stroke_path + '/behavioural/tvb_stroke_behavioural_renamed_reordered.csv'

cols = ['subj', 'wab_fluency', 'wab_av_comp', 'wab_rep', 'wab_obj_name', 'wab_aphasia_score']
behavDF = pd.read_csv(behav_path)[cols].dropna()
subj_list = behavDF.subj.to_list()

lesion_volume_dict = []
for subj in subj_list:
    lesion_path = os.path.join(stroke_path, str(subj), 'anat', 'lesionmask.nii')
    try:
        nii = nb.load(lesion_path)
        img = nii.get_fdata()
        voxel_dims = (nii.header["pixdim"])[1:4]

        nonzero_voxel_count = np.count_nonzero(img)
        voxel_volume = np.prod(voxel_dims)
        nonzero_voxel_volume = nonzero_voxel_count * voxel_volume

        x = {
            'subj': subj,
            'sx': voxel_dims[0],
            'sy': voxel_dims[1],
            'sz': voxel_dims[2],
            'nonzero_voxel_count': nonzero_voxel_count,
            'nonzero_voxel_volume': nonzero_voxel_volume,
        }

        lesion_volume_dict.append(x)        
    except FileNotFoundError:
        continue

lesion_volume_df  = pd.DataFrame.from_dict(lesion_volume_dict)
mergedDF = pd.merge(lesion_volume_df, behavDF, on=["subj"]).dropna()
correlationDF = mergedDF.corr()[['nonzero_voxel_count', 'nonzero_voxel_volume']][6:]

create_directory_if_not_exists("correlations")
create_directory_if_not_exists("tables")
mergedDF.to_csv("tables/wab_lesion_volume.csv")
correlationDF.to_csv("correlations/correlation_wab_lesion_volume.csv")

print(correlationDF)