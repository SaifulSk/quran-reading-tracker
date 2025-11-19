/*
  # Assign unique colors to existing readers

  Updates all existing readers to have unique colors from the palette.
  Assigns colors sequentially to prevent duplicates.
*/

UPDATE readers
SET color = CASE id
  WHEN 'cb14214e-f235-4e1e-b23a-b90eff6d5dbc' THEN '#FF6B6B'
  WHEN '3109344c-8156-476e-bd57-32b178989279' THEN '#4ECDC4'
  WHEN '1fce1b87-6c98-4c84-b30c-0f9be50ae995' THEN '#45B7D1'
  WHEN 'd75e01c5-12a4-443d-85de-f3cbfda64e9c' THEN '#FFA07A'
  WHEN '4cfe851f-36b5-4e37-8be3-e4e25efbd83c' THEN '#98D8C8'
  WHEN 'a87c97fb-a506-4111-adb7-75cdf3143919' THEN '#F7DC6F'
END
WHERE id IN (
  'cb14214e-f235-4e1e-b23a-b90eff6d5dbc',
  '3109344c-8156-476e-bd57-32b178989279',
  '1fce1b87-6c98-4c84-b30c-0f9be50ae995',
  'd75e01c5-12a4-443d-85de-f3cbfda64e9c',
  '4cfe851f-36b5-4e37-8be3-e4e25efbd83c',
  'a87c97fb-a506-4111-adb7-75cdf3143919'
);
