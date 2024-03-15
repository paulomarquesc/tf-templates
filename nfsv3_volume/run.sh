#!/bin/bash
set -euo pipefail

terraform plan -var location=westus -var prefix=pmctest2 -out=plan2

terraform apply plan2
