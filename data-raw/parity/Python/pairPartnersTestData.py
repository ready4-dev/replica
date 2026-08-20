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
        "A001",
        "A002",
        "A003",
        "A004"
    ],

    "age": [
        40,
        35,
        50,
        45
    ],

    "gender": [
        "Male",
        "Female",
        "Male",
        "Female"
    ],

    "household_position": [
        "Parent",
        "Parent",
        "Parent",
        "Parent"
    ]

}).set_index("agent_id")

hh_type = ReplicaStructure(
    household_type="CoupleHousehold",
    couple_gender_distribution=pd.Series(
        {("Male", "Female"): 1.0}
    ),
    couple_age_distribution=pd.Series(
        {"-5-5": 1.0}
    ),
    parent_child_age_distribution=pd.Series(
        dtype=float
    )
)

hh_type.add_members(
    household_position="Parent",
    position_identifier="adult",
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

couples = hh_type.pair_partners(
    group_mask
)
# Export Sampled Agents
pd.DataFrame({
    "sampled_agents":
        hh_type.sampled_agents
}).to_csv(
    "inst/reference_data/pair_partners_sampled.csv",
    index=False
)
# Export Age Gaps
age_gaps = []

for p1, p2 in couples:

    age_gaps.append(
        int(p1[1]) - int(p2[1])
    )

pd.DataFrame({
    "age_gap": age_gaps
}).to_csv(
    "inst/reference_data/pair_partners_age_gaps.csv",
    index=False
)

# Export Gender Pairings
genders = []

for p1, p2 in couples:

    genders.append(
        f"{p1[2]}-{p2[2]}"
    )

pd.DataFrame({
    "pair": genders
}).to_csv(
    "inst/reference_data/pair_partners_genders.csv",
    index=False
)
