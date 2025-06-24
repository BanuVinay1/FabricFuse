-- Assigns linear attribution weights to channels before each purchase event
WITH purchases AS (
  SELECT user_id, event_time AS purchase_time,
         ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_time) AS purchase_id
  FROM user_events
  WHERE event_type = 'purchase'
),
touches AS (
  SELECT ue.user_id, ue.channel, ue.event_time, p.purchase_time, p.purchase_id
  FROM user_events ue
  JOIN purchases p
    ON ue.user_id = p.user_id
   AND ue.event_time < p.purchase_time
  WHERE ue.event_type IN ('view', 'click')
),
deduped AS (
  SELECT DISTINCT user_id, channel, purchase_time, purchase_id
  FROM touches
),
channel_counts AS (
  SELECT user_id, purchase_id, purchase_time,
         COUNT(*) AS num_channels
  FROM deduped
  GROUP BY user_id, purchase_id, purchase_time
),
final AS (
  SELECT d.user_id, d.purchase_id, d.channel, d.purchase_time,
         ROUND(1.0 / c.num_channels, 3) AS attribution_weight
  FROM deduped d
  JOIN channel_counts c
    ON d.user_id = c.user_id AND d.purchase_id = c.purchase_id
)
SELECT * FROM final ORDER BY user_id, purchase_id, attribution_weight DESC;