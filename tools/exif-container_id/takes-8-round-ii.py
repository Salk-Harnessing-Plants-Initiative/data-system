import exifcontainer
exifcontainer.run(
    "/raidix/groot-data/russell_tran/real_data/migrations/takes-8-round-ii/takes-8-round-ii-new-plate-2021-01-03-000156.csv", 
    "/raidix/groot-data/russell_tran/real_data/migrations/takes-8-round-ii/directory.json",
    exifcontainer.container_id_data,
    output_log="/raidix/groot-data/russell_tran/real_data/migrations/takes-8-round-ii/log.txt"
)