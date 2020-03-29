int function(int o[], int n) {
    int r = o[0], a, b;

    for (int i = 1; i < n; i++) {
        a = (o[i] > 0) ? o[i] : -o[i], b = (r > 0) ? r : -r;

        while (a != b) {
            if (a > b)
                a -= b;
            else
                b -= a;
        }

        r = a;

        if (r == 1)
            return 1;
    }

    return r;
}