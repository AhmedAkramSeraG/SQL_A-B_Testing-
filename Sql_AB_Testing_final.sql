--We are running an experiment at an item-level, which means all users who visit will see the same page, but the layout of different item pages may differ.
--Compare this table to the assignment events we captured for user_level_testing.
--Does this table have everything you need to compute metrics like 30-day view-binary? Answer is NO because we need date/time column to calulate 30d time frame

--Data Check
SELECT * 
FROM dsv1069.final_assignments_qa;

--Reformat the final_assignments_qa to look like the final_assignments table, filling in any missing values with a placeholder of the appropriate data type.

SELECT 
  item_id,
  test_a AS test_assignment,
  (CASE WHEN test_a IS NOT NULL THEN 'test_a' ELSE NULL END) AS test_number,
  (CASE WHEN test_a IS NOT NULL THEN '2013-01-05 00:00:00' ELSE NULL END) AS test_start_date
FROM 
  dsv1069.final_assignments_qa
UNION
SELECT 
  item_id,
  test_b AS test_assignment,
  (CASE WHEN test_b IS NOT NULL THEN 'test_b' ELSE NULL END) AS test_number,
  (CASE WHEN test_b IS NOT NULL THEN '2013-01-05 00:00:00' ELSE NULL END) AS test_start_date
FROM 
  dsv1069.final_assignments_qa
UNION
SELECT 
  item_id,
  test_c AS test_assignment,
  (CASE WHEN test_c IS NOT NULL THEN 'test_c' ELSE NULL END) AS test_number,
  (CASE WHEN test_c IS NOT NULL THEN '2013-01-05 00:00:00' ELSE NULL END) AS test_start_date
FROM 
  dsv1069.final_assignments_qa
UNION
SELECT 
  item_id,
  test_d AS test_assignment,
  (CASE WHEN test_d IS NOT NULL THEN 'test_d' ELSE NULL END) AS test_number,
  (CASE WHEN test_d IS NOT NULL THEN '2013-01-05 00:00:00' ELSE NULL END) AS test_start_date
FROM 
  dsv1069.final_assignments_qa
UNION
SELECT 
  item_id,
  test_e AS test_assignment,
  (CASE WHEN test_e IS NOT NULL THEN 'test_e' ELSE NULL END) AS test_number,
  (CASE WHEN test_e IS NOT NULL THEN '2013-01-05 00:00:00' ELSE NULL END) AS test_start_date
FROM 
  dsv1069.final_assignments_qa
UNION
SELECT 
  item_id,
  test_f AS test_assignment,
  (CASE WHEN test_f IS NOT NULL THEN 'test_f' ELSE NULL END) AS test_number,
  (CASE WHEN test_f IS NOT NULL THEN '2013-01-05 00:00:00' ELSE NULL END) AS test_start_date
FROM 
  dsv1069.final_assignments_qa


  -- Use this table to compute order_binary for the 30 day window after the test_start_date
-- for the test named item_test_2

SELECT 
  test_assignment,
  COUNT(item_id) AS items,
  SUM(order_binary_30d) AS orders
FROM 
  (
  SELECT 
    fa.item_id,
    fa.test_assignment,
    MAX(CASE WHEN o.created_at > fa.test_start_date AND 
                  DATE_PART('day', o.created_at - fa.test_start_date) <= 30
              THEN 1 ELSE 0 END) AS order_binary_30d
  FROM 
    dsv1069.final_assignments fa
  LEFT JOIN 
    dsv1069.orders o
  ON 
    fa.item_id = o.item_id
  WHERE 
    test_number = 'item_test_2'
  GROUP BY
    fa.item_id,
    fa.test_assignment
  ) order_binary
GROUP BY
  test_assignment


  --compute view_binary for the 30 day window after the test_start_date
-- for the test named item_test_2

SELECT 
  test_assignment,
  COUNT(item_id) AS items,
  SUM(views_binary_30d) AS views
FROM 
  (
  SELECT 
    fa.item_id,
    fa.test_assignment,
    MAX(CASE WHEN views.event_time > fa.test_start_date AND 
                  DATE_PART('day', views.event_time - fa.test_start_date) <= 30
              THEN 1 ELSE 0 END) AS views_binary_30d
  FROM 
    dsv1069.final_assignments fa

  LEFT JOIN 
    (
    SELECT
      event_time,
      event_id,
      CAST(parameter_value AS INT) AS item_id
    FROM dsv1069.events
    WHERE event_name = 'view_item'
    AND parameter_name = 'item_id'
    ) as views
  ON fa.item_id = views.item_id
  WHERE 
    test_number = 'item_test_2'
  GROUP BY
    fa.item_id,
    fa.test_assignment
  ) as view_binary
GROUP BY
  test_assignment
