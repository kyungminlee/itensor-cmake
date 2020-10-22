#include "itensor/all.h"

using namespace itensor;

int main()
{
    Index i(2, "i"), j(2);
    ITensor t(i,j), u(i), s, v;
    t.fill(1.0);
    svd(t, u, s, v);
    printf("%.2f", norm(s));
}