import random
import numpy as np
import pandas as pd

from gensynthpop.household_grouper import (
    HouseholdType
)

random.seed(123)
np.random.seed(123)

pop = pd.DataFrame({

    "agent_id": [
        "A001",
        "A002",
        "A003"
    ],

    "age": [
        30,
        45,
        60
    ],

    "gender": [
        "Male",
        "Female",
        "Male"
    ],

    "household_position": [
        "SingleAdult",
        "SingleAdult",
        "SingleAdult"
    ]

}).set_index("agent_id")

hh_type = HouseholdType(
    household_type="SingleAdultHousehold",
    couple_gender_distribution=pd.Series(dtype=float),
    couple_age_distribution=pd.Series(dtype=float),
    parent_child_age_distribution=pd.Series(dtype=float)
)

hh_type.add_members(
    household_position="SingleAdult",
    position_identifier="adult",
    amount=1,
    backup_position_identifiers=[]
)

hh_type.update_state(
    pop,
    "household_position"
)

group_mask = pd.Series(
    [True] * len(pop),
    index=pop.index
)

households = hh_type.create_singles(
    group_mask
)

pd.DataFrame({
    "sampled_agents":
        hh_type.sampled_agents
}).to_csv(
    "Export/GenSynthPopR/parity/reference_data/create_singles.csv",
    index=False
)
