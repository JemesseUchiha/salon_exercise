#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples -c"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo -e "\n~~~~~ Salon Appointment ~~~~~\n"
  SERVICES_LIST=$($PSQL "SELECT * FROM services ORDER BY service_id")
  echo "$SERVICES_LIST" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  echo -e "\n\n Please select your service."
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      # send to main menu
      MAIN_MENU "That is not a valid service number."
    else
    APP_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $APP_SERVICE ]]
    then
      # send to main menu
      MAIN_MENU "That is not a valid service number."
    else
      echo -e "\nYou select \"$APP_SERVICE\" for the appointment"
      echo -e "Please insert the customer phone number."
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "Please insert the customer name."
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
      fi
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      echo -e "Please insert the appointment time."
      read SERVICE_TIME
      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      APP_SERVICE_FORMATTED=$(echo $APP_SERVICE | sed 's/ |/"/')
      echo -e "\nI have put you down for a $APP_SERVICE_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
} 

MAIN_MENU
