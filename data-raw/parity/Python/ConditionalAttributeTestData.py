import random
import numpy as np
import pandas as pd

from gensynthpop.conditional_attribute_adder import (
    ConditionalAttributeAdder
)

random.seed(123)
np.random.seed(123)

population = pd.DataFrame({

    "agent_id": range(1, 21),

    "gender":
        ["Male"] * 10 +
        ["Female"] * 10,

    "age_group":
        ["18-64"] * 20

})

contingency = pd.DataFrame({

    "age_group": [
        "18-64","18-64","18-64",
        "18-64","18-64","18-64"
    ],

    "gender": [
        "Male","Male","Male",
        "Female","Female","Female"
    ],

    "education": [
        "Degree",
        "Diploma",
        "School",
        "Degree",
        "Diploma",
        "School"
    ],

    "count": [
        50,30,20,
        50,30,20
    ]

})

adder = ConditionalAttributeAdder(
    df_synthetic_population=population,
    df_contingency=contingency,
    target_attribute="education",
    group_by=[
        "age_group",
        "gender"
    ]
)

result = adder.run()

result.to_csv(
    "Export/GenSynthPopR/parity/reference_data/conditional_attribute_adder.csv",
    index=False
)

# import pandas as pd
# from gensynthpop.conditional_attribute_adder import ConditionalAttributeAdder
# from gensynthpop.household_grouper import HouseholdType, HouseholdGrouper
# print("GenSynthPop imports successful")
# 
# # import gensynthpop 
# # from gensynthpop.conditional_attribute_adder import (
# #     ConditionalAttributeAdder
# # )
# 
# population = pd.DataFrame({
# 
#     "agent_id": range(1, 21),
# 
#     "gender":
#         ["Male"] * 10 +
#         ["Female"] * 10,
# 
#     "age_group":
#         ["18-64"] * 20
# 
# })
# contingency = pd.DataFrame({
# 
#     "age_group": [
#         "18-64","18-64","18-64",
#         "18-64","18-64","18-64"
#     ],
# 
#     "gender": [
#         "Male","Male","Male",
#         "Female","Female","Female"
#     ],
# 
#     "education": [
#         "Degree",
#         "Diploma",
#         "School",
#         "Degree",
#         "Diploma",
#         "School"
#     ],
# 
#     "count": [
#         50,
#         30,
#         20,
#         50,
#         30,
#         20
#     ]
# 
# })
# import random
# import numpy as np
# 
# random.seed(123)
# np.random.seed(123)
# adder = ConditionalAttributeAdder(
#     df_synthetic_population =
#         population,
# 
#     df_contingency =
#         contingency,
# 
#     target_attribute =
#         "education",
# 
#     group_by = [
#         "age_group",
#         "gender"
#     ]
# )
# 
# result = adder.run()
# result.to_csv(
#     "Export/GenSynthPopR/parity/reference_data/conditional_attribute_adder.csv",
#     index=False
# )
# # from gensynthpop.household_grouper import (
# #     HouseholdType
# # )
# couples = hh_type.pair_partners(
#     group_mask
# )
# 
# pd.DataFrame(
#     couples
# ).to_csv(
#     "parity/reference_data/pair_partners.csv",
#     index=False
# )
