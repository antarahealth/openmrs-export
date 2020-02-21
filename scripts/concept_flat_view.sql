USE openmrs;

#TODO: Review security statements
CREATE OR REPLACE
    definer = admin@`%`
    SQL SECURITY DEFINER
VIEW concept_flat_view AS

    # Utility view which selects information related to a concept:
    # It's full and short name (English), class name, datatype and description.
    # This was created for the purpose of exporting data from OpenMRS.

    SELECT con.concept_id    AS concept_id,
           full.name         AS full_name_en,
           short.name        AS short_name_en,
           cclass.name       AS class_name,
           dtype.name        AS datatype_name,
           con.retired       AS retired,
           des.description   AS description,
           con.date_created  AS date_created,
           con.uuid          AS uuid
    FROM concept con
    LEFT JOIN concept_name full
    ON (
            (full.concept_id = con.concept_id)
        AND (full.concept_name_type = 'FULLY_SPECIFIED' )
        AND (full.locale = 'en')
        AND (full.voided = 0)
       )
    LEFT JOIN concept_name short
    ON (
            (short.concept_id = con.concept_id)
        AND (short.concept_name_type = 'SHORT')
        AND (short.locale = 'en')
        AND (short.voided = 0)
       )
    LEFT JOIN concept_class cclass
    ON (cclass.concept_class_id = con.class_id)
    LEFT JOIN concept_datatype dtype
    ON (dtype.concept_datatype_id = con.datatype_id)
    LEFT JOIN concept_description des
    ON (des.concept_id = con.concept_id)
;