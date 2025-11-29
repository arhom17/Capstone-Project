/* Content Keywords */
WITH vw_contentitems AS (
    SELECT * FROM epmain.onecloud_dbo.vw_contentitems
),
pinnacle_tenants AS (
    SELECT * FROM epmain.onecloud_dbo.pinnacle_tenants WHERE _fivetran_deleted = FALSE
),
content_keywords AS (
    SELECT ky.contentid AS content_id,
        ky.keyword
    FROM epmain.onecloud_dbo.content_keywords ky
        INNER JOIN pinnacle_tenants ten
            ON ten.tenantid = ky.tenantid
    WHERE ky._fivetran_deleted = FALSE
        AND (ten.name = 'Eagle Point Software' OR ten.name = 'Ascent')
)


SELECT ci.id AS content_id,
    CASE
        WHEN ci.itemtype = 'PS_Course' THEN 'Course'
        WHEN ci.itemtype = 'PS_VidArchive' THEN 'Video'
        WHEN ci.itemtype = 'PS_Cheat' THEN 'Document'
        WHEN ci.itemtype = 'PS_Workflow' THEN 'Workflow'
        ELSE NULL
    END AS content_type,
    kw.keyword
FROM vw_contentitems ci
    INNER JOIN pinnacle_tenants ten
        ON ten.tenantid = ci.tenantid
    LEFT JOIN content_keywords kw
        ON kw.content_id = ci.id
WHERE (ten.name = 'Eagle Point Software' OR ten.name = 'Ascent')
    AND ci.itemtype = 'PS_Course'
        OR ci.itemtype = 'PS_VidArchive'
        OR ci.itemtype = 'PS_Cheat'
        OR ci.itemtype = 'PS_Workflow'





/* Content Tags */
WITH vw_contentitems AS (
    SELECT * FROM epmain.onecloud_dbo.vw_contentitems
),
pinnacle_tenants AS (
    SELECT * FROM epmain.onecloud_dbo.pinnacle_tenants WHERE _fivetran_deleted = FALSE
),
sy_tags AS (
    SELECT tg.targetid AS content_id,
        tg.tag
    FROM epmain.onecloud_dbo.sy_tags tg
        INNER JOIN pinnacle_tenants ten
            ON ten.tenantid = tg.tenantid
    WHERE tg._fivetran_deleted = FALSE
        AND (ten.name = 'Eagle Point Software' OR ten.name = 'Ascent')
        AND tg.tag_type = 'Learning'
)


SELECT ci.id AS content_id,
    CASE
        WHEN ci.itemtype = 'PS_Course' THEN 'Course'
        WHEN ci.itemtype = 'PS_VidArchive' THEN 'Video'
        WHEN ci.itemtype = 'PS_Cheat' THEN 'Document'
        WHEN ci.itemtype = 'PS_Workflow' THEN 'Workflow'
        ELSE NULL
    END AS content_type,
    tg.tag
FROM vw_contentitems ci
    INNER JOIN pinnacle_tenants ten
        ON ten.tenantid = ci.tenantid
    LEFT JOIN sy_tags tg
        ON tg.content_id = ci.id
WHERE (ten.name = 'Eagle Point Software' OR ten.name = 'Ascent')
    AND ci.itemtype = 'PS_Course'
        OR ci.itemtype = 'PS_VidArchive'
        OR ci.itemtype = 'PS_Cheat'
        OR ci.itemtype = 'PS_Workflow'





/* Content Topics */
WITH vw_contentitems AS (
    SELECT * FROM epmain.onecloud_dbo.vw_contentitems
),
pinnacle_tenants AS (
    SELECT * FROM epmain.onecloud_dbo.pinnacle_tenants WHERE _fivetran_deleted = FALSE
),
vw_product_content_usage AS (
    SELECT * FROM epmain.onecloud_dbo.vw_product_content_usage
),
content_products AS (
    SELECT * FROM epmain.onecloud_dbo.content_products WHERE _fivetran_deleted = FALSE
),
content_product_versions AS (
    SELECT * FROM epmain.onecloud_dbo.content_product_versions WHERE _fivetran_deleted = FALSE
)

SELECT ci.id AS content_id,
    CASE
        WHEN ci.itemtype = 'PS_Course' THEN 'Course'
        WHEN ci.itemtype = 'PS_VidArchive' THEN 'Video'
        WHEN ci.itemtype = 'PS_Cheat' THEN 'Document'
        WHEN ci.itemtype = 'PS_Workflow' THEN 'Workflow'
        ELSE NULL
    END AS content_type,
    cp.name AS topic,
    cpv.name AS suptopic,
    CASE
        WHEN cpv.name IS NULL THEN cp.name
        WHEN cp.name = cpv.name THEN cp.name
        ELSE CONCAT(cp.name, ' ', cpv.name) 
    END AS topic_subtopic
FROM vw_contentitems ci
    INNER JOIN pinnacle_tenants ten
        ON ten.tenantid = ci.tenantid
    LEFT JOIN vw_product_content_usage pcu
        ON pcu.contentid = ci.id
    LEFT JOIN content_products cp
        ON cp.content_productid = pcu.content_productid
    LEFT JOIN content_product_versions cpv
        ON cpv.content_verid = pcu.content_verid
WHERE (ten.name = 'Eagle Point Software' OR ten.name = 'Ascent')
    AND ci.itemtype = 'PS_Course'
        OR ci.itemtype = 'PS_VidArchive'
        OR ci.itemtype = 'PS_Cheat'
        OR ci.itemtype = 'PS_Workflow'




/* Interactions */
WITH lp_course_enrollment AS (
    SELECT * FROM epmain.onecloud_dbo.lp_course_enrollment WHERE _fivetran_deleted = FALSE
),
lp_courses AS (
    SELECT * FROM epmain.onecloud_dbo.lp_courses WHERE _fivetran_deleted = FALSE
),
pinnacle_tenants AS (
    SELECT * FROM epmain.onecloud_dbo.pinnacle_tenants WHERE _fivetran_deleted = FALSE
),
sy_histories AS (
    SELECT * FROM epmain.onecloud_dbo.sy_histories WHERE _fivetran_deleted = FALSE
),
vw_contentitems AS (
    SELECT * FROM epmain.onecloud_dbo.vw_contentitems
),
combined_interactions AS (
    SELECT enr.enrollid AS interaction_id,
        CASE
            WHEN enr.completed_date IS NULL THEN CAST(enr.assigned_date AS DATE)
            ELSE CAST(enr.completed_date AS DATE)
        END AS interaction_date,
        CASE
            WHEN enr.completed_date IS NULL THEN 'Course Enrollment'
            ELSE 'Course Completion'
        END AS interaction_type,
        enr.tenantid AS tenant_id,
        enr.assigned_to_userid AS user_id,
        enr.courseid AS content_id
    FROM lp_course_enrollment enr
        INNER JOIN lp_courses cor
            ON cor.courseid = enr.courseid
        INNER JOIN pinnacle_tenants ten
            ON ten.tenantid = cor.tenantid
    WHERE enr.is_dropped = FALSE
        AND (ten.name = 'Eagle Point Software' OR ten.name = 'Ascent')
        AND enr.assigned_date >= CAST('2021-01-01' AS DATE)
    
        UNION ALL
    
    SELECT sh.histid AS interaction_id,
        CAST(sh.hist_date AS DATE) AS interaction_date,
        CASE
            WHEN sh.hist_type = 'PS_Cheat' THEN 'Document Opened'
            WHEN sh.hist_type = 'PS_VidArchive' THEN 'Video Watched'
            WHEN sh.hist_type = 'PS_Workflow' THEN 'Workflow Opened'
            ELSE NULL
        END AS interaction_type,
        sh.tenantid AS tenant_id,
        sh.userid AS user_id,
        sh.linkid AS content_id
    FROM sy_histories sh
        INNER JOIN vw_contentitems ci
            ON ci.id = sh.linkid
        INNER JOIN pinnacle_tenants ten
            ON ten.tenantid = ci.tenantid
    WHERE (sh.hist_type = 'PS_Cheat'
            OR sh.hist_type = 'PS_VidArchive'
            OR sh.hist_type = 'PS_Workflow')
        AND (ten.name = 'Eagle Point Software' OR ten.name = 'Ascent')
        AND sh.hist_date >= CAST('2021-01-01' AS DATE)
)

SELECT *
FROM combined_interactions ci
ORDER BY ci.interaction_date DESC





/* Tenant Information */
SELECT ten.tenant_id, cust.industry, cust.segment
FROM internal_reporting.core.customers cust
    INNER JOIN internal_reporting.core.tenants ten
        ON ten.pinnacle_id = cust.pinnacle_id




/* User Information */
WITH pinnacle_users AS (
    SELECT * FROM epmain.onecloud_dbo.pinnacle_users WHERE _fivetran_deleted = FALSE
),
sy_user_properties_values AS (
    SELECT * FROM epmain.onecloud_dbo.sy_user_properties_values WHERE _fivetran_deleted = FALSE
),
sy_user_properties AS (
    SELECT * FROM epmain.onecloud_dbo.sy_user_properties WHERE _fivetran_deleted = FALSE
)

SELECT pu.userid,
    upv.str_val AS job_title
FROM pinnacle_users pu
    INNER JOIN sy_user_properties_values upv
        ON upv.userid = pu.userid
    INNER JOIN sy_user_properties up
        ON up.userpropertyid = upv.userpropertyid
WHERE up.name ILIKE '%Job%'