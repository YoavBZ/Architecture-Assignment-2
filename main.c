#include <stdio.h>
#include <stdlib.h>

typedef struct Complex
{
    double real;
    double imaginery;
} Complex;

typedef struct Polynom
{
    long order;
    Complex *coeffcients;
} Polynom;

void scanInput(Polynom *p, double *epsilon, Complex *initial)
{
    scanf("epsilon = %lf\n", *epsilon);
    scanf("order = %ld\n", p->order);
    p->coeffcients = malloc(sizeof(Complex) * (p->order + 1));
    for (long i = 0; i <= p->order; i++)
    {
        long index;
        Complex c;
        scanf("coeff %ld = %lf %lf\n", &index, &c.real, &c.imaginery);
        p->coeffcients[index] = c;
    }
    scanf("initial = %lf %lf\n", initial->real, initial->imaginery);

    printf("epsilon = %.17lf\n", *epsilon);
    printf("order = %ld\n", p->order);
    for (long i = 0; i <= p->order; i++)
    {
        printf("coeff %ld = %lf %lf\n", i, p->coeffcients[i].real, p->coeffcients[i].imaginery);
    }
    printf("inital = %lf %lf\n", initial->real, initial->imaginery);
}

Polynom deriviate(Polynom *p)
{
    Polynom derivative;
    if (p->order != 0)
    {
        derivative.order = p->order - 1;
        derivative.coeffcients = calloc(derivative.order + 1, sizeof(Complex));
        for (long i = 0; i <= derivative.order; i++)
        {
            Complex temp = {i, 0.0};
            derivative.coeffcients[i] = mul(&p->coeffcients[i + 1], &temp);
        }
    }
    else
    {
        derivative.order = 0;
        derivative.coeffcients = calloc(derivative.order + 1, sizeof(Complex));
        derivative.coeffcients[0].real = 0;
        derivative.coeffcients[0].imaginery = 0;
    }
}
Complex computePoly(Complex *c, Polynom *p)
{
    Complex retval = {0.0, 0.0};
    for (long i = 0; i <= p->order; i++)
    {
        Complex temp = power(c, i);
        temp = mul(&temp, &p->coeffcients[i]);
        retval.real += temp.real;
        retval.imaginery += temp.imaginery;
    }
    return retval;
}

Complex power(Complex *c, long pow)
{
    Complex retval = {1.0, 0.0};
    for (long i = 0; i < pow; i++)
    {
        retval = mul(&retval, c);
    }
    return retval;
}

Complex mul(Complex *c1, Complex *c2)
{
    Complex c3;
    c3.real = (c1->real * c2->real) - (c1->imaginery * c2->imaginery);
    c3.imaginery = (c1->real * c2->imaginery) + (c1->imaginery * c2->real);
    return c3;
}

int main(int argc, char **argv)
{
    Polynom p;
    double epsilon;
    Complex initial;
    scanInput(&p, &epsilon, &initial);

    free(p.coeffcients);
    return 0;
}