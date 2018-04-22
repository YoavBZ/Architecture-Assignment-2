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

Complex initial;
Polynom p;
Polynom d;
double epsilon;

extern Complex power(Complex *c, long pow);
extern Complex complexMul(Complex *c1, Complex *c2);
extern Complex complexDiv(Complex *c1, Complex *c2);
extern Complex computePoly(Complex *c, Polynom *p);
// extern void deriviate(Polynom *p);

Polynom deriviate(Polynom *p)
{
    Polynom derivative;
    if (p->order != 0)
    {
        derivative.order = p->order - 1;
        derivative.coeffcients = calloc(derivative.order + 1, sizeof(Complex));
        for (long i = 1; i <= p->order; i++)
        {
            Complex temp = {i, 0.0};
            derivative.coeffcients[i - 1] = complexMul(&p->coeffcients[i], &temp);
        }
    }
    else
    {
        derivative.order = 0;
        derivative.coeffcients = calloc(derivative.order + 1, sizeof(Complex));
        derivative.coeffcients[0].real = 0;
        derivative.coeffcients[0].imaginery = 0;
    }
    return derivative;
}

// void nextInitial()
// {
//     Complex y1 = computePoly(&initial, &p);
//     Complex m = computePoly(&initial, &d);
//     Complex res = complexDiv(&y1, &m);
//     initial.real = initial.real - res.real;
//     initial.imaginery = initial.imaginery - res.imaginery;
// }

void scanInput(Polynom *p, double *epsilon, Complex *initial)
{
    scanf("epsilon = %lf\n", epsilon);
    scanf("order = %ld\n", &p->order);
    p->coeffcients = calloc(p->order + 1, sizeof(Complex));
    for (long i = 0; i <= p->order; i++)
    {
        long index;
        Complex c;
        scanf("coeff %ld = %lf %lf\n", &index, &c.real, &c.imaginery);
        p->coeffcients[index] = c;
    }
    scanf("initial = %lf %lf\n", &initial->real, &initial->imaginery);

    printf("epsilon = %.17lf\n", *epsilon);
    printf("order = %ld\n", p->order);
    for (long i = 0; i <= p->order; i++)
    {
        printf("coeff %ld = %lf %lf\n", i, p->coeffcients[i].real, p->coeffcients[i].imaginery);
    }
    printf("inital = %lf %lf\n", initial->real, initial->imaginery);
}

int main(int argc, char **argv)
{

    scanInput(&p, &epsilon, &initial);
    d = deriviate(&p);
    nextInitial();

    free(p.coeffcients);
    return 0;
}