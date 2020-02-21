USE openmrs;

# Modified from obs_with_parent_view
CREATE OR REPLACE VIEW obs_en_view AS
    # Utility view for obs which also selects the English (en) names related to a concept
    # And combines the various value_* columns into a single column, obs_value
    # This was created for the purpose of exporting data from OpenMRS.
    SELECT
        obs.obs_id AS obs_id,
        obs.encounter_id AS encounter_id,
        obs.person_id AS person_id,

        obs_concept.full_name_en AS obs_concept_name_en,
        parent_obs.obs_id AS parent_obs_id,
        parent_concept.full_name_en AS parent_concept_name_en,

        # Combine the various value columns into one
        # TODO: Ensure that any type conversion here is portable (especially for dates)
        COALESCE(
            value_concept.full_name_en,
            obs.value_drug,
            obs.value_datetime,
            obs.value_numeric,
            obs.value_text,
            obs.value_modifier
        ) as obs_value,

        obs_concept.datatype_name as obs_data_type,

        obs.uuid AS obs_uuid,

        # These individual value columns can be omitted from most queries
        value_concept.full_name_en    AS value_concept_name_en,
        obs.value_coded               AS obs_value_coded,
        obs.value_drug                AS obs_value_drug,
        obs.value_datetime            AS obs_value_datetime,
        obs.value_numeric             AS obs_value_numeric,
        obs.value_modifier            AS obs_value_modifier,
        obs.value_text                AS obs_value_text
    FROM obs
    # Self-join to get the Observation Group
    # TODO: Should we exclude obs rows for which obs_group_id IS NULL?
    LEFT JOIN obs parent_obs
        ON (obs.obs_group_id = parent_obs.obs_id AND parent_obs.voided = 0)
    LEFT JOIN concept_flat_view obs_concept
        ON (obs.concept_id = obs_concept.concept_id)
    LEFT JOIN concept_flat_view value_concept
        ON (obs.value_coded = value_concept.concept_id)
    LEFT JOIN concept_flat_view parent_concept
        ON (parent_obs.concept_id = parent_concept.concept_id)
    WHERE obs.voided = 0
;