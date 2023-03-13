#pragma once

#include <stdint.h>
#include <stddef.h>

//  All print colors
enum print_Color {
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
    Red = 4,
    Purple = 5,
    Brown = 6,
    Gray = 7,
    Dark_Gray = 8,
    Light_Blue = 9,
    Light_Green = 10,
    Light_Cyan = 11,
    Light_Red = 12,
    Light_Purple = 13,
    Yellow = 14,
    White = 15

};

print_clear();
print_newLine(int *row);
print_char();
print_str(char *string, int *color);
print_var(int *var, int *color);

//  extra clear functions!

clear_char(char *letter, int *many);
clear_row(int *row);
clear_col(int *col);