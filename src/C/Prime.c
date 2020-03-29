int function(int n) {
    int f, p, c = 1;

    if (n > 1) {
        p = 1;

        while (c != n) {
            f = 1, p += 2;

            for (int i = 3; i < p; i += 2) {
                if (p % i == 0) {
                    f = 0;

                    break;
                }
            }

            if (f == 1)
                c++;
        }
    }	
    else
        p = 2;

    return p;
}