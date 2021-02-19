# preflight-cylinder-image-upload
Given a `qr_code` string, returns `true` if it matches a preexisting `plant_id` or `container_id` in the database, false otherwise. 

You'll notice here we accept either `plant_id` or `container_id`, whereas with `preflight-plate-image-upload` we are only willing to take `container_id`.