#!/bin/sh
# Run certificate setup/renewal immediately on container start,
# then hand off to crond for daily renewals.
/run.sh
exec crond -f
