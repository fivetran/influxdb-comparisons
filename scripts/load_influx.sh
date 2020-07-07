#!/bin/bash

# Ensure loader is available
EXE_FILE_NAME=${EXE_FILE_NAME:-$(which bulk_load_influx)}
if [[ -z "$EXE_FILE_NAME" ]]; then
    echo "bulk_load_influx not available. It is not specified explicitly and not found in \$PATH"
    exit 1
fi

# Load parameters - common
DATA_FILE_NAME=${DATA_FILE_NAME:-influx-data.gz}
DATABASE_PORT=${DATABASE_PORT:-8086}

EXE_DIR=${EXE_DIR:-$(dirname $0)}
source ${EXE_DIR}/load_common.sh

until curl http://${DATABASE_HOST}:${DATABASE_PORT}/ping 2>/dev/null; do
    echo "Waiting for InfluxDB"
    sleep 1
done

# Remove previous database
curl 'http://localhost:8086/query?q=drop%20database%20benchmark_db'
# Load new data
cat ${DATA_FILE} | gunzip | $EXE_FILE_NAME \
                                --backoff=${BACKOFF_SECS} \
                                --workers=${NUM_WORKERS} \
                                --batch-size=${BATCH_SIZE} \
                                --urls=http://${DATABASE_HOST}:${DATABASE_PORT}