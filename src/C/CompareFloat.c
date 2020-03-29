int function(double a, double b, double p) {
    if (((a - p) < b) && ((a + p) > b))
        return 1;

    else
        return 0;
 }