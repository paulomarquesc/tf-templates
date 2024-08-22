#!/bin/bash
set -euo pipefail

terraform plan -var location=westus -var prefix=pmctest3 -out=plan1

terraform apply plan1
