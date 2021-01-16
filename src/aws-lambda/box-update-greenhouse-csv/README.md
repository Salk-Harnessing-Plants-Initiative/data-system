# Box Update Greenhouse CSV
When called with a `section_name`, goes and updates all Box environmental data CSVs corresponding to experiments
which are currently connected to that `section_name`.

# Configure
## Box 

1. `Create New App` > `Custom App` > `Server Authentication with JWT` > (go to app Configuration tab) > `Generate a Public/Private keypair` > `Download as JSON` > rename JSON to `box_config.json` and put in same directory as `main.py`
2. Enable this script to access your folders by sharing the relevant root folder with the email address of this "Service user". Find the email address by running the following:
```
pipenv run python get_email_address.py
```

# Manual tests
* The CSV is created if not preexisting, is updated with new version if preexisting
* A new relevant row in the database gets reflected in the CSV
* A deleted row in the database gets reflected in the CSV
* For each matched experiment, you can see changes reflected in its CSV (not just one experiment)