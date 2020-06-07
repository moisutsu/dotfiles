#!/bin/bash

bash configs/symbolic_link.sh

bash configs/install.sh

exec $SHELL -l
