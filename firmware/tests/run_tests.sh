#!/bin/bash

# Compilar los tests
g++ -I. -I.. -std=c++11 ButtonsHandler_test.cpp ../ButtonsHandler.cpp -o test_buttons

# Ejecutar los tests
./test_buttons 