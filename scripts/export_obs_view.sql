USE openmrs;

# Modified from obs_with_parent_view
CREATE OR REPLACE VIEW
export_obs_view AS
    SELECT
        obs.obs_id AS obs_id,
        obs.encounter_id AS encounter_id,
        obs.person_id AS person_id,

        obs_concept.full_name AS obs_concept_name,
        parent_obs.obs_id AS parent_obs_id,
        parent_concept.full_name AS parent_concept_name,

        # Combine the various value columns into one
        COALESCE(
            value_concept.full_name,
            obs.value_drug,
            obs.value_datetime,
            obs.value_numeric,
            obs.value_text,
            obs.value_modifier
        ) as obs_value,

        obs_concept.datatype_name as obs_data_type,

        obs.uuid AS obs_uuid,

        # These individual value columns can be omitted from most queries
        value_concept.full_name AS value_concept_name,
        obs.value_coded     as obs_value_coded,
        obs.value_drug      as obs_value_drug,
        obs.value_datetime  as obs_value_datetime,
        obs.value_numeric   as obs_value_numeric,
        obs.value_modifier  as obs_value_modifier,
        obs.value_text      as obs_value_text
    FROM obs
    LEFT JOIN obs parent_obs ON (obs.obs_group_id = parent_obs.obs_id AND parent_obs.voided = 0)
    LEFT JOIN export_concept_view obs_concept ON (obs.concept_id = obs_concept.concept_id)
    LEFT JOIN export_concept_view value_concept ON (obs.value_coded = value_concept.concept_id)
    LEFT JOIN export_concept_view parent_concept ON (parent_obs.concept_id = parent_concept.concept_id)
    WHERE obs.voided = 0
