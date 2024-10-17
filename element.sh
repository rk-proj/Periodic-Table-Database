#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if an argument was provided
if [[ -z $1 ]] 
then
  echo "Please provide an element as an argument."
  exit 0
else
  ELEMENT_INPUT=$1
fi

VALIDATE_INPUT() {

  ATOMIC_NUMBER=""

# Check if input is a number
if [[ "$ELEMENT_INPUT" =~ ^[0-9]+$ ]] 
then
  ATOMIC_NUMBER="$ELEMENT_INPUT"
# Check if input is a valid symbol
elif [[ "$ELEMENT_INPUT" =~ ^[A-Z][a-z]?$ ]] 
then
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$ELEMENT_INPUT'")
# Check if input is a valid element name
elif [[ "$ELEMENT_INPUT" =~ ^[A-Z][a-z]*$ ]] 
then
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$ELEMENT_INPUT'")
else
  echo "I could not find that element in the database."
  exit 0
fi

# Check if ATOMIC_NUMBER was found
if [[ -z "$ATOMIC_NUMBER" ]] 
then
  echo "I could not find that element in the database."
  exit 0
fi

}

VALIDATE_INPUT

# Query the database to find the element details
ELEMENT_DETAILS=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM elements e JOIN properties p ON e.atomic_number = p.atomic_number JOIN types t ON p.type_id = t.type_id WHERE e.atomic_number = $ATOMIC_NUMBER")

# Check if the query returned any results
if [[ -z "$ELEMENT_DETAILS" ]] 
then
  echo "I could not find that element in the database."
  exit 0
else
  echo "$ELEMENT_DETAILS" | while IFS='|' read -r ATOMIC_NUMBER NAME SYMBOL TYPE ATOMIC_MASS MELTING_POINT BOILING_POINT
  do
    # Output the formatted string
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  done
fi

