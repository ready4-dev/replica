import random
import numpy as np
import pandas as pd

from gensynthpop.household_grouper import (
    HouseholdType,
    HouseholdGrouper
)

# --------------------------------------------------
# Reproducibility
# --------------------------------------------------

random.seed(123)
np.random.seed(123)

# --------------------------------------------------
# Create synthetic population
# --------------------------------------------------

pop = pd.DataFrame({

    "agent_id": [
        "A001",
        "A002",
        "A003",
        "A004"
    ],

    "neighb_code": [
        "N1",
        "N1",
        "N2",
        "N2"
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

})

# --------------------------------------------------
# Create HouseholdType
# --------------------------------------------------

hh_type = HouseholdType(
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

# --------------------------------------------------
# Define household members
# --------------------------------------------------

hh_type.add_members(
    household_position="Parent",
    position_identifier="adult",
    amount=2,
    backup_position_identifiers=[]
)

# --------------------------------------------------
# Create HouseholdGrouper
# --------------------------------------------------

grouper = HouseholdGrouper(
    df_synth_pop=pop,
    group_by=["neighb_code"],
    household_position_column="household_position"
)

# --------------------------------------------------
# Register HouseholdType
# --------------------------------------------------

grouper.add_household_type(
    hh_type
)

# --------------------------------------------------
# Run household generation
# --------------------------------------------------

synthetic_population, synthetic_households = (
    grouper.run()
)

# --------------------------------------------------
# Export reference outputs
# --------------------------------------------------

synthetic_population.reset_index().to_csv(
    "Export/GenSynthPopR/parity/reference_data/household_grouper_population.csv",
    index=False
)

synthetic_households.reset_index().to_csv(
    "Export/GenSynthPopR/parity/reference_data/household_grouper_households.csv"
)

print("Files written:")

print(
    "Export/GenSynthPopR/parity/reference_data/"
    "household_grouper_population.csv"
)

print(
    "Export/GenSynthPopR/parity/reference_data/"
    "household_grouper_households.csv"
)
