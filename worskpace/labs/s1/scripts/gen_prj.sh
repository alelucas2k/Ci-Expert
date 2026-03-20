#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: please provide the projec name"
    echo "Usage: ./create_prj.sh <project_name>"
    exit 1

fi

PRJ_NAME=$1
BASE_DIR="prj/$PRJ_NAME"

if [ -d "BASE_DIR" ]; then
    echo "Error: project'$PRJ_NAME' already exists."
    exit 1
fi

mkdir -p "$BASE_DIR/rtl"
mkdir -p "$BASE_DIR/tb"
mkdir -p "$BASE_DIR/docs"

touch "$BASE_DIR/rtl/.empty"
touch "$BASE_DIR/tb/.empty"

touch "$BASE_DIR/docs/README.md"

echo "Project 'PRJ_NAME' successfully created inside prj/"
