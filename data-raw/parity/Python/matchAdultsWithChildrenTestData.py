import random
import numpy as np
import pandas as pd

from gensynthpop.household_grouper import ReplicaStructure

# --------------------------------------------------
# Reproducibility
# --------------------------------------------------

random.seed(123)
np.random.seed(123)

# --------------------------------------------------
# Synthetic population
# --------------------------------------------------

pop = pd.DataFrame({

    "agent_id": [
        "A001", "A002",
        "A003", "A004",
        "C001", "C002",
        "C003", "C004"
    ],

    "age": [
        40, 38,
        52, 50,
        12, 10,
        17, 15
    ],

    "gender": [
        "Male", "Female",
        "Male", "Female",
        "Male", "Female",
        "Male", "Female"
    ],

    "household_position": [
        "Parent", "Parent",
        "Parent", "Parent",
        "Child", "Child",
        "Child", "Child"
    ],

    "neighb_code": [
        "N1", "N1",
        "N1", "N1",
        "N1", "N1",
        "N1", "N1"
    ]

}).set_index("agent_id")

# --------------------------------------------------
# Create ReplicaStructure
# --------------------------------------------------

hh_type = ReplicaStructure(
    household_type="Family",
    couple_gender_distribution=pd.Series(dtype=float),
    couple_age_distribution=pd.Series(dtype=float),
    parent_child_age_distribution=pd.Series(
        {"20-30": 1.0}
    )
)

# Adult role

hh_type.add_members(
    household_position="Parent",
    position_identifier="adult",
    amount=2,
    backup_position_identifiers=[]
)

# Child role

hh_type.add_members(
    household_position="Child",
    position_identifier="child",
    amount=2,
    backup_position_identifiers=[]
)

# Attach population

hh_type.update_state(
    pop,
    "household_position"
)

# --------------------------------------------------
# Parent groups
# --------------------------------------------------

parents = [

    [
        ("A001", 40, "Male"),
        ("A002", 38, "Female")
    ],

    [
        ("A003", 52, "Male"),
        ("A004", 50, "Female")
    ]

]

# --------------------------------------------------
# Child groups
# --------------------------------------------------

children = [

    ["C001", "C002"],
    ["C003", "C004"]

]

# --------------------------------------------------
# Run matching
# --------------------------------------------------

id_offset = hh_type.match_adults_with_children(
    parents,
    children,
    1
)

print("Final id_offset:", id_offset)

# --------------------------------------------------
# Export household summary
# --------------------------------------------------

rows = []

for household_id, household in hh_type.households.items():

    rows.append({

        "household_id": household_id,

        "household_size": len(
            household["all"]
        ),

        "members": "|".join(
            sorted(
                household["all"]
            )
        )

    })

households_df = pd.DataFrame(rows)

households_df.to_csv(
    "inst/reference_data/match_adults_with_children_households.csv",
    index=False
)

# --------------------------------------------------
# Export all assigned agents
# --------------------------------------------------

assigned_agents = []

for household in hh_type.households.values():

    assigned_agents.extend(
        household["all"]
    )

assigned_df = pd.DataFrame({

    "agent_id": sorted(
        assigned_agents
    )

})

assigned_df.to_csv(
    "inst/reference_data/match_adults_with_children_agents.csv",
    index=False
)

print("Reference files written:")
print(
    "match_adults_with_children_households.csv"
)
print(
    "match_adults_with_children_agents.csv"
)
