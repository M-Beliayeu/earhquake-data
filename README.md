# earhquakes-geojson
Processes earthquake data stored in geojson format into (MySQL) server



[Link](https://earthquake.usgs.gov/) to dataset we will refer to.

You can use the following sql script and jupyter notebooks (convert to .py if necessary) to process geojson files, store them 

[create_schema.sql](./create_schema.sql) creates MySQL schema for the model described by:
[schema_model](./schema_model.png)

[setup_database.ipynb](./setup_database.ipynb) scrapes [documentation](https://earthquake.usgs.gov/data/comcat/) to establish the list of agencies (**Agency** table), or networks, that can be considered as sources of information for events. It also populates tables with common magnitude types (**MagnitudeTypes** table), status (**Status** table) and alerts (**Alerts** table) values. If event contains a variable that falls out of the predefined region, an exception is thrown. Consider extending these table, if it happens. For the meaning, check out [thedocumentation](https://earthquake.usgs.gov/data/comcat/).

[quakes_read_geojson.ipynb](quakes_read_geojson.ipynb) reads geojson files into database. 
