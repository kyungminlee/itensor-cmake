#include <cmath>
#include "itensor/all.h"

using namespace itensor;

int main()
{
    Index i(2, "i"), j(2);
    ITensor t(i,j), u(i), s, v;
    t.fill(1.0);
    svd(t, u, s, v);
    double z = norm(s);
    printf("%.2f", z);
    if (abs(z - 2.0) < 1E-8) {
        exit(0);
    } else {
        exit(1);
    }
}