import random
import numpy as np
import pandas as pd

from gensynthpop.household_grouper import (
    ReplicaStructure
)

random.seed(123)
np.random.seed(123)

pop = pd.DataFrame({

    "agent_id": [
        "C001",
        "C002",
        "C003",
        "C004"
    ],

    "age": [
        10,
        11,
        17,
        18
    ],

    "gender": [
        "Male",
        "Female",
        "Male",
        "Female"
    ],

    "household_position": [
        "Child",
        "Child",
        "Child",
        "Child"
    ]

}).set_index("agent_id")

hh_type = ReplicaStructure(
    household_type="Family",
    couple_gender_distribution=pd.Series(dtype=float),
    couple_age_distribution=pd.Series(dtype=float),
    parent_child_age_distribution=pd.Series(dtype=float)
)

hh_type.add_members(
    household_position="Child",
    position_identifier="child",
    amount=2,
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

groups = hh_type.group_children(
    group_mask,
    hh_type.get_position_for_name("child")
)
group_sizes = [len(g) for g in groups]

pd.DataFrame({
    "group_size": group_sizes
}).to_csv(
    "inst/reference_data/group_children_sizes.csv",
    index=False
)
pd.DataFrame({
    "agent_id": hh_type.sampled_agents
}).to_csv(
    "inst/reference_data/group_children_agents.csv",
    index=False
)
