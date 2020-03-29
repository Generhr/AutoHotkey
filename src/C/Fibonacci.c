int function(int n) {
    int a = 0, b = 1, c;

    for (int i = 1; i <= n; ++i)
        c = b, b += a, a = c;

    return c;
}